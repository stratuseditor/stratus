conf     = require '../config'
fractus  = require 'fractus' 
bodyHTML = require('./templates').search
{dialog, keyboard, select} = require 'stratus-ui'

onKey = window.data.config.search
if onKey
  conf.on "fractus.key.#{onKey}", "stratus.search"
conf.on "stratus.search", (edt) ->
  searchDialog (edt || fractus.current)
  return false


config = null
jQuery -> {config} = window.data


# Public: Open a search dialog for the given editor.
# 
# editor - An insance of Editor (definded in _fractus/index.coffee_).
# 
# Returns a Dialog.
module.exports = searchDialog = (editor) ->
  dlg = new SearchDialog editor
  conf.on "fractus.focus", (edt) ->
    dlg.editor = edt
  return dlg


# Internal: A list of the past search terms.
searchDialog.searchHistory  = searchHistory  = []

# Internal: A list of the past replacement terms.
searchDialog.replaceHistory = replaceHistory = []


# Internal: Add a term to the history.
addToSearchHistory  = (term) ->
  match = term.source || term
  unless _.last(searchHistory) == match
    searchHistory.push match
addToReplaceHistory = (term) ->
  match = term.source || term
  unless _.last(replaceHistory) == match
    replaceHistory.push match


# Configurations used:
# 
#   * search.regex : Boolean
#   * search.ignorecase : Boolean
#   * search.reverse : Boolean (TODO)
# 
class SearchDialog
  constructor: (@editor) ->
    $body = $ bodyHTML
    @dlg  = dialog "Search & Replace", $body, {draggable: true}
    @dlg.on "close", => @clearHighlights()
    
    @$search     = $body.find("input.stratus-search").focus()
    @$replace    = $body.find "input.stratus-replace"
    @$regex      = $body.find ".stratus-search-regex > input"
    @$ignorecase = $body.find ".stratus-search-ignorecase > input"
    @$reverse    = $body.find ".stratus-search-reverse > input"
    @$findOne    = $body.find "button.stratus-find"
    @$findAll    = $body.find "button.stratus-find-all"
    @$replaceOne = $body.find "button.stratus-replace"
    @$replaceAll = $body.find "button.stratus-replace-all"
    @$count      = $body.find ".stratus-search-message"
    
    @$searchHistory  = $body.find ".stratus-search-history"
    @$replaceHistory = $body.find ".stratus-replace-history"
    
    @searchSelect    = select.toggle @$searchHistory, (value) =>
      @$search.val value
    , {width: @$search.outerWidth() + @$searchHistory.outerWidth()
    ,  items: searchHistory}
    
    @replaceSelect   = select.toggle @$replaceHistory, (value) =>
      @$replace.val value
    , {width: @$replace.outerWidth() + @$replaceHistory.outerWidth()
    ,  items: replaceHistory}
    
    @_config()
    
    # Set the values of search/replace from the most recent.
    if text = _.last searchHistory
      @$search.val text
      @$search[0].select()
    if text = _.last replaceHistory
      @$replace.val text
    
    @$findOne.click => @_findOne()
    @$findAll.click => @_findAll()
    # Find One on enter.
    @$search.keydown (event) =>
      {which} = event
      if keyboard.keyMap[which] == "\n"
        @_findOne()
      else if keyboard.keyMap[which] == "Escape"
        @close()
      return
    
    
    @$replaceOne.click => @_replaceOne()
    @$replaceAll.click => @_replaceAll()
    # Replace One on enter.
    @$replace.keydown (event) =>
      {which} = event
      if keyboard.keyMap[which] == "\n"
        @_replaceOne()
      else if keyboard.keyMap[which] == "Escape"
        @close()
      else
        return
    
  
  
  # Internal: Apply the configuration settings.
  _config: ->
    @$regex.attr      "checked", config["search.regex"]
    @$ignorecase.attr "checked", config["search.ignorecase"]
  
  # Internal: Get the search options.
  # 
  # Returns Object.
  options: ->
    regex:      @$regex.is(":checked")
    ignorecase: @$ignorecase.is(":checked")
    reverse:    @$reverse.is(":checked")
  
  # Internal: Set the message with the given text or HTML.
  # 
  # html - String. Child `<span>` tags will be bolded.
  # 
  # Returns nothing.
  notify: (html) ->
    @$count.html(html).addClass "show"
  
  # Internal: Indicate the number of results.
  resultCount: (i) ->
    if i == 0
      message = "<span class='error'>No matches</span>"
    else if i == 1
      message = "<span class='num'>1</span> match"
    else
      message = "<span class='num'>#{i}</span> matches"
    @notify message
  
  # Internal: Get the search term.
  # 
  # Returns String or RegExp.
  term: ->
    {regex, ignorecase} = @options()
    match               = @$search.val()
    addToSearchHistory match if match
    if regex
      try
        if ignorecase
          match = new RegExp match, "i"
        else
          match = new RegExp match
      catch err
        @notify "<span class='error'>Invalid regular expression</span>"
        return
    else if ignorecase
      re = _.map match.split(""), (s) ->
        if s in ["]", "^", "\\"]
          "\\#{s}"
        else if s == "-"
          "-"
        else
          "[#{s}]"
      match = new RegExp re.join(""), "i"
    return match
  
  # Internal: Get the replacement term.
  # 
  # Returns String.
  replaceTerm: ->
    match = @$replace.val()
    addToReplaceHistory match if match
    return match
  
  # Internal: Highlight the next search result.
  _findOne: ->
    @clearHighlights()
    return unless t = @term()
    @resultCount findOne(@editor, t, true)
  
  # Internal: Highlight all results.
  _findAll: ->
    @clearHighlights()
    return unless t = @term()
    @resultCount findAll(@editor, t, true)
  
  # Internal: Replace once.
  _replaceOne: ->
    @clearHighlights()
    return unless t = @term()
    r = @replaceTerm()
    @resultCount replaceOne(@editor, t, r)
  
  # Internal: Replace all.
  _replaceAll: ->
    @clearHighlights()
    return unless t = @term()
    r = @replaceTerm()
    @resultCount replaceAll(@editor, t, r)
  
  # Public: Remove all result highlightings.
  # 
  # Returns nothing.
  clearHighlights: ->
    clear @editor
  
  # Public: Close the search dialog.
  close: ->
    @dlg.close()
    @editor.focus()


