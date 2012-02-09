# Events:
# 
#   * stratus.fs.touch
#   * stratus.fs.mkdir
# 

{tree, dialog, validate} = require 'stratus-ui'

fs             = require '../../fs'
templates      = require('../templates').file_manager
{EventEmitter} = require 'events'
touch_dialog   = require './touch_dialog'
mkdir_dialog   = require './mkdir_dialog'
open           = require '../../open'

conf           = require '../../config'

fileTree = null
conf.on "stratus.fs.touch", ->
  FileActions.NewFile window.data.project.path, fileTree, ""

conf.on "stratus.fs.mkdir", ->
  FileActions.NewDir window.data.project.path, fileTree, ""


# Replace $el with a file manager.
# 
# $el         - The element that will be replaced by the tree.
# projectPath - ":username/:projectName", such as "dj/stratus".
# rootFiles   - The initial files to populate the top level of the tree
#               (optional).
# 
# Events:
# 
#   * touch - {tree, path, language}
#   * mkdir - {tree, path}
#   * move  - {tree, fromPath, toPath, language}
# 
# Return an instance of Tree.
module.exports = file_manager = ($el, projectPath, rootFiles = null) ->
  # TODO
  # rootFiles ||= ...
  files = sortFiles rootFiles
  t     = fileTree = tree filesToLeaf(files), (text, path) ->
    open path
  
  , (text, path, callback) ->
    fs.list projectPath, path, (files) ->
      return callback filesToLeaf sortFiles(files)
  
  t.contextmenu (path, leaf) ->
    if leaf.isExpandable
      return dirContextMenu projectPath, t, path
    else
      return fileContextMenu projectPath, t, path
  
  $el.replaceWith t.$root
  return t


sortFiles = (files) ->
  return _.sortBy files, ((f) -> f.name)


# Returns [dir, fileName]
parsePath = (path) ->
  trailingSlash = new RegExp "/$"
  parts         = path.replace(trailingSlash, "").split("/")
  dir           = parts[0..-2].join "/"
  fileName      = _.last parts
  isDir         = !!path[path.length - 1] == "/"
  fileName     += "/" if isDir
  return [dir, fileName]

# Update the file tree when changes are made to the project's files.
_.extend file_manager, EventEmitter.prototype

file_manager.on "touch", (data) ->
  {tree, path, language} = data
  [dir, fileName]        = parsePath path
  tree.findLeaf(dir).addLeaf fileToLeaf {name: fileName, language}

file_manager.on "move", (data) ->
  {tree, fromPath, toPath, language} = data
  tree.removeLeaf fromPath
  [dir, fileName] = parsePath toPath
  tree.findLeaf(dir).addLeaf fileToLeaf {name: fileName, language}

file_manager.on "copy", (data) ->
  {tree, fromPath, toPath, language} = data
  [dir, fileName] = parsePath toPath
  tree.findLeaf(dir).addLeaf fileToLeaf {name: fileName, language}

file_manager.on "mkdir", (data) ->
  {tree, path}    = data
  [dir, fileName] = parsePath path
  tree.findLeaf(dir).addLeaf fileToLeaf {name: fileName + "/"}


# Using the file name, create a leaf object. If the file name has a trailing
# slash, it is assumed to be a directory.
# 
# file - String, such as "client.js" or "server/".
# 
# Examples
# 
#   fileToLeaf {name: "client/",}
#   # => {text: "client", icon: ".../directory.png", isExpandable: true}
# 
#   fileToLeaf {name: "server.js", language: "JavaScript"}
#   # => {text: "server.js", icon: ".../javascript.png", isExpandable: false}
# 
# Return a leaf object with properties `text`, `icon`, and `isExpandable`.
file_manager.fileToLeaf = fileToLeaf = (file) ->
  isDirectory = _.last(file.name) == "/"
  fileName    = file.name.replace /\/$/, ""
  icon        = getIcon(file.language || isDirectory)
  return {
    text:         fileName
    icon:         icon
    isExpandable: isDirectory
  }


