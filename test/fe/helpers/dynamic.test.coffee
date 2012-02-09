should     = require 'should'
{messages} = require '../../../server/fe/helpers/dynamic'

mockFlash = ->
  return success: "I won"

describe "Dynamic helpers", ->
  describe "messages", ->
    describe "at least one message", ->
      html = messages {flash: mockFlash}, {}
      
      it "includes the message", ->
        html.should.include "I won"
      
      it "has the 'flash' class", ->
        html.should.include "flash"
      
      it "has the 'success' class", ->
        html.should.include "success"
    
    describe "no messages", ->
      html = messages {flash: -> {}}, {}
      
      it "is an empty string", ->
        html.should.eql ""
