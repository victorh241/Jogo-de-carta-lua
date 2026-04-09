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

local deckIndex = 1 -- index ordens 1: personagens, 2: recursos
-- variaveis para o fichario
local Lots = {} -- fichario agora
local cardInSlot = {}

local cardBeingDragged = nil
local lotBeingDragged = nil
local wasMousePressed = false

-- ui deck
-- o ui vai ter que ficar no canto inferior direito
local UIdeckChang

local fontSizeDeck = love.graphics.newFont(30)
local normalFont = love.graphics.newFont(10)
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

local function isPointInRect(px, py, rx, ry, rw, rh) -- não sei se é necessario, mas deixa ai por hora
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
    -- index hand
    if isPointInRect() then
        
    end

    -- logica da mão
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

    --logica de trocar de deck


    --#endregion
end

local function getDeckUIRect()
    local sw = love.graphics.getWidth()
    local sh = love.graphics.getHeight()


    return {
        x = sw - sw/12 - 100,
        y = sh - 210,
        w = 200, -- width
        h = 200 -- height
    }
end

local function getButtonInCreaseDeckUI()
    local deckUI = getDeckUIRect()

    return {
        x = 0,
        y = 0,
        w = 30,
        h = 30
    }
end

local function DeckUIDraw()
    -- varivel geral da ui
    local deckComponent = getDeckUIRect()

    --#region Caixa principal
    -- posição geral da caixa

    -- linha de fora
    love.graphics.setColor(0,0,0)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", deckComponent.x, deckComponent.y, deckComponent.w + 1, deckComponent.h + 1)

    -- interno
    love.graphics.setColor(1,1,1, 0.6)
    love.graphics.rectangle("fill", deckComponent.x, deckComponent.y, deckComponent.w, deckComponent.h)

    --#region button 1
    local button = getButtonDeckUI()

    local bnt1PosX = deckPosX + bntWidth - bntWidth/2
    local bnt1PosY = deckPosY + bntHeight

    --linha de fora do botão
    love.graphics.setColor(0,0,0)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", bnt1PosX, bnt1PosY, button.w, button.h)

    --interno
    love.graphics.setColor(1,1,1)
    love.graphics.rectangle("fill", bnt1PosX, bnt1PosX, bntWidth, bntHeight)

    --texto
    love.graphics.setColor(0,0,0)
    love.graphics.setFont(fontSizeDeck)
    love.graphics.printf("+", bnt1PosX, bnt1PosY - 4, 30, "center")
    
    --#endregion

    --#region button 2
    local bnt2PosX = deckPosX + bntWidth*5
    local bnt2PosY = bnt1PosY

    --linha externa
    love.graphics.setColor(0,0,0)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", bnt2PosX, bnt2PosY, bntHeight, bntWidth)

    --interno
    love.graphics.setColor(1,1,1)
    love.graphics.rectangle("fill", bnt2PosX, bnt2PosY, bntHeight, bntWidth)
    
    --texto
    love.graphics.setColor(0,0,0)
    love.graphics.setFont(fontSizeDeck)
    love.graphics.printf("-", bnt2PosX, bnt2PosY- 4, 30, "center")
    love.graphics.setFont(normalFont)
    --#endregion

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

    --#region deck
    DeckUIDraw()
    --#endregion

    Mouse:draw()
end

return Manager