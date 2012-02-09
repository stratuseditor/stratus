###
TODO: These should be served by `express.static` or a CDN.

###

express    = require 'express'
fs         = require 'fs'
bundle     = require 'stratus-bundle'
{Project}  = require '../models'
extensions = require '../models/extensions'

module.exports = (app) ->
  # STATIC
  app.get "/bundles/:language/icon.png", (req, res) ->
    language = req.param "language"
    fs.readFile "#{bundle.dir}/#{language}/icon.png", (err, data) ->
      return res.send err if err
      res.writeHead 200, {"Content-Type": express.static.mime.types.png}
      res.end data, "binary"
  
  # STATIC (well, cacheable at least...)
  app.get "/bundles/:language.json", (req, res) ->
    language = req.param "language"
    bundle(language).toJSON (json) ->
      res.json json
  
  # Fetch the user's JS plugins.
  app.get "/plugins.:format", (req, res) ->
    {user} = req
    if !user
      return res.send 403
    
    {format} = req.params
    Project.where {user_id: user.id, name: ".stratus"}, (projects) ->
      project = projects[0]
      res.contentType "file.#{format}"
      if !project
        res.send '/*no ".stratus" project*/'
      else if format == "js"
        extensions(project.path).js (err, jsCode) ->
          throw err if err
          res.send jsCode
      else if format == "css"
        extensions(project.path).css (err, cssCode) ->
          throw err if err
          res.send cssCode
      else
        res.send 404
