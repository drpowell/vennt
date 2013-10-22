
fdr_cutoff = 0.01

get_pos_neg = (v) -> if (v >= 0) then "pos" else "neg"

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
    do (k) ->
        $('#file_set table tr a:last').click(() -> secondary_table(forRows, k, set))

  $('#file_set li[data-target=venn]').addClass('disabled')

  # Draw venn diagram
  $('#file_set svg').remove()
  if set.length<=4
      $('#file_set li[data-target=venn]').removeClass('disabled')
      n = set.length
      venn = {}
      # All numbers in the venn
      for i in [1 .. Math.pow(2,set.length)-1]
          do (i) ->
              str = reverseStr(toBinary(n,i))
              venn[i] = {str: counts[str] || 0}
              venn[i]['click'] = () -> secondary_table(forRows, str, set)
      # Add the outer labels
      for s,i in set
          do (s,i) ->
              venn[1<<i]['lbl']   = s['typ'] + s['name']
              venn[1<<i]['lblclick'] = () -> showTable(s['name'])
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


g_fdr_field = "input.fdr-fld"

$(g_fdr_field).keyup(() ->
  v = Number($(this).val())
  if (isNaN(v) || v<0 || v>1)
      $(this).addClass('error')
  else
      $(this).removeClass('error')
      set_fdr_cutoff(v)
)

g_slider = null

set_fdr_cutoff = (v) ->
  fdr_cutoff = v
  g_slider.set_slider(v)
  set_all_counts()
  update_selected()
  update_rows_significance()

span = (clazz) -> "<span class='selectable #{clazz}'></span>"

key_column = 'key'
id_column = 'Feature'
fdrCol = 'adj.P.Val'
logFCcol = 'logFC'

class Data
    constructor: (rows) ->
        @data = {}
        for r in rows
            d = (@data[r[id_column]] ?= {})
            r.id ?= r[id_column]   # Needed by slickgrid (better be unique!)

            # Make number columns actual numbers
            for num_col in [fdrCol, logFCcol]
                r[num_col]=+r[num_col] if r[num_col]

            d[r[key_column]] = r

        @ids = d3.keys(@data)
        @keys = d3.keys(@data[@ids[0]])

    get_data_for: (key) ->
        @ids.map((id) => @data[id][key])

    num_fdr: (key) ->
        num = 0; up=0; down=0
        for id,d of @data
            if d[key][fdrCol]<fdr_cutoff
                num+=1
                if (d[key][logFCcol]>0)
                    up++
                else
                    down++
        {'num': num, 'up': up, 'down': down}

