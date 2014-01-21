local loader = require 'loader'

-- Keyboard settings
local keys = loader:unpackIfExists(
{
    name = "keys",
    gesture = "g",
    up = "up",
    down = "down",
    leftArrow = "left",
    rightArrow = "right",
    openMenu = "escape",
    confirm = "return",
    left = "a",
    right = "d",
    spells =
    {
        "space",
        "w",
        "s",
        "q",
    },
})

return keys
