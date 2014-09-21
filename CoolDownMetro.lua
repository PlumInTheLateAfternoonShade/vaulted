local CoolDownMetro = require('lib.middleclass')('CoolDownMetro')

--Handles a timer that fires, then can't fire for awhile.--

function CoolDownMetro:initialize(coolDown)
    self.metro = Metro(0, coolDown)
    self.hasFired = false
end

function CoolDownMetro:tick(dt)
    --[[
    Updates the internal metro by the passed milliseconds and sets the
    state.
    ]]--
    if self.hasFired then
        self.hasFired = self.metro:tick(dt)
    end
    if not self.hasFired and not self.metro.time == 0 then
        self.metro:zero()
    end
    return self.hasFired
end

function CoolDownMetro:fire()
    --Goes to the fired state.--
    self.hasFired = true
end

function CoolDownMetro:fizzle()
    --Goes back to the unfired state prematurely.--
    self.hasFired = false
end

function CoolDownMetro:getState()
    return self.hasFired
end

function CoolDownMetro:getPercent()
    --[[
    If in the fired state, returns what fraction of the state we've
    passed. Otherwise returns 0.
    ]]--
    if self.hasFired then
        return self.metro:getPercentGreen()
    else
        return 0
    end
end

function CoolDownMetro:getTime()
    return self.metro.time
end

return CoolDownMetro
