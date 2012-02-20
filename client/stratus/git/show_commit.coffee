{tabs}      = require '../ui'
dateTools   = require './date'
diffsToHTML = require './diff'

projectPath = window.data.project.path

# Public: Open the commit in a new tab.
module.exports = (commitId) ->
  getCommit commitId, (commit) ->
    html = $ commitToHTML commit
    tabs commitId[0..6], html


# Internal: Get the commit and its diffs from the server,
# and pass it into the callback.
getCommit = (commitId, callback) ->
  $.getJSON "/#{projectPath}/commit/#{commitId}.json", (commit, status, xhr) ->
    commit.committed_date = new Date commit.committed_date
    commit.authored_date  = new Date commit.authored_date
    callback commit


# Internal: Convert the commit to HTML.
# 
# Returns String.
commitToHTML = (commit) ->
  date = commit.authored_date
  if dateTools.isToday date
    time = dateTools.getTime date
  else
    time = dateTools.toString date
  messageLines = commit.message.split "\n"
  """<div class="stratus-git-show-commit" data-commit-id="#{commit.id}">
      <img src="https://secure.gravatar.com/avatar/#{commit.author.hash}" draggable="false"/>
      <header>
        <h3 class="stratus-git-sha">#{commit.id}</h3>
        <h1>#{commit.author.name}</h1>
        <h2>#{time}</h2>
        <p>#{messageLines[0]}</p>
      </header>
      <p>#{messageLines[1..-1].join("<br/>")}</p>
      <div class="stratus-git-diffs-wrapper">
        <!--<button class="stratus-git-revert">Revert commit</button>
        <button class="stratus-git-rollback">Rollback to this commit</button>-->
        #{diffsToHTML(commit.diffs)}
      </div>
    </div>"""



