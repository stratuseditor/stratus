{menu}  = require 'stratus-ui'
conf    = require '../config'
fractus = require 'fractus'
bundle  = require '../bundle'
open    = require '../open'

module.exports = {}
jQuery ($) ->
  tbar = menu.toolbar $("body > .toolbar"),
    File: [
      {text: "New",           click: -> conf.emit("stratus.fs.touch")}
      {text: "New Directory", click: -> conf.emit("stratus.fs.mkdir")}
      {}
      {text: "Open", click: -> conf.emit("stratus.snapopen")}
      {text: "Open Recent", actions: -> recentFiles() }
      {text: "Save", click: -> conf.emit("stratus.save")}
    ]
    Edit: [
      {text: "Search & Replace", click: -> conf.emit("stratus.search")}
      {}
      {text: "Tab Size", actions: [
        {text: "Soft 2", click: -> fractus.current?.tab = "  "}
        {text: "Soft 4", click: -> fractus.current?.tab = "    "}
        {text: "Soft 8", click: -> fractus.current?.tab = "        "}
        {text: "Hard 8", click: -> fractus.current?.tab = "\t"}
      ]}
    ]
    View: [
      {text: "Split top/bottom", click: -> conf.emit("stratus.ui.split.tb.editor")}
      {text: "Split left/right", click: -> conf.emit("stratus.ui.split.lr.editor")}
    ]
    Bundles: selectBundle()
    Tools: []
    Help: [
      {text: "Issue Tracker", href: "https://github.com/stratuseditor/stratus/issues"}
      {text: "Manual",        href: "http://stratuseditor.com/manual"}
      {text: "About",         href: "http://stratuseditor.com/"}
    ]
  
  for k, v of tbar
    module.exports[k] = v


# Internal: Get a list of toolbar items for selecting the bundle.
# 
# Returns an Array of Objects.
selectBundle = ->
  items   = []
  bundles = bundle.list()
  for lang in bundles
    do (lang) ->
      click = ->
        bundle lang, (err, b) ->
          fractus.current?.setSyntax b
      items.push {text: lang, click}
  return items


recent = []
# Internal: Get a list of recent file menu items.
# 
# Return an Array of menu action Objects.
recentFiles = ->
  if (limit = window.data.config["file.recent.limit"]) == 0
    files = recent.slice()
  else
    files = recent.slice 0, limit
  _.map files, (path) ->
    filename = _.last path.split("/")
    do (path) ->
      {text: filename, click: -> open(path) }

# Open recent files
conf.on "stratus.open", (path) ->
  recent.unshift path

