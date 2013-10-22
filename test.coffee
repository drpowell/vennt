$(document).ready () ->
    draw_venn(1, '#venn1', {1: {lbl: 'Label', str: 'String'} })
    draw_venn(2, '#venn2', for n in [0..3]
                               do (n) ->
                                   lbl: "Label #{n}"
                                   str: "Str #{n}"
                                   click: () -> console.log("click="+n)
                                   mouseover: () -> console.log("mouseover="+n)
                                   mouseout: () -> console.log("mouseout="+n)
            )
    draw_venn(3, '#venn3', for n in [0..7]
                               do (n) ->
                                   lbl: "Label #{n}"
                                   str: "Str #{n}"
                                   click: () -> console.log("click="+n)
                                   mouseover: () -> console.log("mouseover="+n)
                                   mouseout: () -> console.log("mouseout="+n)
            )
    draw_venn(4, '#venn4', for n in [0..15]
                               do (n) ->
                                   lbl: "Label #{n}"
                                   str: "#{n}"
                                   click: () -> console.log("click="+n)
                                   mouseover: () -> console.log("mouseover="+n)
                                   mouseout: () -> console.log("mouseout="+n)
            )
