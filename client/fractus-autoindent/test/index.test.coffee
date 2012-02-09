should = require 'should'
indent = require '../'
{Buffer} = require 'fractus/src/buffer'
{Cursor} = require 'fractus/src/cursor'

describe "autoindent", ->
  describe ".newline", ->
    describe "when the next line does not need extra indentation", ->
      describe "on the first line", ->
        b = new Buffer "    Hi"
        c = new Cursor b, 0, 5
        indent.newline b, c, "  "
        it "indents the text correctly", ->
          b.text().should.eql "    H\n    i"
        
        it "positions the cursor", ->
          c.point.row.should.eql 1
          c.point.col.should.eql 4
      
      describe "in the middle of the doc", ->
        b = new Buffer "    Hi\n    there"
        c = new Cursor b, 1, 6
        indent.newline b, c, "  "
        it "indents the text correctly", ->
          b.text().should.eql "    Hi\n    th\n    ere"
        
        it "positions the cursor", ->
          c.point.row.should.eql 2
          c.point.col.should.eql 4
      
      describe "when there is no indentation", ->
        b = new Buffer "Hi"
        c = new Cursor b, 0, 2
        indent.newline b, c, "  "
        it "does not indent", ->
          b.text().should.eql "Hi\n"
    
    describe "when the indent RegExp matches", ->
      describe "without initial indentation", ->
        b = new Buffer "Hi\nthere"
        c = new Cursor b, 0, 2
        indent.newline b, c, "  ", /hi/i
        it "add an extra tab", ->
          b.text().should.eql "Hi\n  \nthere"
        
        it "positions the cursor at the end of the inserted text", ->
          c.point.row.should.eql 1
          c.point.col.should.eql 2
      
      describe "with initial indentation", ->
        b = new Buffer "  Hi\nthere"
        c = new Cursor b, 0, 4
        indent.newline b, c, "  ", /hi/i
        it "add an extra tab", ->
          b.text().should.eql "  Hi\n    \nthere"
        
        it "positions the cursor at the end of the inserted text", ->
          c.point.row.should.eql 1
          c.point.col.should.eql 4
      
      describe "when the cursor is at the beginning of the line", ->
        b = new Buffer "Hi\nthere"
        c = new Cursor b, 0, 0
        indent.newline b, c, "  ", /hi/i
        it "does not indent", ->
          b.text().should.eql "\nHi\nthere"
        
        it "repositions", ->
          c.point.row.should.eql 1
          c.point.col.should.eql 0
  
  
  describe ".tryOutdent", ->
    describe "when the line matches the pattern", ->
      describe "when the line has no indentation", ->
        b = new Buffer "end"
        c = new Cursor b, 0, 3
        indent.tryOutdent b, c, "  ", /end$/
        c.toPoint()
        it "does not change the text", ->
          b.text().should.eql "end"
        
        it "does not move the cursor", ->
          c.point.row.should.eql 0
          c.point.col.should.eql 3
      
      describe "when the line has indentation", ->
        b = new Buffer "    end"
        c = new Cursor b, 0, 7
        indent.tryOutdent b, c, "  ", /end$/
        c.toPoint()
        it "outdents the text one level", ->
          b.text().should.eql "  end"
        
        it "moves the cursor back one level", ->
          c.point.row.should.eql 0
          c.point.col.should.eql 5
      
      describe "when the cursor is not at the end of the line", ->
        b = new Buffer "end"
        c = new Cursor b, 0, 2
        indent.tryOutdent b, c, "  ", /end$/
        c.toPoint()
        it "does not change the text", ->
          b.text().should.eql "end"
        
        it "does not move the cursor", ->
          c.point.row.should.eql 0
          c.point.col.should.eql 2
    
    describe "when the line does not match the pattern", ->
      b = new Buffer "  end"
      c = new Cursor b, 0, 5
      indent.tryOutdent b, c, "  ", /End$/
      c.toPoint()
      it "does not change the text", ->
        b.text().should.eql "  end"
      
      it "does not move the cursor", ->
        c.point.row.should.eql 0
        c.point.col.should.eql 5
    
    describe "when there is no pattern", ->
      b = new Buffer "  end"
      c = new Cursor b, 0, 5
      indent.tryOutdent b, c, "  ", undefined
      c.toPoint()
      it "does not change the text", ->
        b.text().should.eql "  end"
      
      it "does not move the cursor", ->
        c.point.row.should.eql 0
        c.point.col.should.eql 5


