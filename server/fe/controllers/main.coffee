_         = require 'underscore'
{Project} = require '../models'

module.exports = (app) ->
  app.get "/", (req, res) ->
    {user} = req
    return res.render "index" if !user
    
    Project.where user_id: user.id, (projects) ->
      projectData = _.map projects, (project) ->
        name:     project.name
        isPublic: project.isPublic
      res.render "index",
        data:
          projects: _.sortBy(projectData, (p) -> p.name)
          user:     {name: user.name}