class GeneTable
    constructor: (@opts) ->
        grid_options =
            enableCellNavigation: true
            enableColumnReorder: false
            multiColumnSort: false
            forceFitColumns: true
        @dataView = new Slick.Data.DataView()
        @grid = new Slick.Grid(@opts.elem, @dataView, [], grid_options)

        @dataView.onRowCountChanged.subscribe( (e, args) =>
            @grid.updateRowCount()
            @grid.render()
            @_update_info()
        )

        @dataView.onRowsChanged.subscribe( (e, args) =>
            @grid.invalidateRows(args.rows)
            @grid.render()
        )

        @grid.onSort.subscribe( (e,args) => @_sorter(args) )
        @grid.onViewportChanged.subscribe( (e,args) => @_update_info() )

        # Set up event callbacks
        if @opts.mouseover
            @grid.onMouseEnter.subscribe( (e,args) =>
                i = @grid.getCellFromEvent(e).row
                d = @dataView.getItem(i)
                @opts.mouseover(d)
            )
        if @opts.mouseout
            @grid.onMouseLeave.subscribe( (e,args) =>
                @opts.mouseout()
            )
        if @opts.dblclick
            @grid.onDblClick.subscribe( (e,args) =>
                @opts.dblclick(@grid.getDataItem(args.row))
            )

        @_setup_metadata_formatter((ret) => @_meta_formatter(ret))

    _setup_metadata_formatter: (formatter) ->
        row_metadata = (old_metadata_provider) ->
            (row) ->
                item = this.getItem(row)
                ret = old_metadata_provider(row)

                formatter(item, ret)

        @dataView.getItemMetadata = row_metadata(@dataView.getItemMetadata)


    _meta_formatter: (item, ret) ->
        ret ?= {}
        ret.cssClasses ?= ''
        ret.cssClasses += if item[fdrCol] <= fdr_cutoff then 'sig' else 'nosig'
        ret

    _fc_div: (n) ->
        "<div class='#{get_pos_neg(n)}'>#{n.toFixed(2)}</div>"

    _columns: () ->
        [id_column, logFCcol, fdrCol].map((col) =>
            id: col
            name: col
            field: col
            sortable: true
            formatter: (i,c,val,m,row) =>
                if col in [logFCcol]
                    @_fc_div(val)
                else if col in [fdrCol]
                    if val<0.01 then val.toExponential(2) else val.toFixed(2)
                else
                    val
        )

    _sorter: (args) ->
        comparer = (x,y) -> (if x == y then 0 else (if x > y then 1 else -1))
        col = args.sortCol.id
        @dataView.sort((r1,r2) ->
            r = 0
            x=r1[col]; y=r2[col]
            if col in [logFCcol]
                r = comparer(Math.abs(x), Math.abs(y))
            else if col in [fdrCol]
                r = comparer(x, y)
            else
                r = comparer(x,y)
            r * (if args.sortAsc then 1 else -1)
        )

    _update_info: () ->
        view = @grid.getViewport()
        btm = d3.min [view.bottom, @dataView.getLength()]
        $(@opts.elem_info).html("Showing #{view.top}..#{btm} of #{@dataView.getLength()}")

    set_data: (data) ->
        @dataView.beginUpdate()
        @grid.setColumns([])
        @dataView.setItems(data)
        @dataView.reSort()
        @dataView.endUpdate()
        @grid.setColumns(@_columns())

        #set_pos_neg(dat[2], row))
        #update_rows_significance()

class SelectorTable
    elem = "#files"
    constructor: (@data) ->
        @gene_table = new GeneTable({elem:'#gene-table', elem_info: '#gene-table-info'})
        for name in data.keys
            do (name) =>
                li = $("<li class='#{name}'><a class='file' href='#'>#{name}</a>"+
                       span("total")+span("up")+span("down"))
                $('a',li).click(() => @selected(name))
                $(elem).append(li)
        $('.selectable').click((el) => @_sel_span(el.target))
        @set_all_counts()
        #update_selected()

    selected: (name) ->
        rows = @data.get_data_for(name)
        @gene_table.set_data(rows)
        $('#gene-list-name').text("for '#{name}'")

    set_all_counts: () ->
        $('li',elem).each((i,e) => @set_counts(e))

    set_counts: (li) ->
        name = $(li).attr('class')
        nums = @data.num_fdr(name)
        $(".total",li).text(nums['num'])
        $(".up",li).html(nums['up']+"&uarr;")
        $(".down",li).html(nums['down']+"&darr;")

        # "("+(nums['num']*fdr_cutoff).toFixed(1)+")")

    _sel_span: (item) ->
        if $(item).hasClass('selected')
            $(item).removeClass('selected')
        else
            $(item).siblings('span').removeClass('selected')
            $(item).addClass('selected')
        update_selected()
        false



init = () ->
    setup_tabs()
    $("input.fdr-fld").value = fdr_cutoff

    g_slider = new Slider( "#fdrSlider", g_fdr_field, set_fdr_cutoff)
    g_slider.set_slider(fdr_cutoff)

    d3.csv("data.csv", (rows) ->
        data = new Data(rows)
        sel = new SelectorTable(data)
        sel.selected(data.keys[0])
    )

$(document).ready(() -> init())
