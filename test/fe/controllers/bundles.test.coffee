should  = require 'should'
request = require 'request'
bundle  = require 'stratus-bundle'
bundle.testDir()
{host}  = require '../../app'

describe "/bundles", ->
  describe "/bundles/:language/icon.png", ->
    res = null
    before (done) ->
      request "#{host}/bundles/Ruby/icon.png", (err, _res, body) ->
        res = _res
        done()
    
    it "renders", ->
      res.statusCode.should.eql 200
  
  
  describe "/bundles/:language.json", ->
    res  = null
    ruby = null
    before (done) ->
      request "#{host}/bundles/Ruby.json", (err, _res, body) ->
        res  = _res
        ruby = JSON.parse body
        done()
    
    it "renders", ->
      res.statusCode.should.eql 200
    
    describe "the response", ->
      it "is valid json", ->
        ruby.should.be.a "object"
      
      it "has a `name` property", ->
        ruby.name.should.eql "Ruby"
