###
The new project bubble.

TODO: make sure they dont already have a project named X.

###
{tabs, validate, dialog} = require 'stratus-ui'
templates       = require './templates'
validateProject = require('../../shared/validate').project

# Check if the user has a project named `name`.
# 
# name     - The name of the project
# callback - A function which receives `(isUnique, name)`.
# 
unique = (name, callback) ->
  $.getJSON "/projects/unique", {name},
  (data, status, xhr) ->
    callback data.unique, data.name

jQuery ($) ->
  $newProject = $ ".new-project.bubble"
  
  tabs $newProject.children(".tabs")
  
  # Cancel the project creation.
  $newProject.find("button:contains('Cancel')").on "click", ->
    ProjectSlider.open()
    return false
  
  validate.form $newProject.find(".project-type-standard, .project-type-git"),
    "[name='project\\[name\\]']": ($el, callback) ->
      name   = $el.val()
      errors = validateProject({name}).name || []
      return callback errors if errors.length
      
      unique name, (isUnique, pName) ->
        if isUnique
          return callback []
        else
          return callback "You already have a project named '#{ pName }'"

# Show the new project bubble.
module.exports = ->
  ProjectSlider.new()


class BubbleSlider
  @slideUp: ($bubble) ->
    $bubble.css left: "-150%"
  
  @slideIn: ($bubble) ->
    $bubble.css left: "50%"
  
  @slideDown: ($bubble) ->
    $bubble.css left: "150%"


class ProjectSlider extends BubbleSlider
  @open: ->
    @slideDown $ ".new-project.bubble"
    @slideIn $ ".projects"
  
  @new: ->
    @slideIn $ ".new-project.bubble"
    @slideUp $ ".projects"
