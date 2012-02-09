fs        = require '../../fs'
templates = require('../templates').file_manager

{dialog, validate, keyboard} = require 'stratus-ui'
KEY_SCOPE = "stratus.fs.touch-dialog"
# The current $form.
$CURRENT  = null


# Display a dialog to create a new file.
# 
# projectPath - "dj/stratus", for example.
# tree        - An instance of Tree.
# path        - The parent directory.
# callback    - Called if/when a file is created. Receives
#               `(path, language)`, which is the path and bundle name
#               of the new file.
# 
module.exports = (projectPath, path, callback) ->
  $form     = $CURRENT = $ templates.newFile
  dlg       = dialog "New File", $form, draggable: true
  $fileName = $form.find "input"
  $cancel   = $form.find ".cancel"
  $create   = $form.find ".create"
  
  validation = validate $fileName, ($el, callback) ->
    fileName = $el.val()
    return callback "The file name is required" if !fileName
    return callback "Dont use spaces"    if /\s/.test fileName
    return callback "Watch out for '..'" if /[.]{2}/.test fileName
    return callback []
  
  keyboard.focus $fileName, KEY_SCOPE
  $fileName.focus()
  
  $cancel.on "click", ->
    dlg.close()
  
  $create.on "click", ->
    validation.check (success) ->
      return unless success
      fileName = $fileName.val()
      dlg.close()
      
      fs.touch projectPath, "#{path}/#{fileName}", (data) ->
        return callback "#{path}/#{fileName}", data.language


keyboard KEY_SCOPE,
  "\n":   -> $CURRENT?.find(".create").click()
  Escape: -> $CURRENT?.find(".cancel").click()

