ui          = require 'stratus-ui'
{tabs}      = require '../ui'
diffsToHTML = require './diff'

# Public: Open the Git commit dialog.
# 
# Returns Dialog.
module.exports = ->
  new GitCommit()


class GitCommit
  constructor: ->
    @getStatus (res) =>
      {@status, @diffs} = res
      tabs "git-commit", @statusToHTML()
  
  
  # callback - Receives `(err, {status, diffs})`
  getStatus: (callback) ->
    $.getJSON "/#{window.data.project.path}/commit"
    , (data, status, xhr) ->
      callback data
  
  # Convert the status and diffs to a commit form.
  # 
  # Returns String HTML.
  statusToHTML: ->
    {branch}       = window.data.project.git
    statusFiles    = Object.keys @status
    statusFileHTML = []
    for filename, file of @status
      statusFileHTML.push @statusFileToHTML(filename, file)
      
    
    """<div class="stratus-git-commit">
        <div class="body">
          <button class="stratus-git-commit-changes primary">Commit Changes</button>
          <h1>Committing to <b>#{branch}</b></h1>
          <div class="stratus-git-commit-message">
            <input type="text" placeholder="Commit Summary"/>
            <textarea placeholder="Extended description"></textarea>
          </div>
          
          <ul class="stratus-git-commit-unstaged">
            <li class="stratus-git-commit-all">
              <label>
                <input type="checkbox" checked/>
                <h1>Select All</h1>
              </label>
            </li>
            #{statusFileHTML.join("")}
          </ul>
        </div>
        #{diffsToHTML(@diffs)}
      </div>"""
  
  statusFileToHTML: (filename, file) ->
    if !file.tracked || file.type == "A"
      stat = "<span class='create'>New</span>"
    else if file.type == "D"
      stat = "<span class='delete'>Delete</span>"
    else
      stat = ""
    "<li><label>
      <input type='checkbox' checked/>
      <span>#{filename}</span>
      #{stat}
    </label></li>"


# Internal: Get the String commit message.
commitMessage = ($commit) ->
  $message = $commit.find(".stratus-git-commit-message")
  return $message.children(":first").val() +
         "\n" +
         $message.children(":last").val()

# Internal: Commit the code.
postCommit = ($commit, callback) ->
  files   = $commit.find(".stratus-git-commit-unstaged:first").children().filter ->
    return !!$(this).find("input:checked").length && !/Select All/.test(this.innerText)
  files   = _.map files, ((f) -> f.innerText.trim())
  message = commitMessage($commit).trim()
  if !files.length
    alert "You must stage at least 1 file."
  else if !message
    alert "Commit message is required."
  else
    $.post "/#{window.data.project.path}/commit",
      commit: {files, message}
    , (data, status, xhr) ->
      callback data


jQuery ($) ->
  # Commit the code.
  $(document).on "click", ".stratus-git-commit-changes", ->
    $commit = $(this).closest ".stratus-git-commit"
    postCommit $commit, (data) ->
      $tab = tabs.tabs[$commit.attr("id")]
      tabs.close $tab
  
  
  # Toggle the select all files checkbox.
  $(document).on "change", ".stratus-git-commit-all input", ->
    $all   = $ this
    $diffs = $all.closest(".stratus-git-commit").children(".stratus-git-diffs")
    $files = $all.closest("ul").find("input")
    if $all.is(":checked")
      $files.attr "checked", true
      $diffs.children().show()
    else
      $files.attr "checked", false
      $diffs.children().hide()
  
  
  # Toggle a file.
  $(document).on "change", ".stratus-git-commit-unstaged input", ->
    $file = $ this
    return if $file.closest("li").hasClass "stratus-git-commit-all"
    path = $file.closest("li").find("span:first").text()
    return if /\/$/.test path
    $commit = $file.closest(".stratus-git-commit")
    $diffs  = $commit.children(".stratus-git-diffs")
    $diff   = diffsToHTML.find$diff $diffs, path
    # Show the diff.
    if $file.is(":checked")
      $diff?.slideDown()
      $diff?.next().slideDown()
    # Hide the diff.
    else
      $commit.find(".stratus-git-commit-all input").attr "checked", false
      $diff?.slideUp()
      $diff?.next().slideUp()
    return
