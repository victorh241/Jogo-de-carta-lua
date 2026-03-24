local entity = require("Entities/Entity")

local Lot = {}
-- Faz o Lot herdar da Entity
setmetatable(Lot, {__index = entity})
-- Permite que as instâncias de Lot achem as funções de Lot
Lot.__index = Lot

function Lot:new(x, y)
    -- 1. Cria a base usando a entity
    local newLot = entity:new("Lot", x, y)

    -- 2. Vincula o objeto à classe Lot para ele achar o :draw() e :update()
    setmetatable(newLot, self)

    --#region variaveis
    newLot.width = 80  -- largura
    newLot.height = 110  -- altura
    newLot.count = 0
    --#endregion

    return newLot
end

function Lot:isCardInLot(cardX, cardY)
    local lotW, lotH = 110, 80
    local offset = 10
    
    -- Calculamos o centro da carta para uma colisão mais natural
    local cardCenterX = cardX + (70 / 2)
    local cardCenterY = cardY + (100 / 2)

    -- Verifica se o centro da carta está dentro das bordas do lote (com o offset aplicado)
    return cardCenterX >= (self.x + offset) and 
           cardCenterX <= (self.x + lotW - offset) and 
           cardCenterY >= (self.y + offset) and 
           cardCenterY <= (self.y + lotH - offset)
end

function Lot:isMouseOnLot(MouseX, MouseY)
    return MouseX >= self.x and (self.x + self.width) <= MouseX and MouseY >= self.y and (self.y + self.height) <= MouseY
end

function Lot:CardStackedPosition(cardW, cardH)
    local targetX = self.x + (self.width / 2 - (cardW / 2))
    local targetY = self.y + (self.height / 2 - (cardH / 2) - 20) -- valor off set

    if self.count > 0 then
        targetY = targetY + (20 * self.count) -- offset de 20
    end

    return targetX, targetY
end

function Lot:draw()
    -- Retangulo interno (Preenchimento)
    love.graphics.setColor(0.56, 0.29, 0.12)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    -- Retangulo externo (Borda)
    love.graphics.setColor(0, 0, 0)
    love.graphics.setLineWidth(2) -- Aumentei para 2 para ficar mais visível
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    
    -- Reset de cor para não afetar outros desenhos
    love.graphics.setColor(1, 1, 1)
end

return Lot