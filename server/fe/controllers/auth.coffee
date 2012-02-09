###
Handle authentication.

Helpful links:

* http://blog.nodeknockout.com/post/9417557660/countdown-
  to-ko-23-login-with-password-facebook
* https://github.com/bnoguchi/everyauth
* https://github.com/bnoguchi/everyauth/blob/master/example/server.js

###

everyauth = require 'everyauth'
express   = require 'express'
User      = require '../models/user'

module.exports = (app) ->
  app.use everyauth.middleware()
  everyauth.helpExpress app

everyauth.everymodule
  .findUserById (id, callback) ->
    User.find id, (user) ->
      callback null, user

class PasswordAuth
  @authenticate: (username, password) ->
    errors = []
    errors.push "Missing username" unless username
    errors.push "Missing password" unless password
    return errors if errors.length
    
    promise = @Promise()
    
    User.where {name: username}, (users) ->
      user = users[0]
      return promise.fulfill ["No user exists with that name"] unless user
      # Incorrect password
      if user.password != password
        return promise.fulfill ["Incorrect password"]
      # Sign in successful.
      return promise.fulfill user
    return promise
  
  @validate: (attrs, errors) ->
    user = new User
      name:          attrs.login
      password:      attrs.password
      password_conf: attrs.password_conf
    promise = @Promise()
    user.valid (valid) ->
      errors = if valid
        []
      else
        user.errors
      return promise.fulfill errors
    return promise
  
  @register: (attrs) ->
    user = new User
      name:          attrs.login
      password:      attrs.password
      password_conf: attrs.password_conf
    user.save()
    return user


# Set up authentication strategies.

# Normal login.
everyauth.password
  .loginWith("login")
  .getLoginPath("/login")
  .postLoginPath("/login")
  .loginView("users/login.jade")
  .loginLocals
    title: "Log In - Stratus"
  .authenticate(PasswordAuth.authenticate)
  
  .getRegisterPath("/register")
  .postRegisterPath("/register")
  .registerView("users/register.jade")
  .registerLocals
    title: "Register - Stratus"
  
  .validateRegistration(PasswordAuth.validate)
  .registerUser(PasswordAuth.register)
  
  .loginSuccessRedirect("/")
  .registerSuccessRedirect("/")
  
  .extractExtraRegistrationParams (req) ->
    password_conf: req.body.password_conf


