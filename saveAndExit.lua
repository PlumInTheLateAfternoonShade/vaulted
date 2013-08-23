local loader = require('loader')
require('spellBook')
local SaveAndExit = {}

function SaveAndExit:close()
    loader:pack(hero)
    os.exit()
end

return SaveAndExit
