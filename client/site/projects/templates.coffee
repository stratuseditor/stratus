exports.newProjectDialog = "<div class='tabs tabs-block'>
  <nav><ul>
    <li class='current'>Standard</li>
    <li>Git:Clone</li>
    <li>FTP</li>
    <li>DropBox</li>
  </ul></nav>
  
  <div class='tab-contents new-project'>
    <section class='current'>
      <form method='POST' action='/projects' class='project-type-standard'>
        <div class='field'>
          <input name='project[name]' type='text' placeholder='Project name'/>
        </div>
        <div class='field'>
          <label>
            <input name='project[isPublic]' type='checkbox' checked='checked'/>
            Public
          </label>
        </div>
        
        <br/>
        
        <input type='submit' value='Create Project' class='primary'>
        <button>Cancel</button>
      </form>
    </section>
  </div>
</div>"


