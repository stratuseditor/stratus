should   = require 'should'
pair     = require '../'
{Buffer} = require 'fractus/src/buffer'
{Cursor} = require 'fractus/src/cursor'

describe "autopair", ->
  describe ".surround", ->
    describe "single line", ->
      b = new Buffer "Hello"
      c = new Cursor b, 0, 2
      c.selectTo 0, 4
      pair.surround b, c, "(", ")"
      it "surrounds the text", ->
        b.text().should.eql "He(ll)o"
      
      it "changes the selection to a cursor", ->
        should.exist c.point
        should.not.exist c.region
      
      it "moves the cursor to the end of the surrounded text", ->
        c.point.row.should.eql 0
        c.point.col.should.eql 5
    
    describe "multiple lines", ->
      b = new Buffer "Hello\nworld"
      c = new Cursor b, 1, 4
      c.selectTo 0, 2
      pair.surround b, c, "(", ")"
      it "surrounds the text", ->
        b.text().should.eql "He(llo\nworl)d"
      
      it "changes the selection to a cursor", ->
        should.exist c.point
        should.not.exist c.region
      
      it "moves the cursor to the end of the surrounded text", ->
        c.point.row.should.eql 1
        c.point.col.should.eql 4
    
    describe "a backwards region", ->
      b = new Buffer "Hello world"
      c = new Cursor b, 0, 5
      c.selectTo 0, 1
      pair.surround b, c, "(", ")"
      it "surrounds the text", ->
        b.text().should.eql "H(ello) world"
      
      it "changes the selection to a cursor", ->
        should.exist c.point
        should.not.exist c.region
      
      it "moves the cursor to the end of the surrounded text", ->
        c.point.row.should.eql 0
        c.point.col.should.eql 6
  
  
  describe ".close", ->
    describe "the next char is the close char", ->
      b = new Buffer "Hello( )world"
      c = new Cursor b, 0, 7
      pair.close b, c, ")"
      it "does not change the text", ->
        b.text().should.eql "Hello( )world"
      
      it "moves the cursor right", ->
       c.point.row.should.eql 0
       c.point.col.should.eql 8
    
    describe "the next char is *not* the close char", ->
      b = new Buffer "Hello( world"
      c = new Cursor b, 0, 7
      pair.close b, c, ")"
      it "inserts the character", ->
        b.text().should.eql "Hello( )world"
      
      it "moves the cursor right", ->
        c.point.row.should.eql 0
        c.point.col.should.eql 8
  
  
  describe ".matchForward", ->
    describe "when the area between is empty", ->
      b = new Buffer "Hel()d"
      c = new Cursor b, 0, 4
      r = pair.matchForward b, c, "("
      it "finds the correct Region", ->
        r.begin.row.should.eql 0
        r.begin.col.should.eql 4
        r.end.row.should.eql 0
        r.end.col.should.eql 5
    
    describe "when there is no nesting", ->
      b = new Buffer "Hel(lo, wor)ld"
      c = new Cursor b, 0, 4
      r = pair.matchForward b, c, "("
      it "finds the correct Region", ->
        r.begin.row.should.eql 0
        r.begin.col.should.eql 11
        r.end.row.should.eql 0
        r.end.col.should.eql 12
    
    describe "when there is nesting", ->
      b = new Buffer "Hel(lo,( ()) w()or)ld"
      c = new Cursor b, 0, 4
      r = pair.matchForward b, c, "("
      it "finds the correct Region", ->
        r.begin.row.should.eql 0
        r.begin.col.should.eql 18
        r.end.row.should.eql 0
        r.end.col.should.eql 19
    
    describe "when there is no end match", ->
      b = new Buffer "Hel(lo,( ()) w()orld"
      c = new Cursor b, 0, 4
      r = pair.matchForward b, c, "("
      it "is null", ->
        should.not.exist r
  
  
  describe ".matchBackward", ->
    describe "when the area between is empty", ->
      b = new Buffer "Hel()d"
      c = new Cursor b, 0, 5
      r = pair.matchBackward b, c, "("
      it "finds the correct Region", ->
        r.begin.row.should.eql 0
        r.begin.col.should.eql 3
        r.end.row.should.eql 0
        r.end.col.should.eql 4
    
    describe "when there is no nesting", ->
      b = new Buffer "Hel(lo, wor)ld"
      c = new Cursor b, 0, 12
      r = pair.matchBackward b, c, "("
      it "finds the correct Region", ->
        r.begin.row.should.eql 0
        r.begin.col.should.eql 3
        r.end.row.should.eql 0
        r.end.col.should.eql 4
    
    describe "when there is nesting", ->
      b = new Buffer "Hel(lo,( ()) w()or)ld"
      c = new Cursor b, 0, 19
      r = pair.matchBackward b, c, "("
      it "finds the correct Region", ->
        r.begin.row.should.eql 0
        r.begin.col.should.eql 3
        r.end.row.should.eql 0
        r.end.col.should.eql 4
    
    describe "nesting across multiple lines", ->
      b = new Buffer "hi {\n  if (true) {\n    return 5;\n  }\n}"
      c = new Cursor b, 4, 1
      r = pair.matchBackward b, c, "{"
      it "finds the correct Region", ->
        r.begin.row.should.eql 0
        r.begin.col.should.eql 3
        r.end.row.should.eql 0
        r.end.col.should.eql 4
    
    describe "when there is no begin match", ->
      b = new Buffer "Hel() w)orld"
      c = new Cursor b, 0, 8
      r = pair.matchBackward b, c, "("
      it "is null", ->
        should.not.exist r
