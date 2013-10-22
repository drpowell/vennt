
fdr_cutoff = 0.01
logFCcol=2
pValCol=3
fdrCol = 6

cmp = (x,y) -> if x<y
                   return 1
               else if x>y
                   return -1
               else
                   return 0

by_float = (a,b) ->
    x = parseFloat( a )
    y = parseFloat( b )
    cmp(x,y)

by_float_abs = (a,b) ->
    x = Math.abs(parseFloat( a ))
    y = Math.abs(parseFloat( b ))
    cmp(x,y)

jQuery.fn.dataTableExt.oSort['by-float-desc'] = by_float
jQuery.fn.dataTableExt.oSort['by-float-asc'] = (a,b) -> by_float(b,a)
jQuery.fn.dataTableExt.oSort['by-float-abs-desc'] = by_float_abs
jQuery.fn.dataTableExt.oSort['by-float-abs-asc'] = (a,b) -> by_float_abs(b,a)

hide_columns = (dat) ->
    for col in dat["aoColumns"]
        title = col["sTitle"]
        if ($.inArray(title, ['Feature','product','logFC','adj.P.Val'])>=0)
            col["bVisible"] = true
        else
            col["bVisible"] = false
        if ($.inArray(title, ['adj.P.Val'])>=0)
            col["sType"] = "by-float"
        if ($.inArray(title, ['logFC'])>=0)
            col["sType"] = "by-float-abs"
    dat

mkTable = (pre, data, sort, rowCallback) ->
    $('#demo').html( pre + '<table cellpadding="0" cellspacing="0" border="0" class="display" id="example"></table>' )
    settings =
        sScrollY: "200px",
        bPaginate: false,
        bScrollCollapse: true,
        aaSorting: sort,
        fnRowCallback: rowCallback

    $('#example').dataTable( $.extend(data, settings) )

window.showTable = (name) ->
    mkTable('<h3>'+name+'</h3>',
            hide_columns(globalData['data'][name]),
            [[fdrCol, "asc"]],
            (row, dat) ->
                 $(row).removeClass('odd even')
                 set_pos_neg(dat[2], row))
    update_rows_significance()

set_pos_neg = (v, elem) -> $(elem).addClass(if (v >= 0) then "pos" else "neg")

update_rows_significance = () ->
    return if $($('#demo table th')[pValCol]).html() != 'adj.P.Val'
    $('#demo table tr').each(set_significance)

set_significance = (i, tr) ->
  pval = Number($($('td',tr)[pValCol]).text())
  if (pval < fdr_cutoff)
    $(tr).addClass('sig')
    $(tr).removeClass('nosig')
  else
    $(tr).removeClass('sig')
    $(tr).addClass('nosig')

num_fdr = (rows) ->
  num = 0; up=0; down=0
  for row in rows
      if row[fdrCol]<fdr_cutoff
          num+=1
          if (row[logFCcol]>0)
              up++
          else
              down++
  {'num': num, 'up': up, 'down': down}

set_counts = (li) ->
  name = $(li).attr('class')
  nums=num_fdr(globalData['data'][name]["aaData"])
  $(".total",li).text(nums['num'])
  $(".up",li).html(nums['up']+"&uarr;")
  $(".down",li).html(nums['down']+"&darr;")

  # "("+(nums['num']*fdr_cutoff).toFixed(1)+")")

set_all_counts = ->
  $('#files li').each((i,elem) -> set_counts(elem))

get_selected = ->
  sels = $('.selected')
  res = []
  for sel in sels
      name = $(sel).parent('li').attr('class')
      if $(sel).hasClass('total')
        res.push
            name: name
            typ: '' # 'Up/Down'
            func: (row) -> row[fdrCol] < fdr_cutoff
      else if $(sel).hasClass('up')
        res.push
            name: name
            typ: 'Up : '
            func: (row) -> row[fdrCol] < fdr_cutoff && row[logFCcol]>=0
      else if $(sel).hasClass('down')
        res.push
            name: name
            typ: 'Down : '
            func: (row) -> row[fdrCol] < fdr_cutoff && row[logFCcol]<0
  res

