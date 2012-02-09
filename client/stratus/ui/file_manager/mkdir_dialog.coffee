fs                 = require '../../fs'
templates          = require('../templates').file_manager

{dialog, validate, keyboard} = require 'stratus-ui'
KEY_SCOPE = "stratus.fs.mkdir-dialog"
# The current $form.
$CURRENT  = null

# Display a dialog to create a new file.
# 
# projectPath - "dj/stratus", for example.
# tree        - An instance of Tree.
# path        - The parent directory.
# callback    - Called if/when a file is created. Receives
#               `(path)`, which is the path of the new file.
# 
module.exports = (projectPath, path, callback) ->
  $form      = $CURRENT = $ templates.newDir
  dlg        = dialog "New Directory", $form, draggable: true
  $fileName  = $form.find "input"
  validation = validate $fileName, ($el, callback) ->
    fileName = $el.val()
    return callback "The directory name is required" if !fileName
    return callback "Dont use spaces"    if /\s/.test fileName
    return callback "Watch out for '..'" if /[.]{2}/.test fileName
    return callback []
  
  keyboard.focus $fileName, KEY_SCOPE
  $fileName.focus()
  
  $form.find(".cancel").on "click", ->
    dlg.close()
  
  $form.find(".create").on "click", ->
    validation.check (success) ->
      return unless success
      fileName = $fileName.val()
      dlg.close()
      
      fs.mkdir projectPath, "#{path}/#{fileName}", (data) ->
        return callback "#{path}/#{fileName}"


keyboard KEY_SCOPE,
  "\n":   -> $CURRENT?.find(".create").click()
  Escape: -> $CURRENT?.find(".cancel").click()


