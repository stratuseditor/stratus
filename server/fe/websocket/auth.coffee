{parseCookie} = require('connect').utils

module.exports = (io, sessionStore) ->
  io.set "authorization", (data, accept) ->
    return accept "No cookie transmitted.", false unless data.headers.cookie
    
    data.cookie    = parseCookie data.headers.cookie
    data.sessionId = data.cookie["express.sid"]
    
    sessionStore.get data.sessionId, (err, session) ->
      if err
        return accept err.message, false
      else if !session or !session.auth
        return accept "not authorized", false
      
      data.session = session
      return accept null, true
