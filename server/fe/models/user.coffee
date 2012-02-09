_        = require 'underscore'
Model    = require './model'
validate = require '../../../client/shared/validate'

# A user has many projects. And if they dont... they should get on that.
# 
# options - a hash containing:
#           "name"     - the name.. should match /[a-zA-Z0-9]{2,}/
#           "password" - 
# 
# Examples
# 
#   user = new User
#     name:     "mrWiseGuy"
#     password: "lolcatz"
#   user.save (success) ->
#     success # => true
# 
class User extends Model
  @modelName: "users"
  modelName:  "users"
  
  constructor: (options = {}) ->
    super options
    { @id, @name, @password, @password_conf, @email } = options
  
  # Get a hash representing the info that will be stored in the database
  # about this user.
  # 
  # Examples
  # 
  #   user = new User
  #     name:     "rob"
  #     password: "123456"
  #   user.attributes()
  #   # => { _id:        undefined
  #   #    , "name":     "rob"
  #   #    , "password": "xxxxxxxx"
  #   #    , "email":    "rob@example.com" }
  # 
  # Returns a hash of attributes.
  attributes: ->
    return { @id, @name, @password, @email }
  
  # Validations:
  # * username
  #   - valid characters: alphanumeric
  #   - 2 or more characters long
  #   - unique
  # * password
  #   - >= 6 chars long
  #   - must match password_conf
  valid: (callback) ->
    @errors = _.values validate.user(this)
    
    User.where {@name}, (users) =>
      @errors.push "That username is already taken." if users.length
      return callback @errors.length == 0

(new User())._db()

module.exports = User
