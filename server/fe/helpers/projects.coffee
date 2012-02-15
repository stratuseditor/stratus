{hashToAttributes} = require './basic'

input = (attrs) ->
  attrs.type         ?= "text"
  attrs.autocomplete ?= "off" unless attrs.type == "checkbox"
  return "<input#{ hashToAttributes attrs }/>"

checkbox = (label, attrs) ->
  attrs.type ?= "checkbox"
  return "<label>#{ input attrs }#{ label }</label>"

field = (html) ->
  return "<div class='field'>#{ html }</div>"

module.exports =
  # HTML for form fields of the project creation.
  projectFields:
    name: input
      name:         "project[name]"
      placeholder:  "Project name"
    
    isPublic: checkbox("Public",
      name:    "project[isPublic]"
      checked: "checked")
    
    gitUrl: input
      name:         "project[gitUrl]"
      placeholder:  "Git URL"
    
    
    ftp:
      host: input
        name:        "project[ftp][host]"
        placeholder: "FTP Host"
        class:       "ftp-host"
      
      port: input
        name:        "project[ftp][port]"
        placeholder: "FTP Port (22)"
        class:       "ftp-port"
      
      username: input
        name:        "project[ftp][username]"
        placeholder: "FTP Username"
      
      password: input
        name:        "project[ftp][password]"
        placeholder: "FTP Password"
        type:        "password"
      
    
    buttons: "<input type='submit'
                     class='primary'
                     value='Create Project'/>
              <button>Cancel</button>"
