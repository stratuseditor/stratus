_            = require 'underscore'
{Region}     = require 'fractus/src/buffer'
PAIR_OPENERS = ("({['`<" + '"').split('')
PAIR_CLOSERS = (")}]'`>" + '"').split("")

OPENERS =
  "(": "Shift-9"
  "{": "Shift-["
  "<": "Shift-,"
  '"': "Shift-'"
  "[": "["
  "'": "'"
  "`": "`"

OPEN_MATCH =
  "(": ")"
  "[": "]"
  "{": "}"
CLOSE_MATCH =
  ")": "("
  "]": "["
  "}": "{"

# Public: Register a plugin to automatically complete character pairs.
# 
# Returns nothing.
module.exports = autopair = (conf) ->
  config = null
  jQuery -> {config} = window.data
  
  ##
  # Both openers and closers, such as `, ", '.
  for char in _.intersection(PAIR_OPENERS, PAIR_CLOSERS)
    do (char) ->
      conf.on "fractus.key.#{char}", (edt) ->
        if edt.cursor.point && nextChar(edt.buffer, edt.cursor) == char
          edt.cursor.moveRight()
        else
          conf.emit "fractus.autopair", {edt, key: char}
  
  ##
  # Only openers: (, [, {
  for char in _.difference(PAIR_OPENERS, PAIR_CLOSERS)
    do (char) ->
      conf.on "fractus.key.#{char}", (edt) ->
        conf.emit "fractus.autopair", {edt, key: char}
  
  ##
  # Only closers: ), ], }
  for char in _.difference(PAIR_CLOSERS, PAIR_OPENERS)
    do (char) ->
      conf.on "fractus.key.#{char}", (edt) ->
        conf.emit "fractus.autopair.close", {edt, key: char}
  
  ##
  # Insert the character *without* autopairing.
  for char, key of OPENERS
    do (char) ->
      conf.on "fractus.key.Alt-#{key}", (edt) ->
        edt.cursor.insert char
  
  
  conf.on "fractus.autopair", (data) ->
    {edt, key} = data
    bundle     = edt.syntax
    close      = config["fractus.pairs@#{bundle.name}"]?[key]
    close     ?= bundle.pairs[key]
    close     ?= config["fractus.pairs"]?[key]
    if !close
      edt.cursor.insert key
      return false
    {buffer, cursor} = edt
    
    if cursor.region
      surround edt.buffer, edt.cursor, key, close
    else
      cursor.insert key + close
      cursor.moveLeft()
    return false
  
  
  conf.on "fractus.autopair.close", (data) ->
    {edt, key}  = data
    bundle      = edt.syntax
    closeChars  = _.union _.values(config["fractus.pairs@#{bundle.name}"]),
                          _.values(config["fractus.pairs"]),
                          _.values(bundle.pairs)
    
    isCloseChar = ~closeChars.indexOf key
    if isCloseChar
      close edt.buffer, edt.cursor, key
    else
      edt.cursor.insert key
  
  
  conf.on "fractus.cursor.move", (edt) ->
    return unless config["fractus.pairs.match"]
    # Clear the previous matches.
    $(".fractus-autopair-match").remove()
    
    {buffer, cursor} = edt
    point            = cursor.point || cursor.region.end
    char             = buffer.text point.row, point.col - 1
    if OPEN_MATCH[char]
      region = autopair.matchForward buffer, cursor, char
      return unless region
      edt.emphasize region, "fractus-autopair-match"
    else if closeChar = CLOSE_MATCH[char]
      region = autopair.matchBackward buffer, cursor, closeChar
      return unless region
      edt.emphasize region, "fractus-autopair-match"


# Internal: Surround the selected text with `beginChar` and `endChar`.
# 
# Returns nothing.
autopair.surround = surround = (buffer, cursor, beginChar, endChar) ->
  {begin, end} = cursor.region.ordered()
  buffer.insert endChar, end.row, end.col
  buffer.insert beginChar, begin.row, begin.col
  
  if begin.row == end.row
    offset = 1
  else
    offset = 0
  
  {col} = end
  cursor.moveTo end.row, col + offset


# Internal: Get the next character after the cursor.
# 
# Returns a character.
nextChar = (buffer, cursor) ->
  cursor.toPoint()
  {row, col} = cursor.point
  return buffer.text row, col


# Internal: Close or move over a closing character.
# 
# Returns nothing.
autopair.close = close = (buffer, cursor, endChar) ->
  # Advance cursor; dont insert
  if nextChar(buffer, cursor) == endChar
    cursor.moveRight()
  # Insert char
  else
    cursor.insert endChar


# Internal: Find the matching close pair character.
# 
# buffer   - A Buffer.
# cursor   - A Cursor.
# openChar - `"("`, `"["`, or `"{"`.
# 
# Examples
# 
#   "H(|ello,( w)orld[)]"
#   # => "H[(]ello,( w)orld)"
# 
#   "H|(ello,( w)orld)"
#   # => "H(ello,( w)orld)"
# 
# Returns a Region of length 1.
autopair.matchForward = (buffer, cursor, openChar) ->
  closeChar  = OPEN_MATCH[openChar]
  nested     = 0
  {row, col} = cursor.point || cursor.region.end
  lineCount  = buffer.lineCount()
  while row < lineCount
    line = buffer.text(row).substr(col)
    for char, i in line
      if char == openChar
        nested++
      else if char == closeChar
        if nested
          nested--
        else
          begin = buffer.point row, col + i
          end   = buffer.point row, col + i + 1
          return new Region begin, end
    row++
    col = 0
  return null


# Internal: Find the matching open pair character.
# 
# buffer    - A Buffer.
# cursor    - A Cursor.
# openChar - `"("`, `"["`, or `"{"`.
# 
# Examples
# 
#   "H(ello,( w)orld)|"
#   # => "H[(]ello,( w)orld)"
# 
#   "H(ello,( w)orld|)"
#   # => "H(ello,( w)orld)"
# 
# Returns a Region of length 1.
autopair.matchBackward = (buffer, cursor, openChar) ->
  closeChar  = OPEN_MATCH[openChar]
  nested     = 0
  {row, col} = cursor.point || cursor.region.end
  col        = col - 1
  while row >= 0
    line = buffer.text(row).substr(0, col)
    while col >= 0
      char = line[col]
      if char == closeChar
        nested++
      else if char == openChar
        if nested
          nested--
        else
          begin = buffer.point row, col
          end   = buffer.point row, col + 1
          return new Region begin, end
      col--
    
    row--
    col = buffer.lineLength row
  return null

