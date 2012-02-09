return unless location.pathname == "/login"

{validate} = require 'stratus-ui'

jQuery ($) ->
  $form  = $(".sign-in form")
  
  presence = (fieldName) ->
    return ($el, callback) ->
      val = $el.val()
      return callback "Please enter your #{ fieldName }" unless val
      return callback []
  
  validate.form $form,
    "[name='login']":    presence "username"
    "[name='password']": presence "password"
