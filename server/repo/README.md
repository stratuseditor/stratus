# Repo Manager
Create, modify, delete projects. A project has a pointer to a directory.

## API
### Create a brand new project.

    require("project")
      .fs.create({name, owner, path})
      .fs.create({name, owner, clone}) # Not implemented.

### Instantiate an existing project.

    require("project")
      .fs({name, path, owner})

### Now do something with it.

    Project
      #delete
      #move
      #copy
      #list
      #mkdir
      #isDirectory
      #touch
      #read
      #write
