###
Filter a list box of projects, and press enter to open the selected one.


###

{filterbox} = require 'stratus-ui'
newProject  = require './new-project'

LOCK        = "<span class='symbol' title='Private project'>x</span>"

jQuery ($) ->
  {projects, user} = window.data
  return unless projects
  projectNames     = _.map projects, (p) -> p.name
  projectsByName   = {}
  for project in projects
    projectsByName[project.name] = project
  
  # Filter the project list.
  $input = $(".projects .filter > input")
  $list  = $(".projects .filter + ul")
  fbox   = filterbox $input, $list,
    items:  projectNames
    filter: "fuzzy"
    
    select: ($item) ->
      document.location = $item.find("a").attr("href")
    
    cancel: ->
      console.log "Canceled!!!"
    
    itemToHtml: (item) ->
      lock = if projectsByName[item].isPublic then "" else LOCK
      return "<li class='project'>
        <a href='/#{user.name}/#{item}'>#{ user.name }/<b>#{ item }</b>#{lock}</a>
      </li>"
  
  # Give the project filter focus on start.
  fbox.focus()
  
  $(".new-project").on "click", ->
    newProject()
  
  # Display the number of projects.
  $(".project-count").text "(#{ projects?.length })"
