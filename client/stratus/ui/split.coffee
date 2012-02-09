# Events used/defined in this file:
# 
#   * stratus.ui.split.resize - Called whenever a split is resized.
#   * stratus.ui.split.lr     - Split the given editor parameter, or
#       the current editor. (left/right)
#   * stratus.ui.split.tb     - Split the given editor parameter, or
#       the current editor. (top/bottom)
# 

{split} = require 'stratus-ui'
conf    = require '../config'
fractus = require 'fractus'

markup  = require('./templates').split

# Public: Split the editor.
# 
# $container - The element to split.
# type       - Either "tb" or "lr" (for top/bottom or left/right).
# 
# Returns the Split.
module.exports = splitEditor = ($container, type) ->
  $container.addClass "split"
  $container.html markup
  
  sp = split[type] $container
  sp.on "resize", -> conf.emit("stratus.ui.split.resize")
  return sp


jQuery ($) ->
  $(window).resize ->
    conf.emit "stratus.ui.split.resize"


for direction in ["tb", "lr"]
  do (direction) ->
    conf.on "stratus.ui.split.#{direction}", ($container) ->
      $children = $container.children().detach()
      sp        = splitEditor $container, direction, fractus.current
      sp.$pane1.append $children
    
    conf.on "stratus.ui.split.#{direction}.editor", (editor) ->
      editor   ||= fractus.current
      $container = edtToContainer editor
      conf.emit "stratus.ui.split.#{direction}", $container
      _.defer   -> editor?.resize()


# Internal: Get the container element of the editor.
# 
# edt - An Editor.
# 
# Returns a jQuery element.
edtToContainer = (edt) ->
  return $(".main-panel") unless edt
  {$el} = edt.view
  console.log $el.closest(".split-1, .split-2")
  return $el.closest(".split-1, .split-2")
