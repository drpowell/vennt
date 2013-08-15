class SVG
    # Constructor
    constructor: (elem,@w,@h,@m) ->
        @svg = d3.select(elem).append("svg:svg")
                .attr("width", @w+2*@m)
                .attr("height", @h+2*@m)
                .append("g")
                  .attr("transform","translate(#{@m},#{@m})")


    circle: (x,y,r) ->
        @svg.append("svg:circle")
            .attr("cx", x)
            .attr("cy", y)
            .attr("r", r)

    text: (str,x,y, {click, anchor} = {}) ->
        s = @svg.append("svg:text")
            .text(str)
            .attr('x', x)
            .attr('y', y)
        anchor ?= 'middle'
        s.attr("text-anchor", anchor)
        click ?= null
        s.on('click', click) if click?

draw_venn1 = (elem, opts) ->
    w = 300
    h = 300
    r = 400/3
    svg = new SVG(elem, w, h, 5)
    svg.circle(w/2,r, r)
       .style("fill", "cyan")
       .style("fill-opacity", ".5")
    svg.text(opts[1]['lbl'], w/2, r/3, {anchor: 'start'})
    svg.text(opts[1]['str'], w/2, r,   {click: -> opts['click'](1) })

draw_venn2 = (elem, opts) ->
    w = 400
    h = 300
    r = 400/3
    z = r*Math.sqrt(3)/2
    svg = new SVG(elem, w, h, 5)
    svg.circle(r,r, r)
       .style("fill", "#6fff05")
    svg.circle(2*r,r, r)
       .style("fill", "#ff6405")

    b1=1; b2=2;
    svg.text(opts[b1]['lbl'], w/2-r/2, r/2, {anchor: 'end'})  # left
    svg.text(opts[b2]['lbl'], w/2+r/2, r/2, {anchor: 'start'})    # right

    svg.text(opts[b1]['str'], r/2, r,   {click: -> opts['click'](b1) })  #left
    svg.text(opts[b1|b2]['str'], 3*r/2, r, {click: -> opts['click'](b1|b2) })  #middle
    svg.text(opts[b2]['str'], 5*r/2, r, {click: -> opts['click'](b2) })  #right

draw_venn3 = (elem, opts) ->
    w = 400
    h = 380
    r = 400/3
    z = r*Math.sqrt(3)/2.0
    svg = new SVG(elem, w, h, 30)
    svg.circle(w/2,r, r)
       .style("fill", "#6fff05")
    svg.circle(r,r+z, r)
       .style("fill", "#ff6405")
    svg.circle(2*r,r+z, r)
       .style("fill", "#0525ff")

    b1=1; b2=2; b3=4;

    svg.text(opts[b1]['lbl'], w/4, r/4,        {anchor: 'end'})  # top
    svg.text(opts[b2]['lbl'], w/10, r+2*z,     {anchor: 'end'})    # left
    svg.text(opts[b3]['lbl'], w-r/3, r+2*z,    {anchor: 'start'})  # right

    svg.text(opts[b1]['str'], w/2, r/2,         {click: -> opts['click'](b1) })  #top
    svg.text(opts[b2]['str'], w/2-r, r+z+1.0*z/2.0, {click: -> opts['click'](b2) })  #left
    svg.text(opts[b3]['str'], w/2+r, r+z+1.0*z/2.0, {click: -> opts['click'](b3) })  #right

    svg.text(opts[b1|b2]['str'], r, r+1*z/3,       {click: -> opts['click'](b1|b2) })   #left
    svg.text(opts[b1|b3]['str'], 2*r, r+1*z/3,     {click: -> opts['click'](b1|b3) })   #right
    svg.text(opts[b2|b3]['str'], w/2, r+z+1*z/2,   {click: -> opts['click'](b2|b3) })   #bottom

    svg.text(opts[b1|b2|b3]['str'], w/2, r+2*z/3,     {click: -> opts['click'](b1|b2|b3) })  #middle

