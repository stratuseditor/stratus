{tabs}      = require '../ui'
dateTools   = require './date'
show_commit = require './show_commit'

# Public: Open a new tab with the branch selection.
module.exports = ->
  new GitBranches()


class GitBranches
  published: """
      <button class="published">Published</button>
    """
  
  constructor: ->
    @$container = $ """
        <div class="stratus-git-branches">
          <header>
            <input class="stratus-git-branches-filter" type="text" placeholder="Filter branches"/>
          </header>
        </div>
      """
    @$filter = @$container.find ".stratus-git-branches-filter"
    @$filter.on "keydown", =>
      _.defer => @filter(@$filter.val())
    @loadBranches()
    tabs "git-branches", @$container
  
  # Fetch and display the branches.
  loadBranches: ->
    $.getJSON "/#{window.data.project.path}/branches.json"
    , (branches, status, xhr) =>
      _.map branches, (b) ->
        b.commit.authored_date  = new Date b.commit.authored_date
        b.commit.committed_date = new Date b.commit.committed_date
      branches = _.sortBy branches, (branch) ->
        if branch.current
          "A"
        else
          branch.name
      
      @branchNames = _.map branches, ((b) -> b.name)
      inner        = _.map branches, ((b) => @branchToHTML(b))
      @$container.append """
          <ul>
            #{ inner.join("") }
            <li style='visibility: hidden;'></li>
          </ul>
        """
  
  
  # Internal: Filter the branches by the given substring.
  # 
  # Returns nothing.
  filter: (text) ->
    @$container.children("ul").children().each ->
      $branch = $ this
      name    = $branch.find(".name:first").text()
      if ~name.indexOf(text)
        $branch.show()
      else
        $branch.hide()
  
  # Internal: Generate the HTML for a branch list item.
  # 
  # Returns String.
  branchToHTML: (branch) ->
    message = branch.commit.message.split("\n")[0].substr 0, 100
    if branch.current
      current = ' class="current"'
      check   = '<span class="check">✓</span>'
    else
      current = ""
      check   = ""
    
    """
      <li#{current}>
        #{check}
        <div class="stratus-git-branch">
          <header>
            <h1 class="name">#{branch.name}</h1>
            <h2 class="stratus-git-sha">#{branch.commit.id[0..6]}</h2>
          </header>
          <section>
            #{@avatar(branch)}
            <span class="author">#{branch.commit.author.name}:</span>
            <p class="message" data-commit-id="#{branch.commit.id}">#{message}</p>
            <time>#{@time(branch)}</time>
          </section>
          <div class="actions">
            <button>+</button>
            <button>▼</button>
          </div>
        </div>
        #{@publishMarkup(branch)}
      </li>
    """
  
  avatar: (branch) ->
    """
      <img
        class="avatar"
        src="https://secure.gravatar.com/avatar/#{branch.commit.author.hash}"
        draggable="false"/>
    """
  
  publishMarkup: (branch) ->
    if branch.published
      return """
          <img src="/images/git/sync.png" class="sync" draggable="false"/>
          #{GitBranches.published}
        """
    else
      return """
          <img src="/images/git/sync.png" class="sync disabled" draggable="false"/>
          <button class="publish" data-branch="#{branch.name}">Publish</button>
        """
  
  time: (branch) ->
    date = branch.commit.authored_date
    if dateTools.isToday date
      return dateTools.getTime date
    else
      return dateTools.toString date


jQuery ($) ->
  $(document).on "click", ".stratus-git-branch .message", ->
    show_commit $(this).data("commit-id")
  
  $(document).on "click", ".stratus-git-branch .publish", ->
    $publish = $ this
    branch  = $publish.data("branch")
    $.post "/#{window.data.project.path}/publish", {branch}
    , (data, status, xhr) ->
      if data.err
        console.err err
        alert "Something went wrong"
      else
        $publish.replaceWith GitBranches.published
