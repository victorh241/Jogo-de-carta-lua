local entity = require("Entities/Entity")
-- lote agora virou um fichario
-- depois eu dou uma estuda nesse codigo

local Lot = {}
setmetatable(Lot, {__index = entity})
Lot.__index = Lot

local function isPointInRect(px, py, rx, ry, rw, rh) -- função basica também para saber se tem um determinado ponto em cima do fichario
    return px >= rx and px <= (rx + rw) and py >= ry and py <= (ry + rh)
end

function Lot:new(x, y, name)
    local newLot = entity:new("Lot", x, y)

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

    -- intervalo entre click para fechar ou abrir menu
    newLot.DelayConstTime = 0.35
    newLot.CountDelay = 0

    -- slots
    newLot.SlotQnt = 2
    newLot.SlotOffSet = 20
    newLot.SlotList = {
        { id = "personagem", card = nil },
        { id = "recurso", card = nil }
    }

    newLot.lastMissionSent = 0
    --#endregion

    return newLot
end

--#region funções extras
function drawDashedLine(x1, y1, x2, y2, dashLen, gapLen) -- o slot seria traçado
    local dx, dy = x2 - x1, y2 - y1
    local dist = math.sqrt(dx*dx + dy*dy) -- Distância total
    local angle = math.atan2(dy, dx)      -- Direção da linha
    
    local currentDist = 0
    
    while currentDist < dist do
        local nextDist = math.min(currentDist + dashLen, dist)
        
        local sx = x1 + math.cos(angle) * currentDist
        local sy = y1 + math.sin(angle) * currentDist
        local ex = x1 + math.cos(angle) * nextDist
        local ey = y1 + math.sin(angle) * nextDist
        
        love.graphics.line(sx, sy, ex, ey)
        currentDist = currentDist + dashLen + gapLen
    end
end
--#endregion

--#region hover menu
function Lot:isMouseOnButton(mx, my)
    local bx = self.x + self.width - self.btnWidth
    local by = self.y - self.btnHeight - 5 -- 5px de margem acima do lote
    
    return mx >= bx and mx <= (bx + self.btnWidth) and 
           my >= by and my <= (by + self.btnHeight)
end
--#endregion

--#region carta em cima do lote
function Lot:isCardInSlot(cardX, cardY) -- depois eu mudo isso
    local lotW, lotH = 110, 80
    local offset = 10
    
    local cardCenterX = cardX + (70 / 2)
    local cardCenterY = cardY + (100 / 2)

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

function Lot:OpenMenu(dt, mx, my, mClick)
    if self.CountDelay > 0 then
        self.CountDelay = self.CountDelay - dt
    end

    local clicked = false

    -- abre/fecha pelo botão do lote
    if mClick and self:isMouseOnButton(mx, my) and self.CountDelay <= 0 then
        self.isMenuOpen = not self.isMenuOpen
        self.CountDelay = self.DelayConstTime
        clicked = true
    end

    if self.isMenuOpen and mClick and (not clicked) and self.CountDelay <= 0 then
        local panel = self:getMenuRect()
        local closeBtn = self:getCloseButtonRect()
        local sendBtn = self:getSendButtonRect()

        if isPointInRect(mx, my, closeBtn.x, closeBtn.y, closeBtn.w, closeBtn.h) then
            self.isMenuOpen = false
            self.CountDelay = self.DelayConstTime
            return true
        end

        if isPointInRect(mx, my, sendBtn.x, sendBtn.y, sendBtn.w, sendBtn.h) then
            self.lastMissionSent = self.lastMissionSent + 1
            self.CountDelay = self.DelayConstTime
            return true
        end
    end

    return clicked
end

function Lot:getMenuRect()
    local sw = love.graphics.getWidth()
    local sh = love.graphics.getHeight()
    local w = sw * 0.40
    local h = sh * 0.40
    return {
        x = (sw - w) / 2,
        y = (sh - h) / 2,
        w = w,
        h = h
    }
end

function Lot:getCloseButtonRect()
    local panel = self:getMenuRect()
    return {
        x = panel.x + panel.w - 90,
        y = panel.y + 12,
        w = 78,
        h = 26
    }
end

