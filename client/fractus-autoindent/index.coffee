# Public: Register a plugin to automatically indent or outdent lines.
# 
# Returns nothing.
module.exports = autoindent = (conf) ->
  # Autoindent on enter.
  unless conf.isset "fractus.key.\n"
    conf.on "fractus.key.\n", "fractus.autoindent.indent"
  # Newline without autoindent.
  unless conf.isset "fractus.key.Shift-\n"
    conf.on "fractus.key.Shift-\n", (edt) -> edt.cursor.insert("\n")
  
  conf.on "fractus.key", "fractus.autoindent.outdent"
  
  conf.on "fractus.autoindent.indent", (edt) ->
    newline edt.buffer, edt.cursor, edt.tab, edt.syntax?.indent
    return false
  
  conf.on "fractus.autoindent.outdent", (data) ->
    {edt, key} = data
    return unless key.length == 1
    setTimeout ->
      tryOutdent edt.buffer, edt.cursor, edt.tab, edt.syntax?.outdent
    , 0


# Internal: Autoindent from a newline.
# Indentation is preserved, and increased if the bundle's indentation
# pattern matches the line.
# 
# buffer   - A Buffer
# cursor   - A Cursor
# tab      - The tab characters (String).
# indentRe - When this RegExp matches the current line, the next line
#            should be indented (optional).
# 
# Returns nothing.
autoindent.newline = newline = (buffer, cursor, tab, indentRe=null) ->
  cursor.toPoint()
  {row, col} = cursor.point
  line       = buffer.text(row).substr 0, col
  indent     = /^\s*/.exec(line)[0]
  
  # Extra indent according to the bundle.
  indent += tab if indentRe?.test line
  
  cursor.insert "\n#{indent}"


# Internal: If the line matches the outdent regex, outdent the line.
# 
# buffer    - A Buffer
# cursor    - A Cursor
# tab       - The tab characters (String).
# outdentRe - When this RegExp matches the current line, the line
#             should be outdented.
#             
#             This RegExp should **always** match against the end of the line
#             (the last character of the pattern should be `$`).
# 
# Returns nothing.
autoindent.tryOutdent = tryOutdent = (buffer, cursor, tab, outdentRe) ->
  return unless cursor.point
  return unless outdentRe
  {row, col} = cursor.point
  line       = buffer.text row
  matches    = col == buffer.lineLength(row) && outdentRe.test(line)
  return unless matches
  cursor.outdent tab

