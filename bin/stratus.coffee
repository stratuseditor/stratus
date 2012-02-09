srv = "server"
try
  require.resolve "../server/fe"
catch e
  srv = "lib"

process.env.NODE_ENV ||= "development"

commander = require 'commander'
Project   = require "../#{srv}/fe/models/project"
path      = require 'path'

commander
  .version('0.0.1')
  .option('-l, --local',       'Restrict access to Stratus from localhost')
  .option('-P, --pass <pass>', 'Authenticate with http basic auth stratus:<pass>')


commander
  .command('start [port]')
  .description('  start the Stratus server')
  .action (port) ->
    options          = {}
    options.host     = "127.0.0.1"    if commander.local
    options.password = commander.pass if commander.pass
    options.port     = +port          if port
    
    fe = require("../#{srv}/fe") options


commander
  .command('link <user/project> <path>')
  .description('  point a project path to somewhere on the file system')
  .action (projectName, projectPath) ->
    Project.lookup projectName, (project) ->
      exists = projectPath && path.existsSync projectPath
      if project && exists
        project.path = projectPath
        project.save (success) ->
          console.log "Something went wrong:", project.errors if !success
          process.exit()
      else
        console.log ""
        console.log "  * No project at '#{ projectName }'"   unless project
        console.log "  * No directory at '#{ projectPath }'" unless exists
        console.log """
          
            Usage:
              
              stratus link username/projectname /path/to/project
          
          """
        process.exit()


commander
  .command('show <user/project>')
  .description('  print the path to the project')
  .action (projectName) ->
    Project.lookup projectName, (project) ->
      console.log ""
      if project
        console.log "#{project.path}"
      else
        console.log "  * No project at '#{ projectName }'" unless project
      console.log ""
      process.exit()


commander
  .command('plugin:install <username> <path>')
  .description('  install the plugin at `path`')
  .action (username, pluginPath) ->
    extensions = require "../#{srv}/fe/models/extensions"
    Project.lookup "#{username}/.stratus", (project) ->
      pluginRepo = extensions project.path
      pluginRepo.install pluginPath, (err) ->
        throw err if err
        console.log "\n  * Plugin successfully installed.\n"
        process.exit()

commander.parse process.argv

