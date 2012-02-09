module.exports = (app) ->
  app.helpers require('./basic')
  app.helpers require('./projects')
  app.dynamicHelpers require('./dynamic')
