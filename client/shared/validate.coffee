###
This module includes **only** the validations that can be shared between the
server and the client. _Anything that involved database lookups to check
uniqueness, ect, must be done separately._

Each function receives the attributes and returns an object of errors.
{field: [errors]}
A return value of `{}` is success.

###


# A valid username must match this regular expression.
USER_RE    = /^[a-zA-Z0-9]{2,}$/
# The name of the project must match this regex.
PROJECT_RE = /^[a-zA-Z0-9_.-]+$/

module.exports =
  user: (attrs) ->
    {name, password, password_conf} = attrs
    
    errors          = {}
    errors.name     = ["Username is required"] unless name
    errors.password = ["Password is required"] unless password
    
    errors.name   ||= ["Username must match #{ USER_RE }."] unless USER_RE.test name
    
    unless password?.length >= 6
      errors.password ||= "Password is too short"
    
    unless password_conf
      errors.password_conf = ["Password confirmation is required"]
    unless password == password_conf
      errors.password_conf ||= ["Confirmation must match"]
    return errors
  
  
  project: (attrs) ->
    {name} = attrs
    errors = {}
    
    errors.name = ["Project name is required"] unless name
    
    unless PROJECT_RE.test(name)
      errors.name ||= ["The project name must match #{PROJECT_RE}"]
    
    return errors
