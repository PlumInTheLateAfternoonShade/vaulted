-- The ui displayed in-game
local UI = {}

local healthColor = {r=230, g=100, b=100}
local manaColor = {r=100, g=100, b=230}

function UI:draw()
    self:drawHealthBar()
    self:drawManaBar()
    hero.spellBook:draw(0, 0, conf.screenWidth, conf.screenHeight*0.1)
end

function UI:drawHealthBar()
    setColor(healthColor)
    if hero.health then
        love.graphics.rectangle("fill", 0, conf.screenHeight*0.95,
        conf.screenWidth*(hero.health / hero.xp), conf.screenHeight*0.025)
    end
end

function UI:drawManaBar()
    setColor(manaColor)
    if hero.mana then
        love.graphics.rectangle("fill", 0, conf.screenHeight*0.975,
        conf.screenWidth*(hero.mana / hero.xp), conf.screenHeight*0.025)
    end
end

return UI
