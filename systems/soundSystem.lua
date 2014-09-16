-- Handles sound components.
local soundSystem = {}

require('systems.componentSystem'):inherit(soundSystem)

function soundSystem:init()
    self.music = love.audio.newSource("music/calm_piano1.mp3", "stream")
    self.music:setLooping(true)
    self:startMusic()
end

function soundSystem:startMusic()
    love.audio.play(self.music)
    self.paused = false
end

function soundSystem:stopMusic()
    love.audio.stop()
    self.paused = true
end

function soundSystem:update(dt)
    if not self.paused then
        self:startMusic()
    end
end

function soundSystem:delete(id)
end

return soundSystem
