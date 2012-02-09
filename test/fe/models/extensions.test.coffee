should     = require 'should'
extensions = require '../../../server/fe/models/extensions'

{ProjectFactory} = require '../../factories'

sampleJS = """
    function hi() {
      console.log("hi");
    }
    hi()
  """
sampleCoffee = """
    hi = ->
      console.log "hi"
    hi()
  """
sampleCSS = """
    .test {
      color: red;
    }
  """
sampleStylus = """
    .hi
      color red
      &:hover
        color blue
"""
sampleNib = """
    @import "nib"
    .hi
      color red
      &:hover
        color blue
"""


describe "extensions", ->
  describe "()", ->
    it "assigns @path", ->
      extensions("some/path").path.should.eql "some/path"
  
  
  describe "#js", ->
    describe "top-level JS plugin", ->
      js = null
      before (done) ->
        ProjectFactory.create (p) ->
          p.repo().write "hi.js", sampleJS, ->
            extensions(p.path).js (err, _js) ->
              js = _js
              done()
      
      it "is a string", ->
        js.should.be.a "string"
      
      it "is the javascript code", ->
        js.should.include sampleJS
    
    describe "top-level Coffee plugin", ->
      js = null
      before (done) ->
        ProjectFactory.create (p) ->
          p.repo().write "hi.coffee", sampleCoffee, ->
            extensions(p.path).js (err, _js) ->
              js = _js
              done()
      
      it "is javascript code", ->
        js.should.include 'hi()'
        js.should.include 'function'
    
    describe "nested plugin", ->
      js = null
      before (done) ->
        ProjectFactory.create (p) ->
          p.repo().mkdir "myplugin", ->
            p.repo().write "myplugin/index.js", sampleJS, ->
              extensions(p.path).js (err, _js) ->
                js = _js
                done()
      
      it "is the javascript code", ->
        js.should.include sampleJS
  
  
  describe "#css", ->
    describe "top-level CSS plugin", ->
      css = null
      before (done) ->
        ProjectFactory.create (p) ->
          p.repo().write "hi.css", sampleCSS, ->
            extensions(p.path).css (err, _css) ->
              css = _css
              done()
      
      it "is a string", ->
        css.should.be.a "string"
      
      it "is the css code", ->
        css.should.include sampleCSS
    
    describe "top-level Stylus plugin", ->
      css = null
      before (done) ->
        ProjectFactory.create (p) ->
          p.repo().write "hi.styl", sampleStylus, ->
            extensions(p.path).css (err, _css) ->
              css = _css
              done()
      
      it "is css code", ->
        css.should.include '.hi:hover'
    
    describe "nested CSS plugin", ->
      css = null
      before (done) ->
        ProjectFactory.create (p) ->
          p.repo().mkdir "hi", ->
            p.repo().write "index.css", sampleCSS, ->
              extensions(p.path).css (err, _css) ->
                css = _css
                done()
      
      it "is the css code", ->
        css.should.include sampleCSS
    
    describe "nested Stylus plugin", ->
      css = null
      before (done) ->
        ProjectFactory.create (p) ->
          p.repo().mkdir "hi", ->
            p.repo().write "index.styl", sampleStylus, ->
              extensions(p.path).css (err, _css) ->
                css = _css
                done()
      
      it "is css code", ->
        css.should.include '.hi:hover'
    
    describe "Stylus plugin with Nib", ->
      css = null
      before (done) ->
        ProjectFactory.create (p) ->
          p.repo().write "hi.styl", sampleNib, ->
            extensions(p.path).css (err, _css) ->
              css = _css
              done()
      
      it "is css code", ->
        css.should.include '.hi:hover'
