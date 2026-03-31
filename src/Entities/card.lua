local entity = require("Entities/Entity")

local Card = {}
Card.__index = Card
setmetatable(Card, {__index = entity})


local function isPointInRectangle(px, py, rx, ry, rw, rh)
    return px >= rx and px <= (rx + rw) and py >= ry and py <= (ry + rh)
end

function Card:new(x, y, title)
    local newCard = entity:new("card", x, y) -- o tipo é fixo foda-se

    setmetatable(newCard, Card)

    --#region variaveis de logica
    newCard.height = 100 -- const
    newCard.width = 70 -- const
    newCard.velX = 0
    newCard.velY = 0
    newCard.isDragging = false
    newCard.isInLot = false
    newCard.lotId = 0
    newCard.title = title
    newCard.angle = 0
    newCard.targetAngle = 0
    newCard.targetX = x
    newCard.targetY = y
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
    self.isHovering = isPointInRectangle(MouseX, MouseY, self.x, self.y, self.width, self.height)

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
    local cx = self.x + self.width / 2
    local cy = self.y + self.height / 2

    love.graphics.push()
    love.graphics.translate(cx, cy)
    love.graphics.rotate(self.angle or 0)
    love.graphics.translate(-self.width / 2, -self.height / 2)

    --retangulo interno
    love.graphics.setColor(1, 1, 1, 1) -- cor: branca
    love.graphics.rectangle("fill", 0, 0, self.width, self.height)

    --retangulo(linha) externo
    love.graphics.setColor(0, 0, 0)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", 0, 0, self.width, self.height)
    love.graphics.setColor(1, 1, 1)

    --quadrado do titulo
    --retagunlo externo
    love.graphics.setColor(0, 0, 0)
    love.graphics.setLineWidth(3)
    local titleY = -self.height/4 + 5
    love.graphics.rectangle("line", 0, titleY, self.width, 20)
    love.graphics.setColor(1, 1, 1)

    --retangulo interno
    love.graphics.rectangle("fill", 0, titleY, self.width, 20)

    --texto
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf(self.title, 0, titleY, self.width, "center")

    love.graphics.setColor(1, 1, 1)
    love.graphics.pop()
end

return Card