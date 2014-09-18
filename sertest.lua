local Component = require 'components.Component'
local lady = require 'lib.lady'
local comp1 = Component(5)
local comp1 = Component(function() return 10 end)

lady.save_all(comp1, comp2)


local load1, load2 = lady.load_all()
print(load1.systems)
print(load2.systems())