function Lot:getSendButtonRect()
    local panel = self:getMenuRect()
    return {
        x = panel.x + (panel.w / 2) - 110,
        y = panel.y + panel.h - 44,
        w = 220,
        h = 32
    }
end

function Lot:getSlotRects()
    local panel = self:getMenuRect()
    local pad = 22
    local slotW = (panel.w - (pad * 2) - 18) / 2
    local slotH = panel.h * 0.45
    local y = panel.y + 70

    return {
        personagem = { x = panel.x + pad, y = y, w = slotW, h = slotH },
        recurso = { x = panel.x + pad + slotW + 18, y = y, w = slotW, h = slotH }
    }
end

function Lot:tryPlaceCardInSlots(card)
    if not self.isMenuOpen then return false end
    local slots = self:getSlotRects()

    local cx = card.x + (card.width / 2)
    local cy = card.y + (card.height / 2)

    local function place(slotId, rect)
        for _, s in ipairs(self.SlotList) do
            if s.id == slotId then
                s.card = card
                card.isCardInLot = true
                card.lotId = card.lotId or 0
                card.x = rect.x + (rect.w / 2) - (card.width / 2)
                card.y = rect.y + (rect.h / 2) - (card.height / 2)
                card.angle = 0
                return true
            end
        end
        return false
    end

    if isPointInRect(cx, cy, slots.personagem.x, slots.personagem.y, slots.personagem.w, slots.personagem.h) then
        return place("personagem", slots.personagem)
    end
    if isPointInRect(cx, cy, slots.recurso.x, slots.recurso.y, slots.recurso.w, slots.recurso.h) then
        return place("recurso", slots.recurso)
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
    local panel = self:getMenuRect()
    local closeBtn = self:getCloseButtonRect()
    local sendBtn = self:getSendButtonRect()
    local slots = self:getSlotRects()

    -- fundo leve (não cobre tudo)
    love.graphics.setColor(0, 0, 0, 0.25)
    love.graphics.rectangle("fill", panel.x - 12, panel.y - 12, panel.w + 24, panel.h + 24, 12, 12)

    -- painel
    love.graphics.setColor(0.95, 0.95, 0.95, 0.92)
    love.graphics.rectangle("fill", panel.x, panel.y, panel.w, panel.h, 12, 12)
    love.graphics.setColor(0, 0, 0, 0.9)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", panel.x, panel.y, panel.w, panel.h, 12, 12)

    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.print(self.name .. " - Missao", panel.x + 16, panel.y + 14)

    -- botão fechar (topo)
    love.graphics.setColor(0.2, 0.2, 0.2, 1)
    love.graphics.rectangle("fill", closeBtn.x, closeBtn.y, closeBtn.w, closeBtn.h, 8, 8)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("FECHAR", closeBtn.x, closeBtn.y + 6, closeBtn.w, "center")

    -- slots (2)
    local function drawSlot(rect, label) -- lembrete pode fazer esse tipo de coisa
        love.graphics.setColor(0.12, 0.12, 0.12, 0.75)
        love.graphics.rectangle("fill", rect.x, rect.y, rect.w, rect.h, 10, 10)
        love.graphics.setColor(1, 1, 1, 0.20)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", rect.x, rect.y, rect.w, rect.h, 10, 10)
        love.graphics.setColor(1, 1, 1, 0.9)
        love.graphics.print(label, rect.x + 10, rect.y + 10)
    end

    drawSlot(slots.personagem, "Slot Personagem")
    drawSlot(slots.recurso, "Slot Recurso")

    -- botão enviar (embaixo)
    love.graphics.setColor(0.12, 0.45, 0.18, 1)
    love.graphics.rectangle("fill", sendBtn.x, sendBtn.y, sendBtn.w, sendBtn.h, 10, 10)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("ENVIAR PARA MISSAO", sendBtn.x, sendBtn.y + 8, sendBtn.w, "center")
    love.graphics.setColor(0, 0, 0, 0.65)
    love.graphics.print("Enviado: " .. tostring(self.lastMissionSent), sendBtn.x, sendBtn.y + sendBtn.h + 6)

    love.graphics.setColor(1, 1, 1, 1)
end

return Lot