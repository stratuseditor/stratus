jQuery ($) ->
  
  # Close flash messages on click
  $("body > .flash").on "click", ->
    $flash = $(this)
    $flash.animate "margin-top": -200, 100, ->
      $flash.remove()
