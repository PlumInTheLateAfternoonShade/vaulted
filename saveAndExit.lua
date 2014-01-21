local loader = require 'loader'
local keys = require 'keys'
local spellBookSystem = require 'systems.spellBookSystem'
if ShouldProfile then
    ProFi = require 'lib.ProFi'
end
local SaveAndExit = {}

function SaveAndExit:close()
    local heroSpellBook = spellBookSystem:get(heroId)
    if heroSpellBook then
        loader:pack(heroSpellBook)
    end
    loader:pack(conf)
    loader:pack(keys)
    if ShouldProfile then
        -- prof only
        print('Stopping profiler.')
        ProFi:stop()
        ProFi:writeReport('profile.txt')
    end
    love.event.quit()
end

return SaveAndExit
