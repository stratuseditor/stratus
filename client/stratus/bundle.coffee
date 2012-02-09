color = require 'stratus-color'

cache = {}

# Public: Get the bundle and put it in the callback.
# 
# bundleName - A String such as "JavaScript" or "Ruby.Rails.Model".
# callback   - A function which receives `(bundle)`.
# 
# Examples
# 
#   bundle = require 'bundle'
#   bundle "Ruby", (err, ruby) ->
#     throw err if err
#     ruby
#     # =>
#     # { "name":         "Ruby"
#     # , "syntax":       {...}
#     # , "autocomplete": ["..."]
#     # , ...
#     # }
# 
# Returns nothing.
module.exports = bundle = (bundleName, callback) ->
  bundleName ||= "Text"
  return callback null, b if b = cache[bundleName]
  
  $.getJSON "/bundles/#{bundleName}.json",
  (data, status, xhr) ->
    color.addScopes data.syntax if data.syntax
    data.indent       = new RegExp data.indent  if data.indent
    data.outdent      = new RegExp data.outdent if data.outdent
    cache[bundleName] = data
    
    if data.require?.length
      i = 0
      for bName in data.require
        bundle bName, (err, b) ->
          i += 1
          i  = data.require.length if err
          return unless i >= data.require.length
          callback err, data
    else
      callback null, data


# Public: Get a list of the installed bundles.
# 
#   bundle.list()
#   # => [..., "Ruby", "Ruby.Rails", "Ruby.Rails.Controller", ...]
# 
# Returns nothing.
bundle.list = ->
  return window.data.bundles
