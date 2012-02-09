_        = require 'underscore'
fs       = require 'fs'
path     = require 'path'
bundle   = require 'stratus-bundle'
Model    = require './model'
User     = require './user'
repo     = require '../../repo'
validate = require '../../../client/shared/validate'

# A project points to a directory on the file system, a user, and some
# config stuff.
# 
# options - a hash containing:
#           "name"     - the name of the project.
#           "user_id"  - the ID of the owner.
#           "path"     - The path on the file system.
#           "protocol" - "fs", "dropbox" ...
#           "isPublic" - Whether or not the project is publicly acccessable.
#           "isGit":   - Whether or not the project uses Git.
# 
# Examples
# 
# 
# 
module.exports = class Project extends Model
  @modelName: "projects"
  modelName:  "projects"
  
  constructor: (options = {}) ->
    super options
    { @id, @name, @user_id, @path, @protocol, @isPublic, @isGit } = options
    
  preSave: (callback) ->
    User.find @user_id, (user) =>
      repo.fs.create
        name:     @name
        owner:    user.name
        path:     @path
        protocol: @protocol
        isPublic: @isPublic
        isGit:    @isGit
      , (_repo) =>
        {@path} = _repo
        callback()
  
  # Get a hash representing the info that will be stored in the database
  # about this project.
  # 
  # Returns a hash of attributes.
  attributes: ->
    return { @id, @name, @user_id, @path, @protocol, @isPublic, @isGit }
  
  # Validations:
  # * name
  #   - unique within scope of user_id
  #   - 
  valid: (callback) ->
    @errors = _.values validate.project(this)
    
    @errors.push "What the... how can there not be a user?!" unless @user_id
    
    Project.where {@name, @user_id}, (projects) =>
      if projects.length && (!@id || projects[0].id != @id)
        @errors.push "You already have a project named #{@name}"
      return callback @errors.length == 0
  
  # Public: Return whether or not the given user has the permissions necessary
  # to read from the repo.
  # 
  # user     - An instance of User
  # callback - Receives boolean.
  # 
  # Examples
  # 
  #   project.canRead bob, (canRead) ->
  #     # ...
  # 
  # No return.
  canRead: (user, callback) ->
    return callback user.id == @user_id
  
  # Public: Return whether or not the given user has the permissions necessary
  # to write to the repo.
  # 
  # user     - An instance of User
  # callback - Receives boolean.
  # 
  # Examples
  # 
  #   project.canWrite bob, (canRead) ->
  #     # ...
  # 
  # No return.
  canWrite: (user, callback) ->
    return callback user.id == @user_id
  
  # Public: Get an instance of Repo for the project.
  repo: ->
    if @protocol == "fs"
      return new repo.fs {@name, @path, @protocol, @isGit}
    else
      throw new Error "Unsupported Project protocol: '#{@protocol}'"
  
  # Public: Same as Repo#list, except the callback receives a list of objects
  # of the form {name, language}.
  # 
  # Examples
  # 
  #   proj.list "./", (err, files) ->
  #     for file in files
  #       console.log file.name, ":", file.language
  # 
  list: (dirpath, callback) ->
    @repo().list dirpath, (err, files) ->
      return callback err, [] if !files.length
      fileObjs = []
      last     = files.length
      i        = 0
      for file in files
        do (file) ->
          if _.last(file) == "/"
            fileObjs.push {name: file}
            i++
            return callback err, fileObjs if i == last
          else
            bundle.identify file, (err, language) ->
              fileObjs.push {name: file, language}
              i++
              return callback err, fileObjs if i == last
    return
  
  # Public: Same as Repo#read, except the callback receives an object
  # of the form {name, language}.
  read: (filepath, callback) ->
    @repo().read filepath, (err, data) ->
      if data?
        bundle.identify filepath, data.slice(0, data.indexOf("\n")), (err, language) ->
          return callback err, {data, language}
      else
        return callback err, null
  
  
  # Public: Get the project's entire configuration, merged with the
  # default configuration.
  config: (callback) ->
    fs.readFile "#{__dirname}/../../config.json", (err, baseConfig) =>
      return callback err if err
      
      baseConfig = JSON.parse baseConfig.toString()
      @_userConfig (err, userConfig) =>
        @_config (err, projConfig) ->
          return callback err if err
          return callback null, _.extend(baseConfig, userConfig, projConfig)
  
  # Internal: Get only the configuration for the project.
  _config: (callback) ->
    confPath = "#{@path}/.stratus.json"
    return callback null, {} unless path.existsSync confPath
    
    fs.readFile confPath, (err, projConfig) ->
      return callback err if err
      
      projConfig = JSON.parse projConfig.toString()
      return callback null, projConfig
  
  # Internal: Get the user's config.
  _userConfig: (callback) ->
    Project.where {@user_id, name: ".stratus"}, (projects) ->
      return callback null, {} if !projects[0]
      fs.readFile projects[0].path + "/config.json", (err, data) ->
        if err
          return callback null, {}
        else
          return callback null, JSON.parse data.toString()
  
  # Public: Get a project based on an identifier path.
  # 
  # projectPath - A string matching ":username/:projectName",
  #               such as "dj/stratus".
  # callback    - A function which receives the matching instance of
  #               Project. If there is no match, null is passed.
  # 
  @lookup: (projectPath, callback) ->
    [username, projectName] = projectPath.split '/'
    User.where {name: username}, (users) ->
      return callback null if !users.length
      user = users[0]
      Project.where user_id: user.id, name: projectName, (projects) ->
        return callback null if !projects.length
        return callback projects[0]

(new Project())._db()
