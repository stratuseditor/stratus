return unless location.pathname == "/register"

{tabs, validate} = require 'stratus-ui'

validateUser = require('../../shared/validate').user

jQuery ($) ->
  # ###########################
  # Strategy tabs
  # ###########################
  tabs $(".register > .tabs")
  
  
  # ###########################
  # Validations
  # ###########################
  $form          = $(".register form")
  $username      = $(".register [name='login']")
  $password      = $(".register [name='password']")
  $password_conf = $(".register [name='password_conf']")
  
  validate.form $form,
    # Validate username
    "[name='login']": ($el, callback) ->
      val    = $el.val()
      errors = validateUser(name: val).name
      return callback errors if errors?.length
      
      # Unique name address.
      Helpers.unique "name", val, (unique, name) ->
        unless unique
          return callback "There is already a user with name '#{name}'"
        return callback []
    
    
    # Validate password
    "[name='password']": ($el, callback) ->
      val    = $el.val()
      errors = validateUser(password: val).password
      return callback errors
    
    
    # Validate password confirmation
    "[name='password_conf']": ($el, callback) ->
      password = $(".register [name='password']").val()
      val      = $el.val()
      return callback validateUser(password: val, password_conf: val).password_conf

class Helpers
  @unique: (field, value, callback) ->
    $.getJSON "/users/unique", {field, value},
    (data, status, xhr) ->
      callback data.unique, value
  
  