# Public: Get the icon associated with the given language.
# If language is `true`, a directory icon will be returned.
# 
file_manager.icon = getIcon = (language) ->
  if language == true
    "/images/icons/directory.png"
  else if language
    "/bundles/#{language}/icon.png"
  else
    "/images/icons/unknown.png"


file_manager.Clipboard = class Clipboard
  @path:   null
  @isCopy: false
  @isCut:  false
  
  @copy: (@path) ->
    @isCopy = true
    @isCut  = false
  
  @cut: (@path) ->
    @isCut  = true
    @isCopy = false
  

# Map fileToLeaf over many files and return the list of leaves created.
filesToLeaf = (files) ->
  return _.map files, fileToLeaf


fileContextMenu = (projectPath, tree, path) ->
  return [
    { text: "Rename"
    , click: -> FileActions.Rename projectPath, tree, path
    }
    { text: "Delete"
    , click: -> FileActions.Delete projectPath, tree, path
    }
    {}
    { text: "Copy"
    , click: -> FileActions.Copy projectPath, tree, path
    }
    { text: "Cut"
    , click: -> FileActions.Cut projectPath, tree, path
    }
  ]

dirContextMenu = (projectPath, tree, path) ->
  return [
    { text:  "New file"
    , click: -> FileActions.NewFile projectPath, tree, path
    }
    { text:  "New directory"
    , click: -> FileActions.NewDir projectPath, tree, path
    }
    {}
    { text:  "Rename"
    , click: -> FileActions.Rename projectPath, tree, path
    }
    { text: "Delete"
    , click: -> FileActions.Delete projectPath, tree, path
    }
    {}
    { text: "Copy"
    , click: -> FileActions.Copy projectPath, tree, path
    }
    { text: "Cut"
    , click: -> FileActions.Cut projectPath, tree, path
    }
    { text: "Paste into"
    , click: -> FileActions.Paste projectPath, tree, path
    }
  ]


onErr = (err) ->
  console.error err if err

file_manager.FileActions = FileActions =
  Rename: (projectPath, tree, path) ->
    tree.editLeaf path, (newText, oldText) ->
      dir    = path.split("/")[0..-2].join "/"
      toPath = "#{dir}/#{newText}"
      fs.move projectPath, path, toPath, (err, data) ->
        onErr err
        leaf = tree.findLeaf toPath
        icon = getIcon data.language || leaf.isExpandable
        leaf.setIcon icon
  
  Delete: (projectPath, tree, path) ->
    fs.delete projectPath, path, (err) ->
      return onErr err if err
      tree.removeLeaf path
  
  NewFile: (projectPath, tree, path) ->
    touch_dialog projectPath, path, (newPath, language) ->
      file_manager.emit "touch",
        tree:     tree
        path:     newPath
        language: language
  
  NewDir: (projectPath, tree, path) ->
    mkdir_dialog projectPath, path, (newPath) ->
      file_manager.emit "mkdir",
        tree: tree
        path: newPath
  
  Copy: (projectPath, tree, path) ->
    Clipboard.copy path
  
  Cut: (projectPath, tree, path) ->
    Clipboard.cut path
  
  Paste: (projectPath, tree, path) ->
    fromPath = Clipboard.path
    return alert "No file is on the clipboard" unless fromPath
    parts    = fromPath.split("/")
    fileName = _(parts).last()
    toPath   = "#{path}/#{fileName}"
    event    = if Clipboard.isCopy then "copy" else "move"
    
    fs[event] projectPath, fromPath, toPath, (err, data) ->
      if Clipboard.isCut
        Clipboard.copy toPath
        file_manager.emit "move",
          tree:     tree
          fromPath: fromPath
          toPath:   toPath
          language: data.language
      else
        file_manager.emit "copy",
          tree:     tree
          fromPath: fromPath
          toPath:   toPath
          language: data.language

