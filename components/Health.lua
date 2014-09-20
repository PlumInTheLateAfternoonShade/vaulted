local Health = require 'lib.middleclass'('Health',
                 require 'components.Component')

function Health:initialize(initHealth, healthMult)
    self.health = initHealth or 0
    self.healthMult = healthMult or 1
end

return Health