draw_venn4 = (elem, opts) ->
    rx=187
    ry=115
    svg = new SVG(elem, 600, 500,0)
    z = svg.svg.append("g")
           .attr("transform","translate(-123,-785)")
    z.append("g")
       .attr("transform","translate(479,1024) rotate(-40)")
       .append("ellipse")
       .attr("rx",rx)
       .attr("ry",ry)
       .style("fill", "#6fff05")
    z.append("g")
       .attr("transform","translate(407,938) rotate(-40)")
       .append("ellipse")
       .attr("rx",rx)
       .attr("ry",ry)
       .style("fill", "#ff6405")
    z.append("g")
       .attr("transform","translate(410,938) rotate(40)")
       .append("ellipse")
       .attr("rx",rx)
       .attr("ry",ry)
       .style("fill", "#0525ff")
    z.append("g")
       .attr("transform","translate(338,1024) rotate(40)")
       .append("ellipse")
       .attr("rx",rx)
       .attr("ry",ry)
       .style("fill", "#1e1e1e")

    text = (str,x,y,{click, anchor} = {}) ->
            s = z.append("svg:text")
                 .text(str)
                 .attr('x', x)
                 .attr('y', y)
            anchor ?= 'middle'
            s.attr("text-anchor", anchor)
            click ?= null
            s.on('click', click) if click?


    b1=1; b2=2; b3=4; b4=8;

    text(opts[b1]['lbl'], 190,  900,       {anchor: 'end'})
    text(opts[b2]['lbl'], 260,  810,       {anchor: 'end'})
    text(opts[b3]['lbl'], 550,  810,       {anchor: 'start'})
    text(opts[b4]['lbl'], 630,  900,       {anchor: 'start'})

    text(opts[b1]['str'], 215, 950,    {click: -> opts['click'](b1) })
    text(opts[b2]['str'], 295, 840,    {click: -> opts['click'](b2) })
    text(opts[b3]['str'], 505, 840,    {click: -> opts['click'](b3) })
    text(opts[b4]['str'], 605, 950,    {click: -> opts['click'](b4) })

    text(opts[b2|b3]['str'], 405, 870,     {click: -> opts['click'](b2|b3) })
    text(opts[b1|b4]['str'], 405, 1130,    {click: -> opts['click'](b1|b4) })
    text(opts[b1|b2|b3|b4]['str'], 405, 1010,    {click: -> opts['click'](b1|b2|b3|b4) })

    text(opts[b1|b2|b3]['str'], 325, 950,     {click: -> opts['click'](b1|b2|b3) })
    text(opts[b2|b3|b4]['str'], 475, 950,     {click: -> opts['click'](b1|b3|b4) })

    text(opts[b1|b3]['str'], 285, 1030,     {click: -> opts['click'](b1|b3) })
    text(opts[b2|b4]['str'], 525, 1030,     {click: -> opts['click'](b2|b4) })

    text(opts[b1|b2]['str'], 270, 900,     {click: -> opts['click'](b1|b2) })
    text(opts[b3|b4]['str'], 545, 900,     {click: -> opts['click'](b3|b4) })

    text(opts[b1|b3|b4]['str'], 345, 1070,     {click: -> opts['click'](b1|b3|b4) })
    text(opts[b1|b2|b4]['str'], 465, 1070,     {click: -> opts['click'](b1|b2|b4) })




window.draw_venn = (n, elem, opts) ->
    switch n
        when 1 then draw_venn1(elem, opts)
        when 2 then draw_venn2(elem, opts)
        when 3 then draw_venn3(elem, opts)
        when 4 then draw_venn4(elem, opts)

$(document).ready () ->
    draw_venn(1, '#venn1', {1: {lbl: 'Label', str: 'String'} })
    draw_venn(2, '#venn2', ({lbl: "Label #{n}", str: "Str #{n}"} for n in [0..3]))
    draw_venn(3, '#venn3', ({lbl: "Label #{n}", str: "Str #{n}"} for n in [0..7]))
    draw_venn(4, '#venn4', ({lbl: "Label #{n}", str: "#{n}"} for n in [0..15]))
