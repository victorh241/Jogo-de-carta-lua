local Manager = {}
Manager.__index = Manager

-- #region variaveis relacionados ao sistema de dinheiro
local money = 0
--#endregion

--#region importações
local Mouse = require("PlayerRelated/mouse")
local Card = require("Entities/Card")
local Lot = require("Entities/lots")
--#endregion

-- #region variaveis para logica das entidades e outros
--variavel das cartas
local Cards = {}
local CardsPeople = {}
local CardsRessourcers = {}

-- variaveis para o fichario
local Lots = {} -- fichario agora
local cardInSlot = {}

local cardBeingDragged = nil
local lotBeingDragged = nil
local wasMousePressed = false

-- ui deck
-- o ui vai ter que ficar no canto inferior direito
local UIdeckChang


--#endregion

--#region funções extras
local function lerp(a, b, dt) -- eu só to usando o local para manter tudo no gameManager
    return b + (a-b) * math.exp(-16 * dt)
end

local function clamp(x, a, b) -- boa função pra se ter
    if x < a then return a end
    if x > b then return b end
    return x
end

local function isPointInRect(px, py, rx, ry, rw, rh) -- não sei se é necessario
    return px >= rx and px <= (rx + rw) and py >= ry and py <= (ry + rh)
end
--#endregion

function Manager:load()

    -- #region cards
    local CardTest1 = Card:new(400, 300, "Pedro")
    local CardTest2 = Card:new(300, 300, "Sam")
    local CardTest3 = Card:new(200, 300, "Diego")

    table.insert(Cards, CardTest1)
    table.insert(Cards, CardTest2)
    table.insert(Cards, CardTest3)
    --#endregion

    --#region lots
    local lotTest1 = Lot:new(100, 200, "Misson")
    table.insert(Lots, lotTest1)
    --#endregion
end

function Manager:update(dt)
    Mouse:update(dt)

    local mouseJustPressed = Mouse.isPressed and not wasMousePressed
    wasMousePressed = Mouse.isPressed

    --#region logica da carta
    Mouse.isHovering = false

    for i = #Cards, 1, -1 do
        local card = Cards[i]
        local isCardPicked = card:isCardPicked(Mouse.x, Mouse.y, Mouse.isPressed, cardBeingDragged ~= nil)

        -- o debug do mouse
        if card.isHovering then
            Mouse.isHovering = true
        end

        if isCardPicked then
            cardBeingDragged = card

            table.remove(Cards, i)
            table.insert(Cards, card)
            break
        end
    end

    if cardBeingDragged ~= nil and Mouse.isPressed then
        cardBeingDragged.x = cardBeingDragged.x + ((Mouse.x - cardBeingDragged.width/2 + 20) - cardBeingDragged.x) * dt * 15
        cardBeingDragged.y = cardBeingDragged.y + ((Mouse.y - cardBeingDragged.height/2 - 20) - cardBeingDragged.y) * dt * 15
        cardBeingDragged.angle = lerp(cardBeingDragged.angle or 0, 0, dt)
    end
    --#endregion

    --#region lot logica
    -- revisar codigo para aprender mais sobre algoritomo
    if not Mouse.isPressed then
        --#region colocar a carta dentro do slot
        
        --#endregion

        -- Finaliza o arrasto das entidades
        cardBeingDragged = nil
        lotBeingDragged = nil
    end

    --#region Pegando o lote
    for i = #Lots, 1, -1 do
        local lot = Lots[i]
        local isMouseOnlot = lot:isMouseOnLot(Mouse.x, Mouse.y)
        local isMouseOnButtonLot = lot:isMouseOnButton(Mouse.x, Mouse.y)

        --#region logica de arrastar
        if isMouseOnlot then
            Mouse.isHovering = true
            if Mouse.isPressed then
                lot.isDragging = true
                lotBeingDragged = lot

                table.remove(Lots, i)
                table.insert(Lots, lotBeingDragged)
            end
        end
        --#endregion

        --#region abrir menu logica
        if isMouseOnButtonLot then
            Mouse.isHovering = true
        end

        lot:OpenMenu(dt, Mouse.x, Mouse.y, mouseJustPressed)
        --#endregion
    end

    if lotBeingDragged ~= nil and Mouse.isPressed then
        lotBeingDragged.x = lotBeingDragged.x + ((Mouse.x - lotBeingDragged.width/2 + 20) - lotBeingDragged.x) * dt * 15
        lotBeingDragged.y = lotBeingDragged.y + ((Mouse.y - lotBeingDragged.height/2 - 20) - lotBeingDragged.y) * dt * 15
    end
    --#endregion

    --#region slot fichario
    
    --#endregion

    --#region Deck
    do
        local hand = {}
        for _, c in ipairs(Cards) do
            if c ~= cardBeingDragged then
                table.insert(hand, c)
            end
        end

        local n = #hand
        if n > 0 then
            local screenW = love.graphics.getWidth()
            local screenH = love.graphics.getHeight()

            local centerX = screenW * .5
            local baseY = screenH - 215
            local spread = clamp(46, 34, 64)
            local maxAngle = math.rad(6) -- o maximo que fica inclinado

            for i, c in ipairs(hand) do
                local t = (n == 1) and 0 or ((i - 1) / (n - 1)) * 2 - 1
                local tx = centerX + t * spread * (n - 1)
                local ty = baseY + math.abs(t) * 26
                local ta = t * maxAngle

                c.targetX = tx
                c.targetY = ty
                c.targetAngle = ta

                c.x = lerp(c.x, c.targetX, dt)
                c.y = lerp(c.y, c.targetY, dt)
                c.angle = lerp(c.angle or 0, c.targetAngle or 0, dt)
            end
        end
    end
    --#endregion
end

function Manager:draw()

    --#region desenhar lots
    for i, lot in ipairs(Lots) do
        lot:draw()
    end
    --#endregion

    --#region desenhar cartas
    -- desenhar as cartas
    for i, card in ipairs(Cards) do
        card:draw()
    end
    --#endregion

    --#region dinheiro
    love.graphics.print("Money: ",1100, 20)
    love.graphics.print(money, 1180, 20)
    --#endregion

    --#region debug
    -- texto pra debugar
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(Mouse.x, 500, 20)
    love.graphics.print(Mouse.y, 600, 20)
    -- #cards para saber o tamanho de uma tabela é dessa forma
    --#endregion

    Mouse:draw()
end

return Manager