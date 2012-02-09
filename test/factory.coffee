###
To create a factory:

  factory     = require 'factory'
  userFactory = factory User,
    name:          "Fred"
    email:         "fred@example.com"
    password:      "123456"
    password_conf: "123456"

Create, but dont save:

  u1 = userFactory.build()
  u2 = userFactory.build name: "Tim"

Create and save:

  userFactory.create (u) ->

###
_ = require 'underscore'

# Create a factory.
# 
# Model    - A class which extends Model.
# defaults - A hash of default attributes for the factory.
# 
# Return an instance of Factory.
module.exports = (Model, defaults) ->
  return new Factory Model, defaults

class Factory
  @i: 0
  
  constructor: (@Model, @defaults) ->
  
  # Construct an instance of the Model, but do not save it.
  # 
  # attrs    - A hash of attributes to modify the defaults with (optional).
  #         Alternatively, attrs can be a function which receives a callback,
  #         into which it passes a hash of attributes.
  # callback - A function to receive the model.
  # 
  #   u1 = userFactory.build()
  #   u2 = userFactory.build name: "Tim"
  # 
  # Returns an instance of the model.
  build: (attrs = {}, callback) ->
    if _.isUndefined callback
      callback = attrs
      attrs    = {}
    
    complete = (defaults) =>
      attrs = _.defaults attrs, defaults
      model = new @Model @_sub(attrs)
      return callback model
    
    if _.isFunction @defaults
      @defaults (attributes) =>
        complete attributes
    else
      complete @defaults
  
  # Construct an instance of the Model and save it.
  # 
  # attrs    - A hash of attributes to modify the defaults with (optional).
  # callback - A function to receive the saved model.
  # 
  #   userFactory.create (u1) ->
  #   
  #   userFactory.create name: "Tim", (u2) ->
  # 
  # No return.
  create: (attrs, callback) ->
    if _.isUndefined callback
      callback = attrs
      attrs    = {}
    
    @build attrs, (model) ->
      model.save ->
        return callback model
  
  # Handle things like incrementors, etc.
  _sub: (attrs) ->
    newAttrs = {}
    for field, val of attrs
      if _.isString val
        randInt         = Math.floor (Math.random()*1000000)
        newAttrs[field] = val.replace /[%]i/g, randInt
      else
        newAttrs[field] = val
    return newAttrs
    
