local Lifetime = require 'lib.middleclass'('Lifetime',
                 require 'components.Component')

function Lifetime:initialize(lifetime)
    self.lifetime = lifetime
    self.timeAlive = 0
end

return Lifetime
