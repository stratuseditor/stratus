should        = require 'should'
Project       = require '../../../server/fe/models/project'
{ProjectFactory,
 UserFactory} = require '../../factories'

describe "Project", ->
  describe "#valid", ->
    describe "a valid project", ->
      it "is valid", (done) ->
        ProjectFactory.build (p) ->
          p.valid (valid) ->
            valid.should.be.tue
            done()
    
    describe "an invalid project", ->
      it "is invalid", (done) ->
        ProjectFactory.build name: "what ever", (p) ->
          p.valid (valid) ->
            valid.should.be.false
            done()
    
    describe "duplicate name", ->
      it "is invalid", (done) ->
        UserFactory.create (u) ->
          ProjectFactory.create {name: "aName", user_id: u.id},
          (p) ->
            ProjectFactory.build {name: "aName", user_id: u.id},
            (p2) ->
              p2.valid (valid) ->
                valid.should.be.false
                done()
  
  
  describe "#canRead", ->
    describe "the owner", ->
      it "returns true", (done) ->
        UserFactory.create (u) ->
          ProjectFactory.create {user_id: u.id}, (p) ->
            p.canRead u, (canRead) ->
              canRead.should.be.true
              done()
    
    describe "a random user", ->
      it "returns false", (done) ->
        UserFactory.create (u) ->
          ProjectFactory.create (p) ->
            p.canRead u, (canRead) ->
              canRead.should.be.false
              done()

  
  describe "#canWrite", ->
    describe "the owner", ->
      it "returns true", (done) ->
        UserFactory.create (u) ->
          ProjectFactory.create {user_id: u.id}, (p) ->
            p.canWrite u, (canWrite) ->
              canWrite.should.be.true
              done()
    
    describe "a random user", ->
      it "returns false", (done) ->
        UserFactory.create (u) ->
          ProjectFactory.create (p) ->
            p.canWrite u, (canWrite) ->
              canWrite.should.be.false
              done()
  
  
  describe "#list", ->
    files = null
    before (done) ->
      ProjectFactory.create (p) ->
        p.repo().touch "file.rb", ->
          p.list "./", (err, _files) ->
            files = _files
            done()
    
    it "is an array", ->
      files.should.be.an.instanceof Array
    
    describe "the first element", ->
      it "is an object", ->
        files[0].should.be.a "object"
      
      it "has a `name` property", ->
        files[0].name.should.eql "file.rb"
      
      it "has a `language` property", ->
        files[0].language.should.eql "Ruby"
  
  
  describe "#read", ->
    describe "a valid file", ->
      file = null
      before (done) ->
        ProjectFactory.create (p) ->
          p.repo().write "file.rb", "cheese\nsauce", ->
            p.read "file.rb", (err, _file) ->
              file = _file
              done()
      
      it "is an object", ->
        file.should.be.a "object"
      
      it "has a `data` property", ->
        file.data.should.eql "cheese\nsauce"
      
      it "has a `language` property", ->
        file.language.should.eql "Ruby"
    
    describe "a nonexistant file", ->
      file = null
      err  = null
      before (done) ->
        ProjectFactory.create (p) ->
          p.read "file.rb", (_err, _file) ->
            file = _file
            err  = _err
            done()
      
      it "is null", ->
        should.not.exist file
      
      it "passes an error", ->
        should.exist err
  
  
  describe "#config", ->
    describe "when the project conf file exists", ->
      it "overrides the defaults", (done) ->
        ProjectFactory.create (project) ->
          conf = JSON.stringify {"fractus.theme": "Cheese fries"}
          project.repo().write ".stratus.json", conf, ->
            project.config (err, settings) ->
              settings["fractus.theme"].should.eql "Cheese fries"
              done()
    
    describe "when the project conf file does not exist", ->
      it "does not pass an error", (done) ->
        ProjectFactory.create (project) ->
          project.config (err, conf) ->
            should.not.exist err
            conf.should.be.a "object"
            done()
  
  
  describe ".lookup", ->
    describe "an existing project", ->
      user    = null
      project = null
      before (done) ->
        UserFactory.create (u) ->
          ProjectFactory.create {user_id: u.id}, (p) ->
            user    = u
            project = p
            done()
      
      it "passes the project", (done) ->
        Project.lookup "#{user.name}/#{project.name}", (proj) ->
          proj.id.should.eql project.id
          done()
    
    describe "a non-existant project", ->
      it "passes null", (done) ->
        Project.lookup "abc/123", (proj) ->
          should.not.exist proj
          done()

