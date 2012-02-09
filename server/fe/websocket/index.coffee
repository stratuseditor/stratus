# Load all of the controllers.
module.exports = (io, sessionStore) ->
  require('./auth') io, sessionStore
  require('./fs') io, sessionStore
