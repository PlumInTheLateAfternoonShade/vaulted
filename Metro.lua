local Metro = require('lib.middleclass')('Metro')

--A metronome object for abstracting time flow.--

function Metro:initialize(redTime, greenTime,
             delay, initState)
    -- How many millis the metro will be in a "false" state.
    self.redTime = redTime or 0
    -- How many millis the metro will be in a "true" state.
    self.greenTime = greenTime or 0
    local delay = delay or 0
    self.time = -delay
    self.state = initState or false
    self:assignTickTime()
end

function Metro:tick(dt)
    --Updates by a millisecond argument and returns its current state.--
    self.time = self.time + dt
    if self.time > self.tickTime then
        self.time = 0 
        self.state = not self.state
        self:assignTickTime()
    end
    return self.state
end

function Metro:assignTickTime()
    --Assigns the current state length.--
    if self.state then
        self.tickTime = self.greenTime
    else
        self.tickTime = self.redTime
    end
end

function Metro:zero()
    --Resets the time to 0 seconds.--
    self.time = 0
end

function Metro:getPercentGreen()
    --Returns the time divided by the greenTime.--
    return self.time / self.greenTime
end

return Metro
