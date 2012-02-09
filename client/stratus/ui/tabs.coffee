# Events:
# 
#   * stratus.ui.tab.move
#   * stratus.ui.tab.order
#   * stratus.ui.tab.close
#   * stratus.ui.tab.select
# 
# The tab markup looks like this:
# 
#   .split-[1|2]
#     nav.stratus-tabs
#       button.stratus-tabs-more
#       .stratus-tab
#         span.stratus-tab-label Label
#         button.stratus-tab-close
#       .stratus-tab
#         span.stratus-tab-label Label
#         button.stratus-tab-close
#     .stratus-tab-contents
#       .stratus-tab-content CONTENT
#       .stratus-tab-content CONTENT
# 
{tabs}          = require 'stratus-ui'
fractus         = require 'fractus'
conf            = require '../config'
tabMarkup       = require('./templates').tab.handle
containerMarkup = require('./templates').tab.container
checkMarkup     = require('./templates').tab.check

for direction in ["tb", "lr"]
  do (direction) ->
    conf.on "stratus.ui.split.#{direction}", ($container) ->
      _.defer ->
        createContainer $container.children(".split-2")


jQuery ->
  createContainer $(".main-panel")
  
  ##
  # Close button.
  $(document).on "click", ".stratus-tab-close", ->
    $tab = $(this).parent()
    if $tab.hasClass "stratus-tab"
      closeTab $tab
  
  $(document).on "mousedown", ".stratus-tab > .stratus-tab-close", ->
    return false
  
  ##
  # Tab.
  $(document).on "mousedown", ".stratus-tab", ->
    selectTab $(this)
  
  ##
  # More.
  $(document).on "click", ".stratus-tabs-more", ->
    revealTabs $(this)
  
  $(document).on "click", ".stratus-more-tabs", ->
    $li = $ this


# A stack of the most recent tabs accessed.
history    = []
# Content id counter.
cIdCounter = 0

# Public: Change the element into a tab container.
# 
# Returns nothing.
createContainer = ($container) ->
  $container.html containerMarkup
  $nav      = $container.children ".stratus-tabs"
  $contents = $container.children ".stratus-tab-contents"
  
  cont      = tabs $container
  
  $nav.sortable
    containment: "document"
    connectWith: ".stratus-tabs"
    distance:    15
    items:       "> .stratus-tab"
    scroll:      false
    tolerance:   "pointer"
    receive: (event, ui) ->
      $nav     = $ this
      $tab     = $ ui.item
      $content = tabContents($tab).detach()
      $nav.parent().children(".stratus-tab-contents").append $content
      selectTab $tab
    remove: (event, ui) ->
      selectTab $(this).find(".stratus-tab:first")
    start: (event, ui) ->
      $tab = ui.item
      $tab.detach().appendTo "body"


# Public: Attach a new tab to the given container.
# 
# Returns the $handle.
module.exports = createTab = (label, content, $container=null) ->
  $container ||= $(".stratus-tabs:first").parent()
  $nav         = $container.children ".stratus-tabs"
  $contents    = $container.children ".stratus-tab-contents"
  cId          = "stratus-cid-#{cIdCounter++}"
  
  # Add the handle.
  $tab         = $(tabMarkup).appendTo $nav
  $label       = $tab.children ".stratus-tab-label"
  $label.text label
  $tab.data "content", cId
  
  # Add the content
  $content = $ content
  $content.attr "id", cId
  $content.addClass "stratus-tab-content"
  $contents.append $content
  
  selectTab $tab
  return $tab


# Internal: Close the tab associated with the given handle.
# 
# Returns false.
closeTab = ($handle) ->
  contentId = $handle.data "content"
  if $handle.hasClass "current"
    while true
      $newCurrent = history.pop()
      break if !$newCurrent
      newContentId = $newCurrent.data "content"
      break if $newCurrent.is(":visible") && newContentId != contentId
    if $newCurrent
      selectTab $newCurrent
    else if ($newCur = $handle.prev(".stratus-tab")).length
      selectTab $newCur
    else if ($newCur = $handle.next(".stratus-tab")).length
      selectTab $newCur
    
  tabContents($handle).remove()
  $handle.remove()
  return false


# Public: Select the given tab handle, showing it's contents.
# 
# Returns nothing.
createTab.selectTab = selectTab = ($handle) ->
  history.push $handle
  
  # Switch current tabs.
  $nav = $handle.parent()
  $old = $nav.children ".current"
  $old.removeClass "current"
  tabContents($old).removeClass "current"
  
  $handle.addClass "current"
  
  # Switch current tab bodies.
  $contents = $handle.closest(".stratus-tabs").next()
  $contents.children(".current").removeClass "current"
  $content  = tabContents $handle
  $content.addClass "current"
  
  $content.trigger "show"

# Internal: Get the tab content corresponding with the tab.
# 
# Returns a jQuery element.
tabContents = ($handle) ->
  contentId = $handle.data "content"
  return $ "##{contentId}"


# Internal: Show a menu of the tabs that dont fit.
# 
# $more - The button to reveal tabs.
# 
# Returns nothing.
revealTabs = ($more) ->
  labels = getHiddenTabs $more.parent()
  return if !Object.keys(labels).length
  
  right = $("body").width() - $more.offset().left - $more.outerWidth()
  top   = $more.offset().top + $more.outerHeight() - 1
  
  # Reuse the menu.
  if !($menu = $(".stratus-more-tabs").show()).length
    $menu = $ "<menu></menu>", class: "menu stratus-more-tabs"
    $menu.appendTo "body"
  
  markup = ""
  for label, $tab of labels
    if $tab.hasClass "current"
      current = checkMarkup
    else
      current = ""
    markup += """
      <li>
        #{current}
        <span class='stratus-more-tab-label'>#{label}</span>
        <button class='stratus-tab-close'>×</button>
      </li>"""
  
  $menu.html markup
  $menu.css {top, right}
  
  # Select the pseudo-tab.
  $menu.on "mousedown", "li", ->
    $tab   = $(this)
    $menu.find(".stratus-more-tab-current").remove()
    $tab.prepend checkMarkup
    $label = $tab.children ".stratus-more-tab-label"
    selectTab labels[$label.text()]
  # Return false to keep the menu from hiding.
  $menu.on "click", "li", -> false
  
  # Close the pseudo-tab.
  $menu.on "click", ".stratus-tab-close", ->
    $tab   = $(this).parent()
    $label = $tab.children ".stratus-more-tab-label"
    closeTab labels[$label.text()]
    $tab.remove()
  $menu.on "mousedown", ".stratus-tab-close", -> false


# Internal: Get the tabs that are overflowing.
# 
# $handleContainer - The `nav.stratus-tabs-more`
# 
# Returns an Object, keyed by the tab handle labels,
# where the values are the jQuery element tab handles.
getHiddenTabs = ($handleContainer) ->
  $nonVisibleTabs = $handleContainer.children(".stratus-tab").filter ->
    $tab = $(this)
    return $tab.position().top > 0
  
  # Get the labels of the hidden tabs.
  labels = {}
  _.each $nonVisibleTabs, (el) ->
    $tab          = $ el
    label         = $tab.children(".stratus-tab-label").text()
    labels[label] = $tab
  return labels

