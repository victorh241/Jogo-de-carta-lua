local entity = require("Entities/Entity")

local Card = {}
Card.__index = Card
setmetatable(Card, {__index = entity})

--#region função de colisão do mouse com a carta
local function isPointInRectangle(px, py, rx, ry, rw, rh)
    return px >= rx and px <= (rx + rw) and py >= ry and py <= (ry + rh)
end
--#endregion

function Card:new(x, y, title, cardType)
    local newCard = entity:new("card", x, y) -- o tipo é fixo foda-se

    setmetatable(newCard, Card)

    --#region variaveis de logica
    --constantes
    newCard.height = 180 -- const
    newCard.width = 120 -- const

    -- variaveis relacionados ao ato de pegar a carta
    newCard.velX = 0
    newCard.velY = 0
    newCard.isDragging = false
    newCard.targetX = x
    newCard.targetY = y

    --tipagem e individualização da carta
    newCard.title = title
    newCard.cardType = cardType or ""

    --deck
    newCard.angle = 0
    newCard.targetAngle = 0
    --#endregion

    --#region variaveis de atributos
    newCard.atributos = {-- atributo de cada carta depois da missão funcionar eu vejo isso
        strength = 0,
        inteligence = 0,
        dexterity = 0,
        carisma = 0
    }
    --#endregion


    return newCard
end

--#region função de load
function Card:load()
    -- essa função só esta aqui caso precise de algo
end
--#endregion

--#region função para saber se a carta foi pegada ou não
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
--#endregion

function Card:draw()
    -- variaveis para orientação
    local cx = self.x + self.width / 2 -- centro x
    local cy = self.y + self.height / 2 -- centro y

    --#region desenho externo da carta (Lembrando que tudo isso é provisório tirando o titulo talvez)
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
    --#endregion

    --#region titulo
    --quadrado do titulo
    --retagunlo externo
    love.graphics.setColor(0, 0, 0)
    love.graphics.setLineWidth(3)
    local titleY = -self.height/4 + 50 -- depois eu ajeito isso
    love.graphics.rectangle("line", 0, titleY, self.width, 20)
    love.graphics.setColor(1, 1, 1)

    --retangulo interno
    love.graphics.rectangle("fill", 0, titleY, self.width, 20)

    --texto
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf(self.title, 0, titleY, self.width, "center")

    love.graphics.setColor(1, 1, 1)
    love.graphics.pop()
    --#endregion
end

return Card