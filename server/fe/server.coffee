###
Return an app, which is the front end server.

    app = require("fe/server")(some options)

Acceptable options include:

host     - "0.0.0.0" by default, for public. For local-only,
           set to "127.0.0.1".
listen   - Defaults to `true`, but if `false` the server will
           not be started.
password - If given, HTTP Basic Authentication will be used.
           The password will be the password given, and the username is
           "stratus" (all lower-case).
port     - [8134]

###
Path         = require 'path'
express      = require 'express'
io           = require 'socket.io'
stylus       = require 'stylus'
nib          = require 'nib'
browserify   = require 'browserify'
fractus      = require 'fractus'
controllers  = require './controllers'
websocket    = require './websocket'
helpers      = require './helpers'
{NODE_ENV}   = process.env
NODE_ENV   ||= "test"
sessionStore = new (express.session.MemoryStore)()

# Set up the browserify client bundle for the site.
bundle = browserify
  watch: true
bundle.addEntry "#{__dirname}/../../client/site-main.coffee"

# Set up the browserify client bundle for Stratus Editor.
bundleStratus = browserify
  watch: true
  mount: "/stratus-browserify.js"
bundleStratus.addEntry "#{__dirname}/../../client/stratus-main.coffee"

STATIC_DIR = "#{ __dirname }/../../public/"


module.exports = (options = {}) ->
  host     = options.host     || undefined
  listen   = true unless options.listen?
  password = options.password || false
  port     = options.port     || 8134
  
  app      = express.createServer()
  if listen
    io = io.listen app
    # TODO: XXX
    if password
      io.configure ->
        io.set 'transports', ['xhr-polling', 'websocket']
    # XXX
  
  # Configuration.
  app.configure ->
    @set "views", "#{__dirname}/../../views"
    @set "view engine", "jade"
    @set "view options",
      title: "Stratus Editor"
      data:  {}
    
    @use express.bodyParser()
    @use express.methodOverride()
    @use express.cookieParser()
    @use express.session
      secret: "im not wearing pants"
      key:    "express.sid"
      store:  sessionStore
    
    # HTTP Basic Authentication
    @use express.basicAuth "stratus", password if password
    
    # Stylus
    @use stylus.middleware
      compile: compileStylus
      src:     STATIC_DIR
    
    # CoffeeScript
    @use express.compiler
      enable: ["coffeescript"]
      src:    STATIC_DIR
    
    # Browserify bundle
    @use bundle
    @use bundleStratus
    
    # Static files
    @use express.static STATIC_DIR
    
    require('./controllers/auth') app
    
    # Routing
    @use app.router
  
  
  # Environments
  app.configure "development", ->
    @use express.errorHandler
      dumpExceptions: true
      showStack:      true
  
  app.configure "production", ->
    @use express.errorHandler()
  
  
  # Helpers
  helpers app
  
  # Routing
  controllers app, options
  websocket io, sessionStore if listen
  
  # 404 route
  app.get "*", (req, res) ->
    res.render "404", status: 404
  
  if listen
    app.listen port, host
    host_s = host || "0.0.0.0"
    
    if NODE_ENV != "test"
      console.log " * Stratus is listening at http://#{ host_s }:#{ port }/"
  
  return app


stratusUI = Path.dirname(require.resolve("stratus-ui")) + "/css"

compileStylus = (str, path) ->
  return stylus(str)
    .set("filename", path)
    .include(nib.path)
    .include(stratusUI)
    .include(fractus.path)
