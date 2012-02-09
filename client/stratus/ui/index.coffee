{split}      = require 'stratus-ui'
conf         = require '../config'
toolbar      = require './toolbar'
file_manager = require './file_manager'
snapopen     = require './snapopen'
search       = require './search'
tabs         = require './tabs'

require './split'

module.exports = {toolbar, file_manager, snapopen, search}


jQuery ($) ->
  {config}  = window.data
  treeSide  = config["ui.filetree.side"]
  treeWidth = config["ui.filetree.width"]
  
  if treeSide == "left"
    sp = split.lr $("body > .split"), size1: treeWidth
  else if treeSide == "right"
    $(".file-panel").detach().insertAfter ".main-panel"
    sp = split.lr $("body > .split"), size2: treeWidth
  else
    throw new Error "setting <ui.filetree.side> must be 'left' or 'right'"
  
  sp.on "resize", ->
    conf.emit "stratus.ui.split.resize"
  
  {project} = window.data
  file_manager $(".file-panel > ul"), project.path, project.files