# Public: Find and highlight the next occurance of the given term.
# 
# edt     - An Editor.
# term    - The String or RegExp to search for.
# 
# Returns the number of results found (1 or 0).
searchDialog.findOne = findOne = (edt, term, moveTo=false) ->
  return 0 unless term
  
  edt.cursor.toPoint()
  {row, col} = edt.cursor.point
  region = edt.buffer.search term, row, col + 1
  # Highlight the result.
  if region
    highlight edt, region
    edt.cursor.moveTo region.end if moveTo
  # No result: wrap around.
  else if row != 0 && col != 0
    region = edt.buffer.search term, 0, 0
    return 0 unless region
    highlight edt, region
    edt.cursor.moveTo region.end if moveTo
  return 1


# Public: Find and highlight all occurences of the search term.
# 
# TODO: Buffer this so that only the visible portion of the text is
# searched.
# 
# edt     - An Editor.
# term    - The String or RegExp to search for.
# 
# Returns the number of results.
searchDialog.findAll = findAll = (edt, term, moveTo=false) ->
  return 0 unless term
  regions = edt.buffer.searchAll term
  
  for region in regions
    highlight edt, region
  
  if moveTo && regions.length
    edt.cursor.moveTo regions[0].begin
  return regions.length


# Public: Find and replace one occurence of the search term with the
# replacement term.
# 
# edt         - An Editor
# term        - The String or RegExp to replace.
# replaceTerm - The String to replace with.
# 
# Returns the number of replacements (1 or 0).
searchDialog.replaceOne = replaceOne = (edt, term, replaceTerm) ->
  return 0 unless term
  edt.cursor.toPoint()
  {row, col} = edt.cursor.point
  region     = edt.buffer.replace term, replaceTerm, row, col + 1
  
  # Highlight the result.
  if region
    edt.cursor.select region
  # No result: wrap around.
  else if row != 0 && col != 0
    region = edt.buffer.replace term, replaceTerm, 0, 0
    return 0 unless region
    edt.cursor.select region
  return 1


# Public: Find and replace all occurences of the search term with the
# replacement term.
# 
# edt         - An Editor.
# term        - The String or RegExp to replace.
# replaceTerm - The String to replace with.
# 
# Returns the number of replacements.
searchDialog.replaceAll = replaceAll = (edt, term, replaceTerm) ->
  return 0 unless term
  replacementCount = edt.buffer.replaceAll term, replaceTerm
  return replacementCount


# Public: Visually mark the region as a search result.
# 
# Returns nothing.
searchDialog.highlight = highlight = (editor, region) ->
  coords = editor.layout.regionToCoords region
  $("<div></div>", class: "hi-search")
    .appendTo(editor.view.$scrollView)
    .css(coords)

# Public: Un-highlight all search results within the editor.
# 
# editor - An Editor.
# 
searchDialog.clear = clear = (editor) ->
  editor.view.$scrollView.children(".hi-search").remove()


