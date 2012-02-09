should        = require 'should'
User          = require '../../../server/fe/models/user'
{UserFactory} = require '../../factories'

describe "User", ->
  describe "User#valid", ->
    describe "a valid user", ->
      it "is valid", (done) ->
        UserFactory.build (u) ->
          u.valid (valid) ->
            valid.should.be.true
            done()
    
    describe "an invalid user", ->
      it "is invalid", (done) ->
        UserFactory.build name: " ", (u) ->
          u.valid (valid) ->
            valid.should.be.false
            done()
      
      it "assigns error messages to @errors", (done) ->
        UserFactory.build name: " ", (u) ->
          u.valid (valid) ->
            u.errors.length.should.be.above 0
            done()
      
      describe "incorrect password confirmation", ->
        it "is invalid", (done) ->
          UserFactory.build
            password: "123456"
            password_conf: "654321"
          , (u) =>
            u.valid (valid) ->
              valid.should.be.false
              done()
