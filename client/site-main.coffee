prefix = "/node_modules/stratus"
for path, pkg of require.modules
  if path.indexOf(prefix) == 0
    require.modules[path.substr(prefix.length)] = require.modules[path]

require './site/users/register'
require './site/users/log-in'
require './site/projects/open-project'
require './site/flash'
