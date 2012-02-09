
# Public: Register a plugin to autocomplete from the cursor position.
# 
# Returns nothing.
module.exports = autocomplete = (conf) ->
  key = window.data.config["fractus.autocomplete"]
  if key
    conf.on "fractus.key.#{key}", "fractus.autocomplete"
  
  conf.on "fractus.autocomplete", (edt) ->
    return unless point = edt.cursor.point
    
    word     = edt.buffer.wordAt point
    wordText = word.text()
    return unless word.isSolid
    prefix   = wordText.substr 0, point.col - word.begin.col
    
    if edt.syntax
      suffix = autocomplete.words prefix, edt.syntax.completions || []
    if !suffix
      suffix = autocomplete.buffer prefix, edt.buffer, point.row, wordText
    
    if suffix
      #edt.cursor.moveTo word.end
      edt.cursor.insert suffix
    return



# Public: Complete the `prefix` by returning the suffix that
# should be appended to it.
# 
# prefix      - The String word the complete.
# completions - A *sorted* list of string words to complete with.
# 
# Examples
# 
#   autocomplete "foo", ["foobar", "barbaz", "Foo.Bar"].sort()
#   # => "bar"
# 
#   autocomplete "foo", ["cheese.foobar", "barbaz", "Foo.Bar"].sort()
#   # => ""
# 
# Return a String suffix, or "" when no match is found.
autocomplete.words = (prefix, completions) ->
  # Check the completions.
  fullWord = null
  low      = 0
  high     = completions.length
  mid      = null
  {length} = prefix
  while low < high
    mid      = (high + low) >> 1
    fullWord = completions[mid]
    if fullWord.substr(0, length) == prefix && fullWord != prefix
      return fullWord.substr length
    
    if fullWord < prefix
      low  = mid + 1
    else
      high = mid
  
  return ""


# Public: Complete the prefix.
# 
# prefix - String
# buffer - Buffer
# row    - The row to begin searching from. After searching `row`, previous
#          rows are searched backward, then following ones forward.
# except - A word that it cannot match. (String).
# 
# Return a String suffex, or "" when no match is found.
autocomplete.buffer = (prefix, buffer, row, except) ->
  anchorRow = row
  re        = new RegExp "\\b#{ prefix }([a-zA-Z_-]+)"
  
  # Search the given row.
  word = re.exec(buffer.text(row))?[1]
  if word && (prefix + word != except)
    return word
  
  # Search previous rows.
  while row-- >= 0
    word = re.exec(buffer.text(row))?[1]
    if word && (prefix + word != except)
      return word
  
  # Search the previous rows.
  max = buffer.lineCount()
  while anchorRow++ < max
    word = re.exec(buffer.text(anchorRow))?[1]
    if word && (prefix + word != except)
      return word
  
  return ""

