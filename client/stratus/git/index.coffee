return unless window.data.project.git
ui       = require '../ui'
commit   = require './commit'
history  = require './history'
branches = require './branches'

jQuery ($) ->
  ui.toolbar.Tools.append
    text: "Git"
    actions: [
      {text: "Branches", click: -> branches() }
      {text: "History",  click: -> history() }
      {text: "Changes",  click: -> commit() }
    ]
