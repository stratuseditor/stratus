_         = require 'underscore'
{Project} = require '../models'

COMMITS_PER_PAGE = 35

# callback - Receives `(stop, project, gitRepo)`
setup = (req, res, next, callback) ->
  username    = req.param "username"
  projectName = req.param "project"
  # Must be the correct user.
  if req.user?.name != username
    res.send 401
    return callback true
  
  Project.lookup "#{username}/#{projectName}", (project) ->
    if !project
      next()
      return callback true
    
    return callback false, project, project.repo().git()
  

module.exports = (app) ->
  app.get "/:username/:project/commits/:treeish.json", (req, res, next) ->
    setup req, res, next, (stop, project, gitRepo) ->
      return if stop
      treeish = req.param "treeish"
      skip    = req.param "skip"
      page    = req.param "page"
      skip    = page * COMMITS_PER_PAGE if page
      skip   ?= 0
      
      gitRepo.commits treeish, COMMITS_PER_PAGE, skip
      , (err, commits) ->
        return res.send err if err
        commits = _.map commits, ((c) -> c.toJSON())
        res.json commits
  
  
  app.get "/:username/:project/commit/:sha.json", (req, res, next) ->
    setup req, res, next, (stop, project, gitRepo) ->
      return if stop
      sha = req.param "sha"
      
      gitRepo.commits sha, 2, (err, commits) ->
        gitRepo.diff commits[1], commits[0], (err, diffs) ->
          commit = commits[0]
          _.map (d) -> d.toJSON()
          json   = _.extend commit.toJSON(), {diffs}
          res.json json
  
  
  # Get the data that is to be committed.
  app.get "/:username/:project/commit", (req, res, next) ->
    setup req, res, next, (stop, project, gitRepo) ->
      return if stop
      
      gitRepo.diff "HEAD", "", (err, diffs) ->
        gitRepo.status (err, status) ->
          _.map (d) -> d.toJSON()
          json = {status: status.files, diffs}
          res.json json
  
  # Commit code.
  app.post "/:username/:project/commit", (req, res, next) ->
    setup req, res, next, (stop, project, gitRepo) ->
      return if stop
      {files, amend, message} = req.param "commit"
      gitRepo.add files, (err) ->
        return res.json {err} if err
        gitRepo.commit message, {amend: !!amend}, (err) ->
          res.json {err}
  
  # List the branches.
  app.get "/:username/:project/branches.json", (req, res, next) ->
    setup req, res, next, (stop, project, gitRepo) ->
      return if stop
      gitRepo.branches (err, heads) ->
        gitRepo.remotes (err, remotes) ->
          return res.send {err} if err
          gitRepo.branch (err, current) ->
            return res.send {err} if err
            branches = {}
            for head in heads
              delete head.repo
              head.published      = false
              branches[head.name] = head
              if head.name == current.name
                head.current = true
                break
            for remote in remotes
              continue if remote.name == "origin/HEAD"
              delete remote.repo
              remote.name = name = remote.name.replace /^origin\//, ""
              if !branches[name]
                remote.ref     = "origin/#{remote.name}"
                branches[name] = remote
              branches[name].published = true
            
            res.json _.values(branches)
