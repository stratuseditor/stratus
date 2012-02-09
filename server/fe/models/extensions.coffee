fs     = require 'fs'
Path   = require 'path'
coffee = require 'coffee-script'
stylus = require 'stylus'
nib    = require 'nib'
{exec} = require 'child_process'
_      = require 'underscore'

# Public: Get a PluginRepo.
# 
# pluginsPath - The path to the `.stratus` directory to load the plugins from.
# 
# Returns a PluginRepo.
module.exports = extensions = (pluginsPath) ->
  return new PluginRepo pluginsPath


# Internal: Load the plugin at the given path.
# 
# pluginPath - A file or directory. If a directory, the `index.coffee`
#              or `index.js` file is loaded
# 
# Returns a String of JavaScript.
loadJSPlugin = (pluginPath) ->
  isDir = fs.statSync(pluginPath).isDirectory()
  if isDir
    if Path.existsSync("#{pluginPath}/index.js")
      return loadJSPlugin "#{pluginPath}/index.js"
    else if Path.existsSync("#{pluginPath}/index.coffee")
      return loadJSPlugin "#{pluginPath}/index.coffee"
    else
      return ""
  else if /\.coffee$/.test pluginPath
    data = fs.readFileSync(pluginPath).toString()
    return coffee.compile data, {filename: pluginPath}
  else if /\.js$/.test pluginPath
    return fs.readFileSync(pluginPath).toString()
  else
    return ""

# Internal: Load the stylesheets at the given path.
# 
# pluginPath - A file or directory. If a directory, the `index.styl`
#              or `index.css` file is loaded
# callback   - Receive `(err, css)`.
# 
loadCSSPlugin = (pluginPath, callback) ->
  isDir = fs.statSync(pluginPath).isDirectory()
  if isDir
    if Path.existsSync("#{pluginPath}/index.styl")
      loadCSSPlugin "#{pluginPath}/index.styl", callback
    else if Path.existsSync("#{pluginPath}/index.css")
      loadCSSPlugin "#{pluginPath}/index.css", callback
    else
      return callback null, ""
  else if /\.styl$/.test pluginPath
    data = fs.readFileSync(pluginPath).toString()
    stylus(data, {filename: pluginPath})
      .include(nib.path)
      .render(callback)
  else if /\.css$/.test pluginPath
    fs.readFile pluginPath, (err, data) ->
      return callback err, data?.toString()
  else
    return callback null, ""


class PluginRepo
  constructor: (@path) ->
  
  # Public: Install the plugin.
  # 
  # pluginPath - The path to the plugin to install.
  # callback   - Receives `(err)`.
  # 
  # Returns nothing.
  install: (pluginPath, callback) ->
    lastPart = _.last pluginPath.split("/")
    exec "cp -r '#{pluginPath}' '#{@path}/#{lastPart}'",
    (err, stdout, stderr) ->
      return callback err
  
  # Public: Compile the plugins at the given path for inclusion in the browser.
  # 
  # callback    - Receives `(err, jsCode)` where `jsCode` is a String of
  #               compiled JavaScript (optional).
  # 
  # Returns nothing.
  js: (callback) ->
    jsCode = ""
    fs.readdir @path, (err, files) =>
      return callback err if err
      for file in files
        jsCode += loadJSPlugin "#{@path}/#{file}"
      return callback null, jsCode
  
  
  # Public: Compile the stylesheets at the given path for inclusion in
  # the browser.
  # 
  # callback    - Receives `(err, cssCode)` where `cssCode` is a String of
  #               compiled CSS (optional).
  # 
  # Returns nothing.
  css: (callback) ->
    cssCode = ""
    fs.readdir @path, (err, files) =>
      return callback err if err
      i = files.length
      for file in files
        loadCSSPlugin "#{@path}/#{file}", (err, css) ->
          cssCode += css + "\n"
          i--
          return callback null, cssCode if !i

