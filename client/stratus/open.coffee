conf         = require './config'
fs           = require './fs'
tabs         = require './ui/tabs'
createEditor = require './fractus'
fractus      = require 'fractus'
{config}     = window.data

BULLET    = "<b>•</b>"
# A map of open file paths to their tabs.
# The paths should _not_ have a leading slash.
openFiles = {}

conf.on "fractus.key.#{config["fractus.save"]}", ->
  fractus.current.save()


# Public: Open a new tab with the given path.
# 
# path - The path to the file to open.
# 
# Returns nothing.
module.exports = open = (path) ->
  $tab = openFiles[path]
  if $tab && $tab.is(":visible")
    return tabs.selectTab $tab
  
  project  = window.data.project.path
  filename = _.last path.split("/")
  fs.read project, path, (file) ->
    $fractus = $ "<div/>"
    $handle  = tabs filename, $fractus
    $handle.attr "title", path
    editor   = createEditor $fractus, file.data, file.language
    
    editor.path     = path
    openFiles[path] = $handle
    editor.save     = -> save(editor)
    conf.emit "stratus.open", path
    
    # When an element is hidden and then shown again, its scrollbar gets
    # reset to 0. This sets it back in place.
    $fractus.on "show", ->
      editor.refresh()
      editor.focus()
      editor.resize()
    
    for event in ["line:change", "line:insert", "line:delete", "reset"]
      editor.buffer.on event, -> unsaved $handle


# Internal: Save the contents of the editor.
# 
# Returns nothing.
save = (editor) ->
  text = editor.text()
  path = editor.path
  fs.write window.data.project.path, path, text, (err) ->
    throw err if err
    saved openFiles[path]
    conf.emit "stratus.save", editor


# Internal: Mark the tab to indicate that there are unsaved changes in the
# file.
# 
# Returns nothing.
unsaved = ($handle) ->
  return if hasChanged $handle
  $label  = $handle.children ".stratus-tab-label"
  oldText = $label.html()
  
  $label.html BULLET + oldText


# Internal: Remove the mark from the tab, to indicate that all changes
# are saved.
# 
# Returns nothing.
saved = ($handle) ->
  return unless hasChanged $handle
  $label = $handle.children ".stratus-tab-label"
  $label.html $label.html().substr(BULLET.length)


# Internal: Check whether or not the tab has the unsaved indicator.
# 
# Returns boolean.
hasChanged = ($handle) ->
  $label  = $handle.children ".stratus-tab-label"
  oldText = $label.html()
  return oldText.substr(0, BULLET.length) == BULLET

