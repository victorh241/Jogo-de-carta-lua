local entity = require("Entities/Entity")

local Card = {}
Card.__index = Card
setmetatable(Card, {__index = entity})


local function isPointInRectangle(px, py, rx, ry, rw, rh)
    return px >= rx and px <= (rx + rw) and py >= ry and py <= (ry + rh)
end

function Card:new(x, y)
    local newCard = entity:new("card", x, y) -- o tipo é fixo foda-se

    setmetatable(newCard, Card)

    --#region variaveis de logica
    newCard.height = 70 -- const
    newCard.width = 100 -- const
    newCard.velX = 0
    newCard.velY = 0
    newCard.isDragging = false
    newCard.isInLot = false
    newCard.lotId = 0
    --#endregion

    --#region variaveis de atributos
    newCard.name = ""
    newCard.atributos = {
        strength = 0,
        inteligence = 0,
        dexterity = 0,
        carisma = 0
    }
    --#endregion


    return newCard
end

function Card:load()
    -- essa função só esta aqui caso precise de algo
end

function Card:isCardPicked(MouseX, MouseY, isMouseDown, cardBeingDragged)
    self.isHovering = isPointInRectangle(MouseX, MouseY, self.x, self.y, self.height, self.width)

    if isMouseDown and self.isHovering and not cardBeingDragged then 
        self.isDragging = true
        return true
    end

    if not isMouseDown then
        self.isDragging = false
    end

    return false
end

function Card:draw()
    --retangulo interno
    love.graphics.setColor(1, 1, 1, 1) -- cor: branca
    love.graphics.rectangle("fill", self.x, self.y, self.height, self.width)

    --retangulo(linha) externo
    love.graphics.setColor(0, 0, 0)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", self.x, self.y, self.height, self.width)
    love.graphics.setColor(1, 1, 1)
end

return Card