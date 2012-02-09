should   = require 'should'
_        = require 'underscore'
validate = require '../../client/shared/validate'


buildUser = (attrs = {}) ->
  return _.defaults attrs,
    name:          "fred"
    password:      "123456"
    password_conf: "123456"

buildProject = (attrs = {}) ->
  return _.defaults attrs,
    name: "stratus"

assertValid = (errors) ->
  _.values(errors).length.should.eql 0

assertErrorsOn = (errors, field) ->
  errors[field].length.should.be.above 0


describe "Shared validations", ->
  describe "user", ->
    describe "valid", ->
      it "is valid", ->
        assertValid validate.user buildUser()
    
    describe "invalid", ->
      describe "name", ->
        it "is required", ->
          assertErrorsOn validate.user(buildUser(name: "")), "name"
        
        it "with spaces", ->
          assertErrorsOn validate.user(buildUser(name: "han solo")), "name"
        
        it "with dots", ->
          assertErrorsOn validate.user(buildUser(name: "han.solo")), "name"
      
      describe "password", ->
        it "is required", ->
          assertErrorsOn validate.user(buildUser(password: "")), "password"
        
        it "cannot be 5 chars long", ->
          assertErrorsOn validate.user(buildUser(password: "12345")), "password"
      
      describe "password_conf", ->
        it "is required", ->
          assertErrorsOn validate.user(buildUser(password_conf: "")), "password_conf"
        
        it "must match", ->
          attrs = buildUser
            password:      "123456"
            password_conf: "abcdef"
          assertErrorsOn validate.user(attrs), "password_conf"
  
  describe "project", ->
    describe "valid", ->
      it "is valid", ->
        assertValid validate.project buildProject()
      
      it "with dots", ->
        assertValid validate.project buildProject(name: "cheese.sandwich")
      
      it "with dashes", ->
        assertValid validate.project buildProject(name: "cheese-sandwich")
      
      it "with underscores", ->
        assertValid validate.project buildProject(name: "cheese_sandwich")
    
    describe "invalid", ->
      describe "name", ->
        it "is required", ->
          assertErrorsOn validate.project(buildProject(name: "")), "name"
        
        it "with spaces", ->
          assertErrorsOn validate.project(buildProject(name: "X Y")), "name"
        
        it "with slashes", ->
          assertErrorsOn validate.project(buildProject(name: "X/Y")), "name"

