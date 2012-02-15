factory         = require './factory'
{User, Project} = require '../server/fe/models'

UserFactory = factory User,
  name:          "dj%i"
  password:      "123456"
  password_conf: "123456"

ProjectFactory = factory Project, (callback) ->
  UserFactory.create (u) ->
    callback
      name:     "stratus-%i"
      user_id:  u.id
      protocol: "fs"
      isPublic: true


module.exports = {UserFactory, ProjectFactory}
