dge_venn_version = '0.1'


g_fdr_cutoff = 0.01
key_column = 'key'
id_column = 'Feature'
fdrCol = 'adj.P.Val'
logFCcol = 'logFC'

setup_tabs = ->
    $('#overlaps .nav a').click (el) -> clickTab($(el.target).parent('li'))
    clickTab($('#overlaps li[data-target=venn]'))

clickTab = (li) ->
    return if $(li).hasClass('disabled')
    $('#overlaps .nav li').removeClass('active')
    li.addClass('active')
    id = li.attr('data-target')
    $('#overlaps #venn-table, #overlaps #venn').hide()
    $('#overlaps #'+id).show()


class Overlaps
    constructor: (@gene_table, @data) ->

    get_selected: () ->
      sels = $('.selected')
      res = []
      for sel in sels
          name = $(sel).parent('li').attr('class')
          if $(sel).hasClass('total')
            res.push
                name: name
                typ: '' # 'Up/Down'
                func: (row) -> row[fdrCol] < g_fdr_cutoff
          else if $(sel).hasClass('up')
            res.push
                name: name
                typ: 'Up : '
                func: (row) -> row[fdrCol] < g_fdr_cutoff && row[logFCcol]>=0
          else if $(sel).hasClass('down')
            res.push
                name: name
                typ: 'Down : '
                func: (row) -> row[fdrCol] < g_fdr_cutoff && row[logFCcol]<0
      res

    _forRows: (set, cb) ->
        for id in @data.ids
            rowSet = @data.get_data_for_id(id)
            key = ""
            for s in set
                row = rowSet[s.name]
                key += if s.func(row) then "1" else "0"
            cb(key, rowSet)


    _int_to_key: (size, i) ->
        toBinary = (n,x) -> ("00000" +  x.toString(2)).substr(-n)
        reverseStr = (s) -> s.split('').reverse().join('')
        reverseStr(toBinary(size,i))

    _tick_or_cross: (x) ->
        "<i class='glyphicon glyphicon-#{if x then 'ok' else 'remove'}'></i>"



    _mk_venn_table: (set,counts) ->
        table = $('<table>')
        str = '<thead><tr>'
        for s in set
            str += "<th><div class='rotate'>#{s['typ']}#{s['name']}</div></th>"
        str += "<th>Number</tr></thead>"
        table.html(str)

        for k,v of counts
            continue if Number(k) == 0
            do (k,v) =>
                tr = $('<tr>')
                for x in k.split('')
                    tr.append("<td class='ticks'>#{@_tick_or_cross(x=='1')}")
                tr.append("<td class='total'><a href='#'>#{v}</a>")
                $(table).append(tr)

                $('tr a:last',table).click(() => @_secondary_table(k, set))

        $('#overlaps #venn-table').empty()
        $('#overlaps #venn-table').append(table)

    _mk_venn_diagram: (set, counts) ->
        # Draw venn diagram
        $('#overlaps svg').remove()
        if set.length<=4
            n = set.length
            venn = {}
            # All numbers in the venn
            for i in [1 .. Math.pow(2,set.length)-1]
                do (i) =>
                    str = @_int_to_key(n,i)
                    venn[i] = {str: counts[str] || 0}
                    venn[i]['click'] = () => @_secondary_table(str, set)
            # Add the outer labels
            for s,i in set
                do (s,i) ->
                    venn[1<<i]['lbl']   = s['typ'] + s['name']
                    #venn[1<<i]['lblclick'] = () -> console.log(s['name'])
            draw_venn(n, '#overlaps #venn', venn)

    # Handle the selected counts.  Generate the venn table and diagram
    update_selected: () ->
        set = @get_selected()
        return if set.length==0

        counts={}
        @_forRows(set, (key) ->
            counts[key] ?= 0
            counts[key] += 1
        )

        @_mk_venn_table(set, counts)
        @_mk_venn_diagram(set, counts)

        $('#overlaps li[data-target=venn]').toggleClass('disabled', set.length>4)

        # Return to 'venn-table' if venn is disabled
        if $('#overlaps li[data-target=venn]').hasClass("disabled")
            clickTab($('#overlaps li[data-target=venn-table]'))

    _secondary_table: (k, set) ->
        rows = []
        @_forRows(set, (key, rowSet) ->
            if key==k
                row = []
                for s in set
                    if !row.id
                        row.id = rowSet[s.name][id_column]
                    row.push rowSet[s.name][logFCcol]
                rows.push(row)
        )

        desc = []
        cols = [@gene_table.mk_column('id', id_column, '')]
        i=0
        for s in set
            signif = k[i]=='1'
            css = if signif then {} else {cssClass: 'nosig'}
            cols.push(@gene_table.mk_column(i, "logFC - #{s['name']}", 'logFC', css))
            desc.push(@_tick_or_cross(signif) + s['typ'] + s['name'])
            i+=1

        descStr = "<ul class='list-unstyled'>"+desc.map((s) -> "<li>"+s).join('')+"</ul>"
        @gene_table.set_name_and_desc("",descStr)

        @gene_table.set_data(rows, cols)

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

    get_data_for_key: (key) ->
        @ids.map((id) => @data[id][key])

    get_data_for_id: (id) ->
        @data[id]

    num_fdr: (key) ->
        num = 0; up=0; down=0
        for id,d of @data
            if d[key][fdrCol]<g_fdr_cutoff
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

    set_name_and_desc: (name,desc) ->
        $('#gene-list-name').html(name)
        $('#gene-list-desc').html(desc)

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
        ret.cssClasses += if item[fdrCol] > g_fdr_cutoff then 'nosig' else 'sig'
        ret

    _get_formatter: (type, val) ->
        switch type
            when 'logFC'
                cl = if (val >= 0) then "pos" else "neg"
                "<div class='#{cl}'>#{val.toFixed(2)}</div>"
            when 'FDR'
                if val<0.01 then val.toExponential(2) else val.toFixed(2)
            else
                val

    _get_sort_func: (type, col) ->
        comparer = (x,y) -> (if x == y then 0 else (if x > y then 1 else -1))
        (r1,r2) ->
            r = 0
            x=r1[col]; y=r2[col]
            switch type
                when 'logFC'
                    comparer(Math.abs(x), Math.abs(y))
                when 'FDR'
                    comparer(x, y)
                else
                    comparer(x, y)

    mk_column: (fld, name, type, opts={}) ->
        o =
            id: fld
            field: fld
            name: name
            sortable: true
            formatter: (i,c,val,m,row) => @_get_formatter(type, val)
            sortFunc: @_get_sort_func(type, fld)
        $.extend(o, opts)

    _sorter: (args) ->
        if args.sortCol.sortFunc
            @dataView.sort(args.sortCol.sortFunc, args.sortAsc)
        else
            console.log "No sort function for",args.sortCol

    _update_info: () ->
        view = @grid.getViewport()
        btm = d3.min [view.bottom, @dataView.getLength()]
        $(@opts.elem_info).html("Showing #{view.top}..#{btm} of #{@dataView.getLength()}")

    refresh: () ->
        @grid.invalidate()

    set_data: (data, columns) ->
        @dataView.beginUpdate()
        @grid.setColumns([])
        @dataView.setItems(data)
        @dataView.reSort()
        @dataView.endUpdate()
        @grid.setColumns(columns)

