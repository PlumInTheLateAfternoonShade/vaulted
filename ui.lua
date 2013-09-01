-- The ui displayed in-game
local UI = {}

local healthColor = {r=230, g=100, b=100}
local manaColor = {r=100, g=100, b=230}

function UI:draw()
    self:drawHealthBar()
    self:drawManaBar()
end

function UI:drawHealthBar()
    setColor(healthColor)
    if hero.health then
        love.graphics.rectangle("fill", 0, screenHeight*0.95,
        screenWidth*(hero.health / hero.xp), screenHeight*0.025)
    end
end

function UI:drawManaBar()
    setColor(manaColor)
    if hero.mana then
        love.graphics.rectangle("fill", 0, screenHeight*0.975,
        screenWidth*(hero.mana / hero.xp), screenHeight*0.025)
    end
end

return UI
