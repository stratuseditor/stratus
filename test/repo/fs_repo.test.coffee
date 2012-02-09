should = require 'should'
fs     = require 'fs'
path   = require 'path'
FsRepo = require '../../server/repo/fs_repo'

FS_ROOT = path.resolve "#{process.env.HOME}/.stratus/test/projects"
proj    = new FsRepo path: FS_ROOT


describe "FsRepo", ->
  describe "FsRepo.create", ->
    describe "local non-git", ->
      repo = null
      before (done) ->
        FsRepo.create
          name:  "how-to-evade-zombies"
          owner: "ted"
          isGit: false
        , (_repo) ->
          repo = _repo
          done()
      
      it "has a valid path", ->
        repo.path.should.match /\/ted\/how-to-evade-zombies$/
      
      it "has a protocal of 'fs'", ->
        repo.protocol.should.eql "fs"
      
      it "creates the directory", ->
        path.existsSync(repo.path).should.be.true
    
    
    describe "local existing directory", ->
      repo = null
      before (done) ->
        FsRepo.create
          name:  "how-to-evade-zombies"
          owner: "ted"
          path:  "/foo/bar"
        , (_repo) ->
          repo = _repo
          done()
      
      it "has a valid path", ->
        repo.path.should.eql "/foo/bar"
      
      it "has a protocal of 'fs'", ->
        repo.protocol.should.eql "fs"
  
  
  describe "FsRepo#delete", ->
    it "deletes a file", (done) ->
      proj.touch "foo.txt", ->
        proj.delete "foo.txt", ->
          path.existsSync("#{proj.path}/foo.txt").should.be.false
          done()
    
    it "deletes a directory", (done) ->
      proj.mkdir "cake", ->
        proj.delete "cake", ->
          path.existsSync("#{proj.path}/cake").should.be.false
          done()
    
    it "recursively deletes a directory", (done) ->
      proj.mkdir "cheesecake", ->
        proj.touch "cheesecake/foo.js", ->
          proj.delete "cheesecake", ->
            path.existsSync("#{proj.path}/cheesecake").should.be.false
            done()
  
  describe "FsRepo#move", ->
    describe "move file", ->
      before (done) ->
        proj.write "m.txt", "almost dinner time", ->
          proj.mkdir "m", ->
            proj.move "m.txt", "m/x.txt", done
      
      it "the new file has the same data as the old file", (done) ->
        proj.read "m/x.txt", (err, data) ->
          data.should.eql "almost dinner time"
          done()
    
    describe "move directory", ->
      before (done) ->
        proj.mkdir "w", ->
          proj.touch "w/q.txt", ->
            proj.move "w", "z", done
      
      it "the old directory is gone", ->
        path.existsSync("#{proj.path}/w").should.be.false
      
      it "a new directory is created", ->
        path.existsSync("#{proj.path}/z").should.be.true
      
      it "it contains the child file", ->
        path.existsSync("#{proj.path}/z/q.txt").should.be.true
  
  
  describe "FsRepo#copy", ->
    describe "copy file", ->
      before (done) ->
        proj.write "m.txt", "almost dinner time", ->
          proj.mkdir "m", ->
            proj.copy "m.txt", "m/x.txt", done
      
      it "the new file has the same data as the old file", (done) ->
        proj.read "m/x.txt", (err, data) ->
          data.should.eql "almost dinner time"
          done()
    
    describe "copy directory", ->
      before (done) ->
        proj.mkdir "w", ->
          proj.touch "w/q.txt", ->
            proj.copy "w", "z", done
      
      it "the old directory is still there", ->
        path.existsSync("#{proj.path}/w").should.be.true
      
      it "a new directory is created", ->
        path.existsSync("#{proj.path}/z").should.be.true
      
      it "it contains the child file", ->
        path.existsSync("#{proj.path}/z/q.txt").should.be.true
  
  
  describe "FsRepo#list", ->
    files = null
    before (done) ->
      proj.mkdir "list", ->
        proj.touch "list/f.txt", ->
          proj.mkdir "list/d", ->
            proj.list "list", (err, _files) ->
              files = _files
              done()
    
    it "includes the child file", ->
      files.should.include "f.txt"
    
    it "includes the child directory", ->
      files.should.include "d/"
    
    it "does not include a '.'", ->
      files.should.not.include "."
    
    it "does not include a '..'", ->
      files.should.not.include ".."
  
  
  describe "#listR", ->
    describe "simple", ->
      files = null
      before (done) ->
        proj.mkdir "list", ->
          proj.touch "list/f.txt", ->
            proj.mkdir "list/d", ->
              proj.listR "list", (_files) ->
                files = _files
                done()
      
      it "lists files and directories recursively", ->
        files.should.include "list/f.txt"
        files.should.include "list/d/"
    
    describe "exclude directories", ->
      files = null
      before (done) ->
        proj.mkdir "list", ->
          proj.touch "list/f.txt", ->
            proj.mkdir "list/d", ->
              proj.listR "list", (_files) ->
                files = _files
                done()
              , true
      
      it "lists only files recursively", ->
        files.should.include "list/f.txt"
        files.should.not.include "list/d/"
  
  
  describe "FsRepo#mkdir", ->
    before (done) ->
      proj.mkdir "some_dir", done
    
    it "creates the directory", ->
      path.existsSync("#{proj.path}/some_dir").should.be.true
  
  
  describe "FsRepo#isDirectory", ->
    describe "directory", ->
      before (done) ->
        proj.mkdir "d_foo", done
      
      it "is true", (done) ->
        proj.isDirectory "d_foo", (isDir) ->
          isDir.should.be.true
          done()
    
    describe "file", ->
      before (done) ->
        proj.touch "f_foo.txt", done
      
      it "is false", (done) ->
        proj.isDirectory "f_foo.txt", (isDir) ->
          isDir.should.be.false
          done()
  
  describe "FsRepo#isDirectorySync", ->
    describe "directory", ->
      before (done) ->
        proj.mkdir "d_foo", done
      
      it "is true", ->
        proj.isDirectorySync("d_foo").should.be.true
    
    describe "file", ->
      before (done) ->
        proj.touch "f_foo.txt", done
      
      it "is false", ->
        proj.isDirectorySync("f_foo.txt").should.be.false
  
  
  describe "FsRepo#touch", ->
    describe "the file does not exist", ->
      before (done) ->
        proj.touch "fool.txt", done
      
      "creates the file": ->
        path.existsSync("#{proj.path}/fool.txt").should.be.false
    
    describe "the file already exists", ->
      before (done) ->
        fs.writeFileSync "#{ proj.path }/touchtouch.txt", "Hello world"
        proj.touch "touchtouch.txt", done
      
      it "does not overwrite the old data", ->
        data = fs.readFileSync("#{proj.path}/touchtouch.txt").toString()
        data.should.eql "Hello world"
  
  describe "FsRepo#read", ->
    describe "a valid file", ->
      data = null
      before (done) ->
        fs.writeFileSync "#{ proj.path }/bar.txt", "Hello world"
        proj.read "bar.txt", (err, _data) ->
          data = _data
          done()
      
      it "reads the data from the file", ->
        data.should.eql "Hello world"
    
    describe "a nonexistant file", ->
      data = null
      err  = null
      before (done) ->
        proj.read "bar22.txt", (_err, _data) ->
          data = _data
          err  = _err
          done()
      
      it "does not throw", ->
        should.not.exist data
      
      it "passes an error", ->
        should.exist err
  
  
  describe "FsRepo#write", ->
    before (done) ->
      proj.write "pizza.txt", "Hello world", done
    
    it "writes the data to the file", ->
      data = fs.readFileSync "#{ FS_ROOT }/pizza.txt"
      data.toString().should.eql "Hello world"
  
  
  describe "FsRepo#_clean", ->
    it "resolves ./", ->
      proj._clean("./x/y.z").should.not.match /[.]\//
    
    it "resolves ../", ->
      proj._clean("x/y/../x/../../y.z").should.not.match /[.]{2}/
    
    describe "root directories", ->
      dir = proj._clean("/etc")
      
      it "resolve locally to the project", ->
        dir.should.match /etc$/
      
      "does not access the root directory": (dir) ->
        dir.should.not.matcj /^\/etc/
    
    describe "security violations throw an error", ->
      it "traverse up", ->
        should.throws ->
          proj._clean("../x")
        , Error
      
      it "traversing down then up up", ->
        should.throws ->
          proj._clean("x/../..")
        , Error

