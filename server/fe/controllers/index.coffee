# Load all of the controllers.
module.exports = (app) ->
  require('./main')    app
  require('./users')   app
  require('./bundles') app
  require('./project') app
