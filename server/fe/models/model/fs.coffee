###


###
fs      = require 'fs'
path    = require 'path'
_       = require 'underscore'
DB_ROOT = path.resolve process.env.HOME, ".stratus", (process.env.NODE_ENV || "development")

fs.mkdirSync DB_ROOT, 0755 unless path.existsSync DB_ROOT

# The file system driver for the models. This must be overridden
# to be useful.
# 
# See models/user.coffee for example usage.
# 
module.exports = class FsModel
  @collections: {}
  
  # Override
  # The name of the model. Used as the file name to serialize to.
  modelName: "OVERRIDE"
  # Override
  # Be sure to call `super`.
  constructor: (options = {}) ->
    @errors = []
  
  # Public: Get a hash representing the info that will be stored in
  # the database about this model.
  # Override
  # 
  # Examples
  # 
  #   user = new User
  #     name:     "rob"
  #     password: "123456"
  #   user.attributes()
  #   # => { "name": "rob", "password": "xxxxxxxx" }
  # 
  # Returns a hash of attributes.
  attributes: ->
  
  # Public: Create and add string errors to the array `@errors`.
  # Override
  # 
  # callback - receives `true` if the model is valid, `false` if it is not.
  # 
  #   myDinner.valid (valid) ->
  #     valid
  #     # => false
  #     
  #     myDinner.errors
  #     # => ["You should always eat desert first.", ...]
  # 
  valid: (callback) ->
  
  
  
  # Public: Write the model's attributes to the database. If the model
  # already exists in the database, update it. Otherwise, insert.
  # 
  # callback - Receives a `success` parameter upon completion (optional).
  # 
  # Examples
  # 
  #   manInASpaceSuit.save (success) ->
  #     console.log "Man in space suit: 'You saved me!'" if success
  # 
  save: (callback) ->
    @valid (valid) =>
      return callback? false unless valid
      @preSave =>
        @id                                  = @_generateId() unless @id
        FsModel.collections[@modelName][@id] = @attributes()
        @_writeDb -> callback? true
  
  # Override
  preSave: (callback) -> callback()
  
  # Public: Remove the record from the database.
  # 
  # callback - Called upon completion (optional).
  # 
  # Examples
  # 
  #   bigScaryAlien.destroy ->
  #     console.log "Got him!"
  # 
  destroy: (callback) ->
    delete FsModel.collections[@modelName][@id]
    @id = null
    @_writeDb()
    return callback?()
  
  # Return an array of ALL of the records. This probably shouldnt be used
  # except for development purposes, loading a large database is very
  # expensive.
  @all: (callback) ->
    return callback FsModel.collections[@modelName]
  
  # Public: Retrieve a record from the database by it's unique id.
  # 
  # id       - the id to lookup by.
  # callback - receive the found record, or null if there is none.
  # 
  # Examples
  # 
  #   UserModel.find 123456, (user) ->
  #     console.log "Hello, #{ user.name }!" if user
  # 
  @find: (id, callback) ->
    return callback FsModel.collections[@modelName][id]
  
  # Public: Retrieve records based on a hash of constraints.
  # 
  # constraints - a hash where the keys are attribute names
  #               and values are the values to filter records by.
  # callback    - called with a list of matching models.
  # 
  # Examples
  # 
  #   UserModel.where {"name": "bob"}, (users) ->
  #     # ...
  # 
  @where: (constraints, callback) ->
    found   = []
    records = FsModel.collections[@modelName]
    for id, attrs of records
      valid = true
      for constrainField, constrainValue of constraints
        valid = false unless attrs[constrainField] == constrainValue
      found.push new @ attrs if valid
    return callback found
  
  # Public: Get the number of records in the database.
  # 
  # callback - a callback to receive the number of records.
  # 
  # Examples
  # 
  #   UserModel.count (count) ->
  #     console.log "There are #{ count } users"
  # 
  @count: (callback) ->
    return callback Object.keys(FsModel.collections[@modelName]).length
  
  # File-system driver specific helpers
  # Get the path of the file/database json.
  _dbPath: ->
    @__dbPath ||= path.join DB_ROOT, "#{ @modelName }.json"
    return @__dbPath
  
  # Get the data.
  _db: ->
    FsModel.collections[@modelName] ||= if path.existsSync @_dbPath()
      JSON.parse fs.readFileSync @_dbPath()
    else
      {}
  
  # Write the data to file. 
  _writeDb: (callback) ->
    data = JSON.stringify(FsModel.collections[@modelName])
    fs.writeFile @_dbPath(), data, callback
  
  # Generate a random ID.
  _generateId: ->
    id = "" + Math.floor(Math.random() * 10000000)
    if !FsModel.collections[@modelName][id]
      return id
    else
      return @_generateId()

