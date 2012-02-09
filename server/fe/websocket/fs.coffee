###
Use socket.io to give the client access file system operations on the repo.

TODO: handle permissions
###
bundle    = require 'stratus-bundle'
{Project} = require '../models'
{getUser} = require './helpers'


# callback - Receives (user, project, repo)
setup = (socket, data, callback) ->
  getUser socket, (err, user) ->
    Project.lookup data.project, (project) ->
      return callback user, project, project.repo()

module.exports = (io, sessionStore) ->
  fsIo = io.of("/fs").on "connection",
  (socket) ->
    
    basicActions = [
      "delete"
      "exists"
      "mkdir"
      "isDirectory"
    ]
    for event in basicActions
      do (event) ->
        socket.on event, (data, callback) ->
          setup socket, data, (user, project, repo) ->
            repo[event] data.path, callback
    
    socket.on "touch", (data, callback) ->
      setup socket, data, (user, project, repo) ->
        repo.touch data.path, ->
          bundle.identify data.path, (err, language) ->
            callback {language}
    
    
    socket.on "list", (data, callback) ->
      setup socket, data, (user, project, repo) ->
        project.list data.path, (err, files) ->
          return callback files, err
    
    socket.on "read", (data, callback) ->
      setup socket, data, (user, project, repo) ->
        project.read data.path, (err, file) ->
          return callback file, err
    
    socket.on "write", (data, callback) ->
      setup socket, data, (user, project, repo) ->
        repo.write data.path, data.data, (err) ->
          return callback err
    
    socket.on "move", (data, callback) ->
      setup socket, data, (user, project, repo) ->
        repo.move data.fromPath, data.toPath, (err) ->
          bundle.identify data.toPath, (__, language) ->
            callback err, {language}
    
    socket.on "copy", (data, callback) ->
      setup socket, data, (user, project, repo) ->
        repo.copy data.fromPath, data.toPath, (err) ->
          bundle.identify data.toPath, (__, language) ->
            callback err, {language}
    
