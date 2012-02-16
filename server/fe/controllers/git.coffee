_         = require 'underscore'
{Project} = require '../models'

module.exports = (app) ->
  app.get "/:username/:project/commits/:treeish.json", (req, res) ->
    username    = req.param "username"
    projectName = req.param "project"
    treeish     = req.param "treeish"
    skip        = req.param("skip") || 0
    
    # Must be the correct user.
    if req.user?.name != username
      res.send 401
      return
    
    Project.lookup "#{username}/#{projectName}", (project) ->
      return next() unless project
      
      project.repo().git().commits treeish, 35, skip, (err, commits) ->
        return res.send err if err
        commits = _.map commits, ((c) -> c.toJSON())
        res.json commits
