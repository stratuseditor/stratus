should   = require 'should'
BaseRepo = require '../../server/repo/base_repo'


describe "BaseRepo", ->
  describe "new BaseRepo", ->
    repo = new BaseRepo
      name:     "stratus"
      path:     "/foo/bar"
      protocol: "fs"
    
    it "assigns the options as properties", ->
      repo.name.should.eql "stratus"
      repo.path.should.eql "/foo/bar"
      repo.protocol.should.eql "fs"

