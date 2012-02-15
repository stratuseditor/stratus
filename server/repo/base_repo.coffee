fs   = require 'fs'
path = require 'path'

class BaseRepo
  constructor: (options) ->
    # The name of the project, such as "Stratus".
    { @name
    # A path for use of the project implementations.
      @path
    # Either "fs", ...
      @protocol
    } = options
  
  # #### OVERRIDE THESE ####
  
  # Delete the file or directory at the given path.
  # For directories this is *recursive*.
  # 
  # filepath - the path of the file or directory to delete
  # callback - A function called on completion (optional).
  # 
  # Examples
  # 
  #   proj.delete "some/file"
  # 
  # No return value.
  delete: (file, callback) ->
  
  # Move the file or directory.
  # 
  # fromPath - the start location.
  # toPath   - the end location.
  # callback - called upon completion.
  # 
  # Examples
  # 
  #   proj.move "some/file", "other/place", (err) ->
  #     console.log "I've done it!" unless err
  # 
  # No return value.
  move: (fromPath, toPath, callback) ->
  copy: (fromPath, toPath, callback) ->
  
  # Check if the given file exists.
  # 
  # filepath - the path of the file or directory to check.
  # 
  # Examples
  # 
  #   proj.exists "README", (ex) ->
  #     ex # => true
  # 
  #   proj.exists "a-body-under-my.bed", (ex) ->
  #     ex # => false
  # 
  # Return boolean.
  exists: (file, callback) ->
  
  # Directories methods
  
  # Public: Make a new directory at the given path if one does not already exist.
  # 
  # dirpath  - the path of the new directory
  # callback - A function called on completion (optional).
  # 
  # Examples
  # 
  #   proj.mkdir "some/dir"
  # 
  # No return value.
  mkdir: (dirpath, callback) ->
  
  # Public: List the files and directories in the directory.
  # A list of strings will be returned. Child directories can be identified
  # by a trailing forward slash in the name.
  # 
  # dirpath  - the path of the directory
  # callback - the callback which receives `(err, files)`
  # 
  # Examples
  # 
  #   # For these examples, assume the following directory structure:
  #   # proj/
  #   #   dir/
  #   #     bar.txt
  #   #     baz.js
  #   #     foo/
  # 
  #   proj.list "dir", (err, files) ->
  #     # files => [ "bar.txt"
  #                , "baz.js"
  #                , "foo/"
  #                ]
  # 
  list: (dirpath, callback) ->
  
  # Public: List recursively.
  listR: (dirpath, callback, excludeDirs=false) ->
  
  # Public: Check whether or not the given path is a directory.
  # 
  # dirpath - the path to the directory to check (relative to the project root)
  # 
  # Examples
  # 
  #   proj.isDirectory "something", (isDir) ->
  #     isDir # => false
  # 
  # Returns boolean
  isDirectory: (dirpath, callback) ->
  
  # File methods
  
  # Public: Touch a path, creating a new file if it does not already exist.
  # 
  # file     - The path for the new file.
  # callback - A function called on completion (optional).
  # 
  # Examples
  # 
  #   proj.touch "some/file.py"
  # 
  # No return value.
  touch: (file, callback) ->
  
  # Public: Read the file, and pass it's contents into the callback as a string.
  # 
  # file     - the path of the file to read, relative to the project root
  # callback - receives `(err, data)` when the read is complete.
  # 
  # Examples
  # 
  #   proj.read "some/file.py", (err, data) ->
  #     console.log data unless err
  # 
  # No return value.
  read:  (file, callback) ->
  
  # Public: Write the data to the file.
  # 
  # file     - the path of the file to write to
  # data     - the data to write to the file, as a string
  # callback - receives `(err)` when the write completes
  # 
  # Examples
  # 
  #   proj.write "some/file.txt", "look, a ladybug!", (err) ->
  #     console.log "It worked!" unless err
  # 
  # No return value.
  write: (file, data, callback) ->

module.exports = BaseRepo
