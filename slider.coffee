# ------------------------------------------------------------
# Slider routines
resStepValues = [0, 1e-5, 0.0001, 0.001, .01, .02, .03, .04, .05, 0.1, 1]

class Slider
    constructor: (elem, text, callback) ->
        @slider = $(elem).slider({
          animate: true,
          min: 0,
          max: resStepValues.length-1,
          value: 1,
          slide: (event, ui) ->
            v = resStepValues[ui.value]
            $(text).val(v)
            callback(v)
        })

    # Set the slider to the nearest entry
    set_slider: (v) ->
      set_i=0
      $.each(resStepValues, (i,v2) ->
        if (v2<=v)
          set_i = i
      )
      @slider.slider("value", set_i)

window.Slider = Slider
