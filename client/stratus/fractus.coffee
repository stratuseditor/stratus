###
A simple Fractus wrapper.

Events:

  * fractus.key.* - Key presses within the scope of an editor.
  * fractus.cursor.move - (editor)

###

fractus = require 'fractus'
bundle  = require './bundle'
conf    = require './config'

{keyboard}   = require 'stratus-ui'
coordsMarkup = require('./ui/templates').coords

config = null
jQuery -> {config} = window.data


keyboard "global", (k) ->
  event = "key.#{k}"
  if !conf.isset(event)
    return true
  else
    conf.emit event
    return false


mode = (edt, key) ->
  event = "fractus.key.#{key}"
  
  if conf.isset "fractus.key.#{key}"
    conf.emit event, edt
    conf.emit "fractus.key", {edt, key}
    return false
  else
    conf.emit "fractus.key", {edt, key}
    action = fractus.InsertMode[key]
    if action
      action edt
      return false
    else
      v = fractus.InsertMode.otherwise edt, key
    return v


module.exports = ($el, text, syntax) ->
  edt = fractus $el, {text, mode}
  bundle syntax, (err, lang) ->
    edt.setSyntax lang
    edt.tab = config["fractus.tab@#{syntax}"] || lang.tab || "    "
  
  conf.on "stratus.ui.split.resize", ->
    edt.resize()
  
  # Reset the coords.
  setCoords 0, 0
  edt.cursor.on "move", ->
    conf.emit "fractus.cursor.move", edt
    if edt.cursor.region
      row = edt.cursor.region.end.row
      col = edt.cursor.region.end.col
    else
      row = edt.cursor.point.row
      col = edt.cursor.point.col
    setCoords row, col
  
  edt.on "focus", -> conf.emit("fractus.focus", edt)
  edt.on "blur",  -> conf.emit("fractus.blur", edt)
  
  return edt


$coords    = null
$coordsRow = null
$coordsCol = null

# Internal: Set the `(row, column)` indicator.
# 
# The row and column arguments are 0-based, but will be displayed as 1-based.
# 
# row - The 0-based index of the current row.
# col - The 0-based index of the current column.
# 
# Returns nothing.
setCoords = (row, col) ->
  if !$coords
    $coords    = $(coordsMarkup).appendTo "body"
    $coordsRow = $coords.children ".stratus-cursor-row"
    $coordsCol = $coords.children ".stratus-cursor-col"
  
  $coordsRow.text row + 1
  $coordsCol.text col + 1
  return


# Make sure that the font gets downloaded so that the initial font
# dimension calculations & measurements are accurate.
# 
# Without this, the initial font measurement will use the default
# monospace font...
jQuery ($) ->
  fontFamily = config["fractus.font.monospace.family"]
  fontSize   = config["fractus.font.monospace.size"]
  $("body").append "<span style='font-family: #{fontFamily};'>X</span>"
  $("head").append """
      <style>
        .fractus {
          font-family: #{fontFamily};
          font-size: #{fontSize}px;
        }
        .fractus-gutter > span::before {
          font-size: #{fontSize}px;
        }
      </style>
    """
