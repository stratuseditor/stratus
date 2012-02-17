_         = require 'underscore'
{Project} = require '../models'

COMMITS_PER_PAGE = 35

module.exports = (app) ->
  app.get "/:username/:project/commits/:treeish.json", (req, res) ->
    username    = req.param "username"
    projectName = req.param "project"
    treeish     = req.param "treeish"
    
    skip        = req.param "skip"
    page        = req.param "page"
    skip        = page * COMMITS_PER_PAGE if page
    skip       ?= 0
    
    # Must be the correct user.
    if req.user?.name != username
      res.send 401
      return
    
    Project.lookup "#{username}/#{projectName}", (project) ->
      return next() unless project
      
      project.repo().git().commits treeish, COMMITS_PER_PAGE, skip
      , (err, commits) ->
        return res.send err if err
        commits = _.map commits, ((c) -> c.toJSON())
        res.json commits
  
  
  app.get "/:username/:project/commit/:sha.json", (req, res) ->
    username    = req.param "username"
    projectName = req.param "project"
    sha         = req.param "sha"
    
    # Must be the correct user.
    if req.user?.name != username
      res.send 401
      return
    
    Project.lookup "#{username}/#{projectName}", (project) ->
      gitRepo = project.repo().git()
      gitRepo.commits sha, 2, (err, commits) ->
        gitRepo.diff commits[1], commits[0], (err, diffs) ->
          commit = commits[0]
          _.map (d) -> d.toJSON()
          json   = _.extend commit.toJSON(), {diffs}
          res.json json
