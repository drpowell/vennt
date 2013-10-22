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

    text: (str,x,y, opts = {}) ->
        s = @svg.append("svg:text")
            .text(str)
            .attr('x', x)
            .attr('y', y)
        s.attr("text-anchor", opts.anchor ? 'middle')
        for ev in ['click','mouseover','mouseout','mousemove']
            s.on(ev, opts[ev]) if opts[ev]?

draw_venn1 = (elem, opts) ->
    w = 300
    h = 300
    r = 400/3
    svg = new SVG(elem, w, h, 5)
    svg.circle(w/2,r, r)
       .style("fill", "cyan")
       .style("fill-opacity", ".5")
    svg.text(opts[1]['lbl'], w/2, r/3, {anchor: 'start', click: opts[1]['lblclick']})
    svg.text(opts[1]['str'], w/2, r,   opts[1])

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
    svg.text(opts[b1]['lbl'], w/2-r/2, r/2, {anchor: 'end', click: opts[b1]['lblclick']})  # left
    svg.text(opts[b2]['lbl'], w/2+r/2, r/2, {anchor: 'start', click: opts[b2]['lblclick']})    # right

    ss = [{ind: b1, x: r/2, y: r},
          {ind: b2, x: 5*r/2, y: r},
          {ind: b1|b2, x: 3*r/2, y: r}]

    for s in ss
        do (s) ->
            svg.text(opts[s.ind].str, s.x, s.y, opts[s.ind])

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

    svg.text(opts[b1]['lbl'], w/4, r/4,        {anchor: 'end', click: opts[b1]['lblclick']})  # top
    svg.text(opts[b2]['lbl'], w/10, r+2*z,     {anchor: 'end', click: opts[b2]['lblclick']})    # left
    svg.text(opts[b3]['lbl'], w-r/3, r+2*z,    {anchor: 'start', click: opts[b3]['lblclick']})  # right

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
            svg.text(opts[s.ind].str, s.x, s.y, opts[s.ind])

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

    text = (str,x,y, opts = {}) ->
            s = z.append("svg:text")
                 .text(str)
                 .attr('x', x)
                 .attr('y', y)
            s.attr("text-anchor", opts.anchor ? 'middle')
            for ev in ['click','mouseover','mouseout','mousemove']
                s.on(ev, opts[ev]) if opts[ev]?


    b1=1; b2=2; b3=4; b4=8;

    text(opts[b1]['lbl'], 190,  900,       {anchor: 'end', click: opts[b1]['lblclick']})
    text(opts[b2]['lbl'], 260,  810,       {anchor: 'end', click: opts[b2]['lblclick']})
    text(opts[b3]['lbl'], 550,  810,       {anchor: 'start', click: opts[b3]['lblclick']})
    text(opts[b4]['lbl'], 630,  900,       {anchor: 'start', click: opts[b4]['lblclick']})

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
            text(opts[s.ind].str, s.x, s.y, opts[s.ind])



window.draw_venn = (n, elem, opts) ->
    switch n
        when 1 then draw_venn1(elem, opts)
        when 2 then draw_venn2(elem, opts)
        when 3 then draw_venn3(elem, opts)
        when 4 then draw_venn4(elem, opts)
