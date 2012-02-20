{tabs}      = require '../ui'
show_commit = require './show_commit'
dateTools   = require './date'

projectPath = window.data.project.path



# Public: Open the Git commit dialog.
# 
# Returns Dialog.
module.exports = History = ->
  new GitHistory()


class GitHistory
  constructor: ->
    # The current 0-based page offset.
    @page       = 0
    @$container = $ """
        <div class="stratus-git-history">
        </div>
      """
    
    @$container.on "click", "li", ->
      show_commit $(this).data("commit-id")
    @$container.on "click", ".stratus-git-log-prev", => @prev()
    @$container.on "click", ".stratus-git-log-next", => @next()
    
    @loadCurrentPage =>
      tabs "git-history", @$container
  
  # Internal: Load the current page of commits into the @$container element.
  # The page is determined by @page.
  # 
  # callback - optional
  # 
  loadCurrentPage: (callback) ->
    getCommits @page, (commits) =>
      @$container.html GitHistory.commitsToHTML(commits, @page)
      callback?()
  
  # Internal: Page back to newer commits.
  prev: ->
    return unless @page
    @page--
    @loadCurrentPage()
  
  # Internal: Page forward to older commits.
  next: ->
    @page++
    @loadCurrentPage()
  
  # Internal: Convert an Array of Commits to HTML.
  # 
  # commits  - An Array of Commit objects.
  # page     - The 0-based page number.
  # 
  # Returns String HTML.
  @commitsToHTML: (commits, page) ->
    html = []
    date = null
    if page
      disable = ""
    else
      disable = " disabled"
    
    for commit in commits
      if date && dateTools.sameDay(commit.authored_date, date)
        html.push commitToListItem commit
      else
        html.push "</ul>" if date
        date = commit.authored_date
        pref = if dateTools.isToday(date) then "Today &bull; " else ""
        html.push """
            <time>#{pref}#{dateTools.toString(date)}</time>
            <ul class="stratus-git-log">
            #{commitToListItem(commit)}
          """
    html.push """
        </ul>
        <footer>
          <nav>
            <button class="stratus-git-log-prev#{disable}">&larr; Newer</button>
            <button class="stratus-git-log-next">Older &rarr;</button>
          </nav>
        </footer>
      """
    return html.join ""


# Internal: Pass the commit objects into the callback.
# 
# page     - 0-based page index.
# callback - Receives `(commits)`.
# 
getCommits = (page, callback) ->
  {branch} = window.data.project.git
  $.getJSON "/#{projectPath}/commits/#{branch}.json", {page}
  , (commits, status, xhr) ->
    _.each commits, (c) ->
      c.committed_date = new Date c.committed_date
      c.authored_date  = new Date c.authored_date
    callback commits




# Internal: Convert a commit object into a history list item.
# 
# commit - A Commit object.
# 
# Returns String HTML.
commitToListItem = (commit) ->
  date = commit.authored_date
  if dateTools.isToday date
    time = dateTools.getTime date
  else
    time = "#{dateTools.month(date.getMonth())} #{date.getDate()}"
  """<li data-commit-id="#{commit.id}">
    <img src="https://secure.gravatar.com/avatar/#{commit.author.hash}" draggable="false"/>
    <header>#{commit.author.name}</header>
    <p>#{commit.message.split("\n")[0]}</p>
    <aside>
      <a href="#" class="stratus-git-log-show symbol" title="Browse code">)</a>
      <p>
        <time>#{time}</time>
        <span class="stratus-git-sha">#{commit.id[0..6]}</span>
      </p>
    </aside>
  </li>"""

