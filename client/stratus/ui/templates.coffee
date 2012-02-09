floatRight = "style='float: right;'"

module.exports =
  coords: """
    <div class="stratus-cursor-coords"><span class="stratus-cursor-row" title="row">
      </span><span class="stratus-cursor-col" title="column">
      </span></div>
    """
    
  
  file_manager:
    newFile: """
      <div class='new-file-dialog'>
        <div class='field'>
          <label>File path</label>
          <input type='text' placeholder='File name'/>
        </div>
        <button #{floatRight} class='create primary'>Create</button>
        <button #{floatRight} class='cancel'>Cancel</button>
      </div>
      """
    
    newDir: """
      <div class='new-dir-dialog'>
        <div class='field'>
          <label>Directory path</label>
          <input type='text' placeholder='Directory name'/>
        </div>
        <button #{floatRight} class='create primary'>Create</button>
        <button #{floatRight} class='cancel'>Cancel</button>
      </div>
      """
  
  split: """
    <div class="split-1"></div>
    <div class="split-2"></div>
    """
  
  search: """
    <div class='stratus-search'>
      <label>Search for</label>
      <input class="stratus-search" type="text" tabindex="1"/>
      <button class="stratus-search-history" title="Search history">[</button>
      <br/>
      
      <label>Replace with</label>
      <input class="stratus-replace" type="text" tabindex="2"/>
      <button class="stratus-replace-history" title="Replacement history">[</button>
      <br/>
      
      <label class="stratus-search-regex">
        <input type="checkbox"/>
        Regular expression
      </label>
      
      <label class="stratus-search-ignorecase">
        <input type="checkbox"/>
        Ignore case
      </label>
      
      <!--
      <label class="stratus-search-reverse">
        <input type="checkbox"/>
        Search backwards
      </label>
      -->
      
      <div class='stratus-search-message'>x</div>
      
      <div class="buttons">
        <button class="stratus-find" tabindex="3">Find</button>
        <button class="stratus-find-all" tabindex="4">Find all</button>
        
        <button class="stratus-replace" tabindex="5">Replace</button>
        <button class="stratus-replace-all" tabindex="6">Replace all</button>
      </div>
    </div>
    """
  
  snapopen: """
    <div class="stratus-snapopen">
      <input type="text" spellcheck="false"/>
      <ul></ul>
    </div>
    """
  
  tab:
    handle: """
      <div class="stratus-tab">
        <span class="stratus-tab-label"></span>
        <button class="stratus-tab-close">×</button>
      </div>
      """
    
    container: """
      <nav class="stratus-tabs">
        <button class="stratus-tabs-more">&gt;</button>
      </nav>
      <div class="stratus-tab-contents"></div>
      """
    
    #  A check mark to indicate the current tab in the overflow menu.
    check: """
      <span class="stratus-more-tab-current">.</span>
      """
