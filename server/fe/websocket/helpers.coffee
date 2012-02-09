everyauth = require 'everyauth'

# Get the currently signed in user via websocket.
# 
# socket   - A socket.io socket.
# callback - Receives the current User. If not logged in, receives `null`.
# 
# Source: https://github.com/Raynos/so642/blob/master/src/route/messages.js#L177
# 
exports.getUser = (socket, callback) ->
  id = socket.handshake.session?.auth?.userId
  return callback null if !id
  everyauth.everymodule._findUserById id, callback
