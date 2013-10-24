class SVG
    # Constructor
    constructor: (elem,@w,@h,@m) ->
        @svg = d3.select(elem).append("svg:svg")
                .attr("class", "venn-diagram")
                .attr("width", @w+2*@m)
                .attr("height", @h+2*@m)
                .append("g")
                  .attr("transform","translate(#{@m},#{@m})")


    circle: (x,y,r) ->
        @svg.append("svg:circle")
            .attr("cx", x)
            .attr("cy", y)
            .attr("r", r)

    textLbl: (str,x,y, opts = {}) -> @textLblE(@svg,str,x,y,opts)

    textStr: (str,x,y, opts = {}) -> @textStrE(@svg,str,x,y,opts)

    textLblE: (e,str,x,y, opts = {}) ->
        opts.css = 'lbl'
        @textE(e,str,x,y,opts)

    textStrE: (e,str,x,y, opts = {}) ->
        opts.css = 'str'
        @textE(e,str,x,y,opts)

    textE: (e,str,x,y, opts = {}) ->
        s = e.append("svg:text")
             .text(str)
             .attr('x', x)
             .attr('y', y)
        s.attr("text-anchor", opts.anchor ? 'middle')
        s.attr("class",opts.css) if opts.css
        for ev in ['click','mouseover','mouseout','mousemove']
            s.on(ev, opts[ev]) if opts[ev]?

draw_venn1 = (elem, opts) ->
    w = 600
    h = 300
    r = 400/3
    svg = new SVG(elem, w, h, 5)
    svg.circle(150,r, r)
       .style("fill", "cyan")
       .style("fill-opacity", ".5")
    svg.textLbl(opts[1]['lbl'], 270, r/3, {anchor: 'start', click: opts[1]['lblclick']})
    svg.textStr(opts[1]['str'], 150, r,   opts[1])

draw_venn2 = (elem, opts) ->
    w = 600
    h = 350
    r = 400/3
    z = r*Math.sqrt(3)/2
    svg = new SVG(elem, w, h, 5)
    svg.circle(r,r+50, r)
       .style("fill", "#6fff05")
    svg.circle(2*r,r+50, r)
       .style("fill", "#ff6405")

    b1=1; b2=2;
    svg.textLbl(opts[b1]['lbl'], r+20, 30, {anchor: 'end', click: opts[b1]['lblclick']})  # left
    svg.textLbl(opts[b2]['lbl'], 2*r-20, 30, {anchor: 'start', click: opts[b2]['lblclick']})    # right

    ss = [{ind: b1, x: r/2, y: r+50},
          {ind: b2, x: 5*r/2, y: r+50},
          {ind: b1|b2, x: 3*r/2, y: r+50}]

    for s in ss
        do (s) ->
            svg.textStr(opts[s.ind].str, s.x, s.y, opts[s.ind])

draw_venn3 = (elem, opts) ->
    w = 400
    w2 = 600
    h = 380
    r = 400/3
    z = r*Math.sqrt(3)/2.0

    lm = 100 # left margin

    svg = new SVG(elem, w2, h, 30)
    svg.circle(w/2+lm,r, r)
       .style("fill", "#6fff05")
    svg.circle(r+lm,r+z, r)
       .style("fill", "#ff6405")
    svg.circle(2*r+lm,r+z, r)
       .style("fill", "#0525ff")

    b1=1; b2=2; b3=4;

    svg.textLbl(opts[b1]['lbl'], w/4+lm, r/4,        {anchor: 'end', click: opts[b1]['lblclick']})  # top
    svg.textLbl(opts[b2]['lbl'], w/10+lm, r+2*z,     {anchor: 'end', click: opts[b2]['lblclick']})    # left
    svg.textLbl(opts[b3]['lbl'], w-r/3+lm, r+2*z,    {anchor: 'start', click: opts[b3]['lblclick']})  # right

    ss = [{ind: b1,    x: w/2,   y: r/2},
          {ind: b2,    x: w/2-r, y: r+z+1.0*z/2.0 },
          {ind: b3,    x: w/2+r, y: r+z+1.0*z/2.0 },
          {ind: b1|b2, x: r,     y: r+1*z/3 },
          {ind: b1|b3, x: 2*r,   y: r+1*z/3 },
          {ind: b2|b3, x: w/2,   y: r+z+1*z/2 },
          {ind: b1|b2|b3, x: w/2,   y: r+2*z/3 }
        ]

    for s in ss
        do (s) ->
            svg.textStr(opts[s.ind].str, s.x+lm, s.y, opts[s.ind])

draw_venn4 = (elem, opts) ->
    rx=187
    ry=115
    svg = new SVG(elem, 750, 390,0)
    z = svg.svg.append("g")
           .attr("transform","translate(-50,-785)")
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

    b1=1; b2=2; b3=4; b4=8;

    svg.textLblE(z,opts[b1]['lbl'], 190,  900, {anchor: 'end', click: opts[b1]['lblclick']})
    svg.textLblE(z,opts[b2]['lbl'], 260,  810, {anchor: 'end', click: opts[b2]['lblclick']})
    svg.textLblE(z,opts[b3]['lbl'], 550,  810, {anchor: 'start', click: opts[b3]['lblclick']})
    svg.textLblE(z,opts[b4]['lbl'], 630,  900, {anchor: 'start', click: opts[b4]['lblclick']})

    ss= [{ind: b1, x: 215, y: 950},
         {ind: b2, x: 295, y: 840},
         {ind: b3, x: 505, y: 840},
         {ind: b4, x: 605, y: 950},

         {ind: b2|b3, x: 405, y: 870},
         {ind: b1|b4, x: 405, y: 1130},
         {ind: b1|b2|b3|b4, x: 405, y: 1010},

         {ind: b1|b2|b3, x: 325, y: 950},
         {ind: b2|b3|b4, x: 475, y: 950},

         {ind: b1|b3, x: 285, y: 1030},
         {ind: b2|b4, x: 525, y: 1030},

         {ind: b1|b2, x: 270, y: 900},
         {ind: b3|b4, x: 545, y: 900},

         {ind: b1|b3|b4, x: 345, y: 1070},
         {ind: b1|b2|b4, x: 465, y: 1070},
        ]

    for s in ss
        do (s) ->
            svg.textStrE(z,opts[s.ind].str, s.x, s.y, opts[s.ind])



window.draw_venn = (n, elem, opts) ->
    switch n
        when 1 then draw_venn1(elem, opts)
        when 2 then draw_venn2(elem, opts)
        when 3 then draw_venn3(elem, opts)
        when 4 then draw_venn4(elem, opts)
