###

Routes:

GET /users/unique? field, value


###
User = require '../models/user'

module.exports = (app) ->
  
  # Check if an email or username is already taken.
  app.get "/users/unique", (req, res) ->
    {field, value} = req.query
    return res.json {} unless field in ["name", "email"]
    query        = {}
    query[field] = value
    
    User.where query, (users) ->
      unique       = !users.length
      query.unique = unique
      return res.json query
