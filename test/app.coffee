request = require 'request'

module.exports =
  app:  require('../server/fe')(port: 8137)
  host: "http://localhost:8137"
  
  signIn: (host, user, callback) ->
    request.post
      url: "#{host}/login"
      json:
        login:    user.name
        password: user.password
    , callback
