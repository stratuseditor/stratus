{EventEmitter} = require 'events'

class Emitter
  constructor: ->
    @emitter = new EventEmitter()
    @emitter.setMaxListeners 0
  
  on: (scope, event) ->
    if typeof event == "function"
      @emitter.on scope, (data) =>
        event data
    else
      @emitter.on scope, (data) =>
        if @isset(event)
          return @emit event, data
        else
          return true
  
  emit: (scope, data) ->
    return @emitter.emit scope, data
  
  isset: (scope) ->
    return !!@emitter.listeners(scope).length


module.exports = conf = new Emitter()

config = null
jQuery -> {config} = window.data

# Override annoying browser defaults.
# ---------------------------------------------------------
conf.on "ignore", (-> false)

# In Chrome these are forward/back buttons.
conf.on "fractus.key.Alt-Left",  "ignore"
conf.on "fractus.key.Alt-Right", "ignore"

window.onbeforeunload = ->
  unless config["redirect"]
    return "Did you mean to do that?"


# Load default plugins.
# ---------------------------------------------------------
require('../fractus-autocomplete') conf
require('../fractus-autoindent')   conf
require('../fractus-autopair')     conf