class SelectorTable
    elem = "#files"
    constructor: (@data) ->
        @gene_table = new GeneTable({elem:'#gene-table', elem_info: '#gene-table-info'})
        @overlaps = new Overlaps(@gene_table, @data)
        @_mk_selector()
        @set_all_counts()

    _mk_selector: () ->
        span = (clazz) -> "<span class='selectable #{clazz}'></span>"
        for name in @data.keys
            do (name) =>
                li = $("<li class='#{name}'><a class='file' href='#'>#{name}</a>"+
                       span("total")+span("up")+span("down"))
                $('a',li).click(() => @selected(name))
                $(elem).append(li)
        $('.selectable').click((el) => @_sel_span(el.target))

    selected: (name) ->
        rows = @data.get_data_for_key(name)

        columns = [@gene_table.mk_column(id_column, id_column, ''),
                   @gene_table.mk_column(logFCcol, logFCcol, 'logFC'),
                   @gene_table.mk_column(fdrCol, fdrCol, 'FDR')]
        @gene_table.set_data(rows, columns)
        @gene_table.set_name_and_desc("for '#{name}'", "")

    set_all_counts: () ->
        $('li',elem).each((i,e) => @set_counts(e))
        @gene_table.refresh()
        @overlaps.update_selected()

    set_counts: (li) ->
        name = $(li).attr('class')
        nums = @data.num_fdr(name)
        $(".total",li).text(nums['num'])
        $(".up",li).html(nums['up']+"&uarr;")
        $(".down",li).html(nums['down']+"&darr;")

    _sel_span: (item) ->
        if $(item).hasClass('selected')
            $(item).removeClass('selected')
        else
            $(item).siblings('span').removeClass('selected')
            $(item).addClass('selected')
        @overlaps.update_selected()
        false


