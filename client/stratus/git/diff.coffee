# Public: Convert an Array of Diffs to HTML.
# 
# Returns String.
module.exports = DiffsToHTML = (diffs) ->
  html = ["<ul class='stratus-git-diffs'>"]
  for diff in diffs
    if diff.new_file
      stat = "<span class='status-git-diff-add' title='New file'>+</span>"
    else if diff.deleted_file
      stat = "<span class='status-git-diff-rm' title='Deleted file'>-</span>"
    else
      stat = ""
    html.push """
      <li class="stratus-git-diff-path"><span>#{diff.a_path}</span>#{stat}</li>
      <li class="stratus-git-diff-data">
        <table><tbody>
          #{diffRows(diff)}
        </tbody></table>
      </li>
    """
  html.push "</ul>"
  return html.join ""


# Public: Find the diff path list item with the given path.
# 
# Returns jQuery element or null.
DiffsToHTML.find$diff = ($diffs, path) ->
  $diff = null
  $diffs.children(".stratus-git-diff-path").each ->
    return if $diff
    $d = $ this
    if $d.children(":first").text() == path
      $diff = $d
  return $diff


# Internal: Convert the +-@ lines into HTML table rows.
# 
# Returns String.
diffRows = (diff) ->
  lines = escapeForHTML(diff.diff).split "\n"
  if /Binary files /.test lines[0]
    return "<tr><td>#{diff.diff}</td></tr>"
  
  html  = [
    """<tr>
      <td class="sgg head">Old</td>
      <td class="sgg head">New</td>
      <td class="stratus-diff-comment">#{lines[2]}</td>
    </tr>"""]
  
  [oldLine, newLine] = parseComment lines[2]
  for line in lines[3..-1]
    html.push "<tr>"
    if line.substr(0, 2) == "@@"
      [oldLine, newLine] = parseComment line
      html.push """
        <td class="sgg">...</td>
        <td class="sgg">...</td>
        <td class="stratus-diff-comment">#{line}</td>"""
    else if line[0] == "+"
      html.push """
        <td class="sgg"></td>
        <td class="sgg"'>#{newLine++}</td>
        <td class="stratus-diff-insert">#{line}</td>"""
    else if line[0] == "-"
      html.push """
        <td class="sgg">#{oldLine++}</td>
        <td class="sgg"'></td>
        <td class="stratus-diff-delete">#{line}</td>"""
    else
      html.push """
        <td class="sgg">#{oldLine++}</td>
        <td class="sgg"'>#{newLine++}</td>
        <td>#{line}</td>"""
    html.push "</tr>"
  return html.join ""


# Internal: Parse the "@@...@@" comment to get the line numbers.
# 
# Examples
# 
#   parseComment "@@ -22,8 +16,7 @@ module.exports = (app) ->"
#   # => [22, 16]
# 
# Returns Array [oldLine, newLine].
parseComment = (comment) ->
  [m, oldL, newL] = /[-]([0-9]+).+?[+]([0-9]+).+@@/.exec comment
  return [+oldL, +newL]

# Internal: Replace "<" with "&lt;"; etc.
# 
# Returns String.
escapeForHTML = (text) ->
  text.replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")


jQuery ($) ->
  $(document).on "click", ".stratus-git-diff-path", ->
    $path = $ this
    $file = $path.next()
    if $file.is(":visible")
      $file.slideUp()
    else
      $file.slideDown()

