fs        = require 'fs'
{Project} = require '../models'
bundle    = require 'stratus-bundle'

module.exports = (app) ->
  # CREATE project
  # 
  # project - The hash of attributes for a project, such as the name,
  #           isPublic, ect.
  # 
  app.post "/projects", (req, res) ->
    {user} = req
    if !user
      req.flash "error", "You need to be logged in to create a project"
      res.redirect "/"
      return
    
    projectAttrs          = req.param "project"
    projectAttrs.user_id  = user.id
    projectAttrs.isPublic = !!projectAttrs.isPublic
    
    project               = new Project projectAttrs
    project.save (success) ->
      # Redirect to the editor
      if success
        req.flash "success", "Project created!"
        res.redirect "/"
      # Display errors
      else
        req.flash "error", "Something went wrong..."
        res.redirect "/"
  
  
  # Check if the current user already has a project with the given name.
  # Must be signed in!
  # 
  # name - The name of the project.
  # 
  app.get "/projects/unique", (req, res) ->
    {name} = req.query
    query  = {name, user_id: req.user.id}
    
    Project.where query, (projects) ->
      query.unique = !projects.length
      return res.json query
  
  
  # HTML:
  #   Open the editor to the given project.
  app.get "/:username/:project", (req, res, next) ->
    username    = req.param "username"
    projectName = req.param "project"
    
    # Must be the correct user.
    if req.user?.name != username
      req.flash "error", "You are not authorized to access '#{username}/#{projectName}'"
      if req.user
        res.redirect "/"
      else
        res.redirect "/login"
      return
    
    Project.lookup "#{username}/#{projectName}", (project) ->
      return next() unless project
      
      project.list "./", (err, rootFiles) ->
        project.config (err, conf) ->
          project.repo().listR "./", (allFiles) ->
            project.repo().isGit (err, isGit) ->
              bundle.list (err, bundles) ->
                res.render "stratus",
                  layout:  false
                  title:   "#{username}/#{projectName} - Stratus"
                  data:
                    project:
                      path:  "#{username}/#{projectName}"
                      files: rootFiles
                      open:  {}
                      lsR:   allFiles
                      isGit: isGit
                    config: conf
                    bundles: bundles.sort()
          , true
  
