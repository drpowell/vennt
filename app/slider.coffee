# ------------------------------------------------------------
# Slider routines
class Slider
    constructor: (elem, text, @steps, callback) ->
        @slider = $(elem).slider({
          animate: true,
          min: 0,
          max: @steps.length-1,
          value: 1,
          slide: (event, ui) =>
            v = @steps[ui.value]
            $(text).val(v)
            callback(v)
        })

    # Set the slider to the nearest entry
    set_slider: (v) ->
      set_i=0
      $.each(@steps, (i,v2) ->
        if (v2<=v)
          set_i = i
      )
      @slider.slider("value", set_i)

window.Slider = Slider
