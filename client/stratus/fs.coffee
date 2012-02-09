###
Perform file system operations on the project.

Examples

  {fs} = require 'stratus'
  fs.delete ":user/:project", "some/file.js", (err) ->
  fs.move ":user/:project", "from/file.js", "to/another.js", (err) ->
  fs.copy ":user/:project", "from/file.js", "to/another.js", (err) ->
  fs.exists ":user/:project", "some/file.js", (err) ->
  fs.mkdir ":user/:project", "some/dir", (err) ->
  
  fs.list ":user/:project", "some/dir", (files, err) ->
    for file in files
      console.log "#{file.name} : #{file.language}"
  
  fs.isDirectory ":user/:project", "some/thing", (bool, err) ->
  fs.touch ":user/:project", "some/file.js", (err) ->
  fs.read ":user/:project", "some/file.js", ({data, language}) ->
  fs.write ":user/:project", "some/file.js", "bla bla data bla", (err) ->

###
fsIo = window.io.connect "http://#{ document.location.host }/fs"


module.exports = window.fs =
  delete: (project, path, callback) ->
    fsIo.emit "delete", {project, path}, callback
  
  move: (project, fromPath, toPath, callback) ->
    fsIo.emit "move", {project, fromPath, toPath}, callback
  
  copy: (project, fromPath, toPath, callback) ->
    fsIo.emit "copy", {project, fromPath, toPath}, callback
  
  exists: (project, path, callback) ->
    fsIo.emit "exists", {project, path}, callback
  
  mkdir: (project, path, callback) ->
    fsIo.emit "mkdir", {project, path}, callback
  
  list: (project, path, callback) ->
    fsIo.emit "list", {project, path}, callback
  
  isDirectory: (project, path, callback) ->
    fsIo.emit "isDirectory", {project, path}, callback
  
  touch: (project, path, callback) ->
    fsIo.emit "touch", {project, path}, callback
  
  read: (project, path, callback) ->
    fsIo.emit "read", {project, path}, callback
  
  write: (project, path, data, callback) ->
    fsIo.emit "write", {project, path, data}, callback
