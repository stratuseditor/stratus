should          = require 'should'
{projectFields} = require '../../../server/fe/helpers/projects'

describe "Project helpers", ->
  describe "projectFields", ->
    {name} = projectFields
    
    it "is an input element", ->
      name.should.match /<input/
