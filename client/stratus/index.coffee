config = require('./config')

module.exports = window.stratus =
  ui:       require('./ui')
  bundle:   require('./bundle')
  fractus:  require('./fractus')
  fs:       require('./fs')
  open:     require('./open')
  
  on:    (a, b) -> config.on(a, b)
  emit:  (a, b) -> config.emit(a, b)
  isset: (a, b) -> config.isset(a, b)