# Handle the selected counts.  Generate the venn table and diagram
update_selected = ->

  $('#file_set').hide()
  $('#file_set table').empty()
  set = get_selected()
  return if set.length==0
  $('#file_set').show()

  rows = []
  for name, d of globalData['data']
    rows = d['aaData']
    break

  forRows = (cb) ->
              for i in [0..rows.length-1]
                  key=""
                  rowSet = []
                  for s in set
                      # TODO  - check files are sorted by gene!
                      row = globalData['data'][s['name']]['aaData'][i]
                      rowSet.push(row)
                      if s['func'](row)
                        key += "1"
                      else
                        key += "0"
                  cb(key, rowSet, set)

  counts={}
  forRows (key) ->
      counts[key] ?= 0
      counts[key] += 1

  tr = $(document.createElement('tr'))
  for s in set
    tr.append("<th><div class='rotate'>#{s['typ']}#{s['name']}</div></th>")
  tr.append("<th>Number")
  $('#file_set table').append('<thead>')
  $('#file_set table thead').append(tr)
  $('#file_set table').append('<tbody>')

  for k,v of counts
    continue if Number(k) == 0
    tr = $(document.createElement('tr'))
    for x in k.split('')
        tr.append("<td class='ticks'>#{tick_or_cross(x)}")
    tr.append("<td class='total'><a href='#'>#{v}</a>")
    $('#file_set table').append(tr)

    # Ridiculous hack so 'k' is not used in callback.  Necessary because of daft js scoping
    closure = (this_k) -> $('#file_set table tr a:last').click(() -> secondary_table(forRows, this_k, set))
    closure(k)

  $('#file_set li[data-target=venn]').addClass('disabled')

  $('#file_set svg').remove()
  if set.length<=4
      $('#file_set li[data-target=venn]').removeClass('disabled')
      n = set.length
      venn = {}
      for i in [1 .. Math.pow(2,set.length)-1]
          venn[i] = {str: counts[reverseStr(toBinary(n,i))] || 0}
      for s,i in set
          venn[1<<i]['lbl'] = s['typ'] + s['name']
      venn['click'] = (x) -> secondary_table(forRows, reverseStr(toBinary(n,x)), set)
      draw_venn(n, '#file_set #venn', venn)

  # Return to 'table' if venn is disabled
  if $('#file_set li[data-target=venn]').hasClass("disabled")
      clickTab($('#file_set li[data-target=table]'))

setup_tabs = ->
    $('#file_set .nav a').click (el) -> clickTab($(el.target).parent('li'))
    clickTab($('#file_set li[data-target=venn]'))

clickTab = (li) ->
    return if $(li).hasClass('disabled')
    $('#file_set .nav li').removeClass('active')
    li.addClass('active')
    id = li.attr('data-target')
    $('#file_set #table, #file_set #venn').hide()
    $('#file_set #'+id).show()

toBinary = (n,x) -> ("00000" +  x.toString(2)).substr(-n)
reverseStr = (s) -> s.split('').reverse().join('')

tick_or_cross = (x) -> "<i class='glyphicon glyphicon-#{if x=="1" then "ok" else "remove"}'></i>"

secondary_table = (forRows, k, set) ->
    dat = []
    forRows (key, rowSet) ->
        if key==k
            row = rowSet[0][0..1]
            row.push v[logFCcol] for v in rowSet
            dat.push(row)

    desc = []
    cols = [{sTitle:"Feature"}, {sTitle:"product"}]
    i=0
    for s in set
        cols.push({sTitle:"logFC - #{s['name']}"})
        desc.push(tick_or_cross(k[i]) + s['typ'] + s['name'])
        i+=1

    descStr = "<ul class='unstyled'>"+desc.map((s) -> "<li>"+s).join('')+"</ul>"
    mkTable(descStr, {aaData: dat, aoColumns: cols},
            [[0, 'asc']],
             (row, dat) ->
                         $(row).removeClass('odd even')
                         $("td", row).each (i, td) ->
                             if i>=2
                                 set_pos_neg(Number($(td).html()), td)
                                 $(td).addClass(if (k[i-2] == '1') then 'sig' else 'nosig')
           )

$(document).ready(() ->
  fdr_field = "input.fdr-fld"

  $(fdr_field).keyup(() ->
    v = Number($(this).val())
    if (isNaN(v) || v<0 || v>1)
        $(this).addClass('error')
    else
        $(this).removeClass('error')
        set_fdr_cutoff(v)
  )

  set_fdr_cutoff = (v) ->
    fdr_cutoff = v
    slider.set_slider(v)
    set_all_counts()
    update_selected()
    update_rows_significance()

  sel_span = (item) ->
      if $(item).hasClass('selected')
        $(item).removeClass('selected')
      else
        $(item).siblings('span').removeClass('selected')
        $(item).addClass('selected')
      update_selected()
      false

  span = (clazz) -> "<span class='selectable #{clazz}'></span>"

  slider = new Slider( "#fdrSlider", fdr_field, set_fdr_cutoff)


  init = () ->
      setup_tabs()
      $("input.fdr-fld").value = fdr_cutoff
      slider.set_slider(fdr_cutoff)

      $.each(globalData['order'], (i, name) ->
        $("#files").append(
          "<li class='#{name}'>"+
          "<a class='file' href='#' onClick='showTable(\"#{name}\")'>#{name}</a>"+
          span("total")+span("up")+span("down") +
           "")
      )
      $('.selectable').click( -> sel_span($(this)) )
      set_all_counts()
      update_selected()

      showTable(globalData['order'][0])

  init()
)
