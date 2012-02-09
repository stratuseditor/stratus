should = require 'should'
{ hashToAttributes
, imageTag
, errorMessages
, jsData} = require '../../../server/fe/helpers/basic'

describe "Basic helpers", ->
  describe "hashToAttributes", ->
    html = hashToAttributes foo: "bar", dinner: "rice"
    
    it "includes the html attributes", ->
      html.should.include "foo='bar' dinner='rice'"
    
    it "has a leading space", ->
      html.should.match /^ /
  
  
  describe "imageTag", ->
    describe "no extra attributes", ->
      html = imageTag "foo.png"
      
      it "produces the correct html", ->
        html.should.eql "<img src='/images/foo.png'/>"
    
    describe "extra attrs", ->
      html =  imageTag "foo.png", alt: "Foo"
      
      it "produces the correct html", ->
        html.should.eql "<img src='/images/foo.png' alt='Foo'/>"
  
  
  describe "errorMessages", ->
    html = errorMessages ["A", "B"]
    
    it "produces the correct html", ->
      html.should.eql "<ul class='errors'><li>A</li><li>B</li></ul>"
  
  
  describe "jsData", ->
    js = jsData fried: "pickles"
    
    it "sets `window.data`", ->
      js.should.include "window.data ="
    
    it "includes the data", ->
      js.should.include JSON.stringify(fried: "pickles")