class DGEVenn
    constructor: () ->
        setup_tabs()
        $("input.fdr-fld").value = g_fdr_cutoff

        d3.csv("data.csv", (rows) => @_data_ready(rows))

    _data_ready: (rows) ->
        data = new Data(rows)
        @selector = new SelectorTable(data)
        @selector.selected(data.keys[0])

        @_setup_fdr_slider()

    _setup_fdr_slider: () ->
        fdr_field = "input.fdr-fld"

        @slider = new Slider( "#fdrSlider", fdr_field, (v) => @set_fdr_cutoff(v))
        @slider.set_slider(g_fdr_cutoff)

        $(fdr_field).keyup((ev) =>
            el = ev.target
            v = Number($(el).val())
            if (isNaN(v) || v<0 || v>1)
                $(el).addClass('error')
            else
                $(el).removeClass('error')
            @set_fdr_cutoff(v)
        )

    set_fdr_cutoff: (v) ->
        g_fdr_cutoff = v
        @slider.set_slider(v)
        @selector.set_all_counts()

setup_about_modal = () ->
    html = "<div id='about-modal' class='modal fade' tabindex='-1' role='dialog' aria-labelledby='myModalLabel' aria-hidden='true'>
      <div class='modal-dialog'>
        <div class='modal-content'>
          <div class='modal-header'>
            <button type='button' class='close' data-dismiss='modal' aria-hidden='true'>x</button>
            <h3 id='myModalLabel'>About DGE Venn Explorer</h3>
          </div>
          <div class='modal-body'>
            <p>DGE Venn Explorer : Compare gene expression lists using a dynamic venn diagram</p>
            <p>Version : #{dge_venn_version}  (See <a target='_blank' href='https://raw.github.com/drpowell/DGE-venn/master/Changelog.txt'>Changelog</a>)</p>
            <p>Visit the <a href='http://drpowell.github.io/DGE-venn/'>DGE Venn Explorer project page</a>,
               or the <a href='https://github.com/drpowell/DGE-venn'>source code on GitHub</a>
            </p>
            <div>Written by <a href='http://thunking.drp.id.au/'>David R. Powell</a></div>
            <div class='supported-by'>
              Supported by <a href='http://vicbioinformatics.com/'>Victorian Bioinformatics Consortium, Monash University</a>
              and <a href='http://www.vlsci.org.au/lscc'>VLSCI\'s Life Sciences Computation Centre</a>
            </div>
          </div>
          <div class='modal-footer'>
            <button class='btn btn-primary' data-dismiss='modal' aria-hidden='true'>Close</button>
          </div>
        </div><!-- /.modal-content -->
      </div><!-- /.modal-dialog -->
`   </div><!-- /.modal -->
    "
    $('#about-modal').replaceWith(html)

$(document).ready(() -> setup_about_modal(); new DGEVenn())
