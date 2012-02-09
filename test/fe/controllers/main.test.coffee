should  = require 'should'
request = require 'request'
{host}  = require '../../app'

describe "/", ->
  describe "GET /", ->
    it "renders", (done) ->
      request "#{host}/", (err, res, body) =>
        res.statusCode.should.eql 200
        done()
    
  describe "GET /browserify.js", ->
    it "renders", (done) ->
      request "#{host}/browserify.js", (err, res, body) =>
        res.statusCode.should.eql 200
        done()
  
  describe "GET /stratus-browserify.js", ->
    it "renders", (done) ->
      request "#{host}/stratus-browserify.js", (err, res, body) =>
        res.statusCode.should.eql 200
        done()
