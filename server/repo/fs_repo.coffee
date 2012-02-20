###
TODO
* dont let files be created with whitespace names

###

fs      = require 'fs'
path    = require 'path'
util    = require 'util'
{exec}  = require 'child_process'
findit  = require 'findit'
Repo    = require './base_repo'
git     = require 'gift'

STRATUS = path.resolve process.env.HOME, ".stratus"
FS_BASE = path.resolve STRATUS, (process.env.NODE_ENV || "development"), "projects"
fs.mkdirSync STRATUS, 0755 unless path.existsSync STRATUS
fs.mkdirSync FS_BASE, 0755 unless path.existsSync FS_BASE

# Create a new project on the file system.
# 
# options - a hash
#           Required:
#           "name"  - The name of the project, such as "stratus".
#           "owner" - The name of the user who is creating the project.
#           
#           And one of the following optional properties:
#           "path"  - The path to the directory on the file system that
#                   should become a project (optional).
#           "clone" - A git clone URL. The new project will be a clone of
#                     the URL passed (optional).
# callback - receives the FsRepo instance.
# 
# Examples
# 
#   createFsRepo
#     name:  "rails"
#     owner: someUser
#     clone: git://github.com/rails/rails.git
#   , (fsRepo) ->
#     # ...
# 
#   createFsRepo
#     name:  "how-to-evade-zombies"
#     owner: someUser
#   , (fsRepo) ->
#     # ...
# 
#   createFsRepo
#     name:  "rails"
#     owner: someUser
#     path:  "/some/project/path"
#   , (fsRepo) ->
#     # ...
# 
# No return.
createFsRepo = (options, callback) ->
  # Create an empty project with a Git repo.
  # Use an existing directory on the file system for the project.
  if options.path
    return callback new FsRepo {
      name:     options.name
      path:     options.path
      protocol: "fs"
    }
    
  # Clone the project from someplace.
  else if options.clone
    projectPath = allocate options.owner, options.name, false
    exec "git clone #{options.clone} #{projectPath}", (err) ->
      console.error err if err
      return callback new FsRepo {
        name:     options.name
        path:     projectPath
        protocol: "fs"
      }
    
  # Create an empty project without a Git repo.
  else
    projectPath = allocate options.owner, options.name
    return callback new FsRepo {
      name:     options.name
      path:     projectPath
      protocol: "fs"
    }
    


# Generate a path for the project.
allocate = (owner, projectName, create=true) ->
  userDir    = path.resolve "#{ FS_BASE }/#{ owner }"
  projectDir = path.resolve userDir, projectName
  fs.mkdirSync userDir, 0755 unless path.existsSync userDir
  fs.mkdirSync projectDir, 0755 if create
  return projectDir


module.exports = class FsRepo extends Repo
  # See `createFsRepo` for usage.
  @create: createFsRepo
  
  
  delete: (filepath, callback) ->
    fullPath = @_clean filepath, filepath
    if @isDirectorySync(filepath)
      @list filepath, (err, files) =>
        for file in files
          @delete "#{ filepath }/#{ file }"
        fs.rmdirSync fullPath
        callback?()
    else
      fs.unlinkSync fullPath
      return callback?()
  
  move: (fromPath, toPath, callback) ->
    fs.rename @_clean(fromPath), @_clean(toPath), callback
  
  copy: (fromPath, toPath, callback) ->
    exec "cp -r '#{@_clean(fromPath)}' '#{@_clean(toPath)}'", callback
  
  
  exists: (filepath, callback) ->
    return callback path.existsSync @_clean filepath
  
  
  mkdir: (dirpath, callback) ->
    directory = @_clean dirpath
    return callback?() if path.existsSync directory
    fs.mkdir directory, 0755, ->
      return callback?()
  
  list: (dirpath, callback) ->
    directory = @_clean dirpath
    fs.readdir directory, (err, files) =>
      newFiles = []
      for file in files
        if @isDirectorySync path.join(dirpath, file)
          newFiles.push file + "/"
        else
          newFiles.push file
      return callback err, newFiles
  
  
  listR: (dirpath, callback, excludeDirs=false) ->
    files    = findit.sync @_clean(dirpath)
    newFiles = []
    for file in files
      file  = file.slice @path.length
      file  = file.slice 1 if file[0] == "/"
      isDir = @isDirectorySync file
      if excludeDirs
        newFiles.push file if !isDir
      else if isDir
        newFiles.push file + "/"
      else
        newFiles.push file
    return callback newFiles
  
  
  isDirectory: (dirpath, callback) ->
    return callback fs.statSync(@_clean dirpath).isDirectory()
  
  isDirectorySync: (dirpath) ->
    try
      return fs.statSync(@_clean dirpath).isDirectory()
    catch err
      return false
  
  touch: (file, callback) ->
    fullPath = @_clean file
    return callback?() if path.existsSync fullPath
    fs.writeFile fullPath, "", ->
      callback?()
  
  
  read: (file, callback) ->
    fullPath = @_clean file
    fs.readFile fullPath, (err, data) ->
      return callback err, data?.toString()
  
  write: (file, data, callback) ->
    fullPath = @_clean file
    fs.writeFile fullPath, data, callback
  
  
  isGit: (callback) ->
    return callback null, @_isGit if @_isGit?
    fs.readdir @path, (err, dirs) =>
      return callback err if err
      return callback null, (@_isGit = !!~dirs.indexOf(".git"))
  
  git: ->
    @_git ||= git @path
  
  # Helpers
  
  # Change the `filepath` the be relative to the project root, and remove
  # any junk from the path.
  # 
  # Examples (assume the project root is "/home/x/bob")
  # 
  #   _clean "some/file.py"
  #   # => "/home/x/bob/some/file.py"
  # 
  # Returns the expanded and cleaned path. If the path ended up outside
  # the project (via "../../" whatever), "" is returned instead.
  _clean: (filepath) ->
    cleanPath @path, filepath


filename = (filePath) ->
  path.basename path.normalize(filePath)

cleanPath = (projectRoot, filePath) ->
  throw new Error "You can't do that!" if !filePath
  projectRoot = projectRoot.replace(/[\/]$/, "") unless projectRoot == "/"
  clean       = path.join projectRoot, path.normalize(filePath)
  if clean.indexOf(projectRoot + "/") == 0
    return clean
  else
    throw new Error "You can't do that!"

