should        = require 'should'
qs            = require 'querystring'
request       = require 'request'
{app, host}   = require '../../app'
{UserFactory} = require '../../factories'

requestUnique = (query, callback) ->
  q = qs.stringify query
  request "#{host}/users/unique?#{q}", (err, res, body) =>
    callback err, res

describe "/users", ->
  describe "GET /users/unique", ->
    describe "name", ->
      describe "unique", ->
        setup = (callback) ->
          requestUnique
            field: "name"
            value: "time"
          , (err, res, body) ->
            callback res
        
        it "renders valid JSON", (done) ->
          setup (res) ->
            JSON.parse(res.body).should.be.a "object"
            done()
        
        it "has a 'name' property", (done) ->
          setup (res) ->
            JSON.parse(res.body).name.should.eql "time"
            done()
        
        it "is unique", (done) ->
          setup (res) ->
            JSON.parse(res.body).unique.should.be.true
            done()
      
      describe "not unique", ->
        setup = (callback) ->
          UserFactory.create name: "blob", (u) =>
            requestUnique
              field: "name"
              value: "blob"
            , (err, res, body) ->
              callback res
        
        it "is not unique", (done) ->
          setup (res) ->
            JSON.parse(res.body).unique.should.be.false
            done()
    
    describe "email", ->
      describe "unique", ->
        setup = (callback) ->
          requestUnique
            field: "email"
            value: "time@example.com"
          , (err, res, body) ->
            callback res
        
        it "renders valid JSON", (done) ->
          setup (res) ->
            JSON.parse(res.body).should.be.a "object"
            done()
        
        it "has a 'email' property", (done) ->
          setup (res) ->
            JSON.parse(res.body).email.should.eql "time@example.com"
            done()
        
        it "is unique", (done) ->
          setup (res) ->
            JSON.parse(res.body).unique.should.be.true
            done()
      
      describe "not unique", ->
        setup = (callback) ->
          UserFactory.create email: "blob@example.com", (u) =>
            requestUnique
              field: "email"
              value: "blob@example.com"
            , (err, res, body) ->
              callback res
        
        it "is not unique", (done) ->
          setup (res) ->
            JSON.parse(res.body).unique.should.be.false
            done()

