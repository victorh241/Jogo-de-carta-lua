local entity = require("Entities/Entity")
-- lote agora virou um fichario


local Lot = {}
-- Faz o Lot herdar da Entity
setmetatable(Lot, {__index = entity})
-- Permite que as instâncias de Lot achem as funções de Lot
Lot.__index = Lot

function Lot:new(x, y, name)
    -- 1. Cria a base usando a entity
    local newLot = entity:new("Lot", x, y)

    -- 2. Vincula o objeto à classe Lot para ele achar o :draw() e :update()
    setmetatable(newLot, self)

    --#region variaveis
    newLot.width = 220  -- largura
    newLot.height = 120  -- altura
    newLot.count = 0
    newLot.isDragging = false
    newLot.name = name or ""
    --#endregion

    --#region menu variaveis
    newLot.isMenuOpen = false
    newLot.btnHeight = 20
    newLot.btnWidth = 40
    --#endregion

    return newLot
end

--#region hover menu
function Lot:isMouseOnButton(mx, my)
    -- O botão ficará no canto superior direito do lote
    local bx = self.x + self.width - self.btnWidth
    local by = self.y - self.btnHeight - 5 -- 5px de margem acima do lote
    
    return mx >= bx and mx <= (bx + self.btnWidth) and 
           my >= by and my <= (by + self.btnHeight)
end
--#endregion

--#region carta em cima do lote
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
--#endregion

--#region mouse sobre o lote
function Lot:isMouseOnLot(MouseX, MouseY)
    return MouseX >= self.x and MouseX <= (self.x + self.width) and 
    MouseY >= self.y and MouseY <= (self.y + self.height)
end

function Lot:CardStackedPosition(cardW, cardH)
    local targetX = self.x + (self.width / 2 - (cardW / 2))
    local targetY = self.y + (self.height / 2 - (cardH / 2) - 20) -- valor off set

    if self.count > 0 then
        targetY = targetY + (20 * self.count) -- offset de 20
    end

    return targetX, targetY
end
--#endregion

function Lot:update(dt, mx, my, mClick)
    -- Se o mouse foi clicado E estava em cima do botão
    if mClick and self:isMouseOnButton(mx, my) then
        self.isMenuOpen = not self.isMenuOpen -- Inverte (abre/fecha)
        return true -- Avisa o manager que um botão foi clicado
    end
    return false
end

function Lot:draw()
    -- Retangulo interno (Preenchimento)
    love.graphics.setColor(0.56, 0.29, 0.12)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    -- Retangulo externo (Borda)
    love.graphics.setColor(0, 0, 0)
    love.graphics.setLineWidth(2) -- Aumentei para 2 para ficar mais visível
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)

    --cabeçalho titulo
    --retangulo externo
    love.graphics.rectangle("line", self.x, self.y - self.height/4 + 5, self.width, 20)
    love.graphics.setColor(1, 1, 1)

    --retangulo interno
    love.graphics.rectangle("fill", self.x, self.y - self.height/4 + 5, self.width, 20)

    --titulo
    love.graphics.setColor(0,0,0)
    love.graphics.printf(self.name, self.x, self.y - self.height/4 + 5, self.width, "center")

    -- Reset de cor para não afetar outros desenhos
    love.graphics.setColor(1, 1, 1)

    -- 2. Desenha o Botão (Acima do lote)
    local bx = self.x + self.width - self.btnWidth
    local by = self.y - self.btnHeight - 5
    
    love.graphics.setColor(0.2, 0.6, 0.2) -- Verde
    love.graphics.rectangle("fill", bx, by, self.btnWidth, self.btnHeight)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("MENU", bx + 2, by + 4)

    -- 3. Desenha o Menu (Apenas se estiver aberto)
    if self.isMenuOpen then
        self:drawMenu()
    end
end

function Lot:drawMenu()
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.rectangle("fill", 1280/2, 720/2, 300, 300)
end

return Lot