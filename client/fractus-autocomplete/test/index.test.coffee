should       = require 'should'
autocomplete = require '../'
{Buffer}     = require 'fractus/src/buffer'

describe "autocomplete", ->
  describe ".words", ->
    describe "when a word matches", ->
      it "finds the correct suffix", ->
        suffix = autocomplete.words "foo", ["foobar", "barbaz", "bla"].sort()
        suffix.should.eql "bar"
    
    describe "when no word matches", ->
      it "returns ''", ->
        suffix = autocomplete.words "foo", ["Xfoobar", "barbaz", "bla"].sort()
        suffix.should.eql ""
  
  
  describe ".buffer", ->
    describe "when a word matches on the same line", ->
      b = new Buffer "The String word to complete\nbuffer - A buffer"
      it "returns the word", ->
        autocomplete.buffer("S", b, 0).should.eql "tring"
    
    describe "when a word matches on a previous line", ->
      b = new Buffer "The String word to complete\nbuffer - A buffer"
      it "returns the word", ->
        autocomplete.buffer("S", b, 1).should.eql "tring"
    
    describe "when a word matches on a later line", ->
      b = new Buffer "The String word to complete\nbuffer - A buffer"
      it "returns the word", ->
        autocomplete.buffer("bu", b, 0).should.eql "ffer"
    
    describe "when no word matches", ->
      b = new Buffer "The String word to complete\nbuffer - A buffer"
      it "returns the word", ->
        autocomplete.buffer("X", b, 0).should.eql ""
    
    describe "when 'except' is given", ->
      b = new Buffer "Clock\nCookie Cheese"
      it "returns the word", ->
        autocomplete.buffer("C", b, 0, "Clock").should.eql "ookie"
