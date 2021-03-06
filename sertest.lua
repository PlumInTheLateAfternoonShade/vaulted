local utils = require 'utils'
local Component = require 'components.Component'
local Position = require 'components.Position'
local SpellBook = require 'components.SpellBook'
local Point = require 'geometry.Point'
local Force = require 'components.Force'
local lady = require 'lib.Lady.lady'
local comp1 = Component(5)
local comp2 = Component(function() return 10 end)
local pos = Position:new({1, 2, 3, 4, 5, 6}, Point(0, 1))

lady.save_all('sertest.sav', comp1, comp2, pos)


local load1, load2, loadPos = lady.load_all('sertest.sav')
assert(loadPos:isInstanceOf(Component))
print(loadPos.class)
print(load1.systems)
print(load2.systems())

local pos2 = objectDeepcopy(pos)
pos2.id = 500

local system = {}

function system:init()
    self.components = {}
end

function system:add(comp)
    self.components[comp.id] = comp
end

system:init()
system:add(pos2)
print(tostring(system.components[pos2.id]))

local positionSystem = require 'systems.positionSystem'
positionSystem:init()
print(tostring(positionSystem.components))
print(pos2.id)
print(tostring(positionSystem.components[pos2.id]))

--utils.setFieldRecursive(pos2, 'systems', nil)
