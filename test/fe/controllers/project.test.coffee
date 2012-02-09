should  = require 'should'
qs      = require 'querystring'
request = require 'request'

{host, signIn} = require '../../app'
{UserFactory,
 ProjectFactory} = require '../../factories'



describe "/projects", ->
  describe "POST /projects", ->
    describe "not signed in", ->
      it "redirects", (done) ->
        request.post
          url: "#{host}/projects"
          json:
            project:
              name: "stratus"
        , (err, res, body) =>
          res.statusCode.should.eql 302
          done()
  
  
  describe "GET /projects/unique", ->
    describe "unique", ->
      res = null
      before (done) ->
        UserFactory.create (user) ->
          signIn host, user, ->
            request "#{host}/projects/unique?name=stratus&user_id=#{user.id}",
            (err, _res, body) ->
              throw err if err
              res = _res
              done()
      
      it "responds with valid JSON", ->
        JSON.parse(res.body).should.be.a "object"
      
      it "has a name property", ->
        JSON.parse(res.body).name.should.eql "stratus"
      
      it "is unique", ->
        JSON.parse(res.body).unique.should.be.true
    
    describe "not unique", ->
      res = null
      before (done) ->
        UserFactory.create (user) ->
          ProjectFactory.create
            user_id: user.id
            name: "taken"
          , (p) ->
            signIn host, user, ->
              request "#{host}/projects/unique?name=taken&user_id=#{user.id}",
              (err, _res, body) ->
                throw err if err
                res = _res
                done()
      
      it "responds with valid JSON", ->
        JSON.parse(res.body).should.be.a "object"
      
      it "has a name property", ->
        JSON.parse(res.body).name.should.eql "taken"
      
      it "is not unique", ->
        JSON.parse(res.body).unique.should.be.false
  
  
  describe "GET /:username/:project", ->
    describe "a project that exists", (done) ->
      res = null
      before (done) ->
        UserFactory.create name: "tom", (user) ->
          signIn host, user, ->
            ProjectFactory.create
              name:    "stratus"
              user_id: user.id
            , (project) ->
              request "#{host}/tom/stratus",
              (err, _res, body) ->
                res = _res
                done()
      
      it "renders", ->
        res.statusCode.should.eql 200
      
      it "the title includes :username/:project", ->
        res.body.should.match new RegExp("<title>tom/stratus.*</title>")
    
    describe "a nonexistant project", ->
      it "is a 404", (done) ->
        UserFactory.create (user) ->
          signIn host, user, ->
            request "#{host}/#{user.name}/my-plan-for-world-domination",
            (err, res, body) ->
              res.statusCode.should.eql 404
              body.should.include "404"
              done()

