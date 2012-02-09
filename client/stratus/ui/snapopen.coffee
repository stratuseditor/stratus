# Snap open is a Textmate-style fuzzy file opener.
##

conf   = require '../config'
markup = require('./templates').snapopen
open   = require '../open'

{dialog, filterbox} = require 'stratus-ui'

module.exports = snapopen = ->
  return new SnapOpen()

onKey = window.data.config["snapopen"]
if onKey
  conf.on "key.#{onKey}", ->
    snapopen()
    return false


allFiles = []
config = null
jQuery ->
  allFiles = window.data.project.lsR
  {config} = window.data


# Internal: The snap open dialog.
# 
# Config options:
# 
#   * snapopen.limit : Integer
# 
class SnapOpen
  constructor: ->
    $body   = $ markup
    @$input = $body.children "input"
    @$list  = $body.children "ul"
    
    filterbox @$input, @$list,
      items:      allFiles
      select:     ($item, event) => @openItem($item, event)
      cancel:     => @close()
      filter:     "fuzzy"
      empty:      true
      wrap:       true
      itemToHtml: (item) ->
        dir   = item[0]
        dir &&= dir + "/"
        "<li><h1>#{item[1]}</h1><h2>/#{dir}</h2></li>"
      filterOpts:
        pre:        "<b>"
        post:       "</b>"
        limit:      config["snapopen.limit"]
        separator:  "/"
        separate:   true
        ignorecase: config["snapopen.ignorecase"]
    
    @dlg = dialog "Snap Open", $body
    
    # For some reason the scope gets set to global instead of the filterbox
    # scope unless I focus twice....
    @$input.focus()
    @$input.focus()
  
  
  # Internal: Hide the dialog.
  # 
  # Returns nothing.
  close: ->
    @dlg.close()
  
  # Internal: Open the file corresponding to the list item.
  # 
  # Returns nothing.
  openItem: ($item, event) ->
    path = $item.children("h2").text().substr(1) + $item.children("h1").text()
    open path
    @close() unless event?.ctrlKey

