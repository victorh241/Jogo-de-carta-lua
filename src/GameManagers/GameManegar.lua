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
local Cards = {}
local Lots = {}
local cardInLot = {}

local cardBeingDragged = nil
local lotBeingDragged = nil
local wasMousePressed = false
--#endregion

--#region variaveis para debug
local debugNumber = 0
--#endregion

--#region funções extras
local function lerp(a, b, dt) -- eu só to usando o local para manter tudo no gameManager
    return b + (a-b) * math.exp(-16 * dt)
end

local function clamp(x, a, b)
    if x < a then return a end
    if x > b then return b end
    return x
end

local function isPointInRect(px, py, rx, ry, rw, rh)
    return px >= rx and px <= (rx + rw) and py >= ry and py <= (ry + rh)
end
--#endregion

--#region UI deck/decada
local deckUI = {
    x = 1040,
    y = 510,
    w = 140,
    h = 190
}

local decadas = { "1950s", "1960s", "1970s", "1980s", "1990s", "2000s", "2010s", "2020s" }
local decadaIndex = 4 -- começa em 1980s
local decadaBtn = {
    w = 130,
    h = 28,
    gap = 8
}
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

    --#region UI trocar decada (lado esquerdo do deck)
    local decadaPanelX = deckUI.x - (decadaBtn.w + 14)
    local decadaPanelY = deckUI.y + 10
    local btnPrevX = decadaPanelX
    local btnPrevY = decadaPanelY + 40
    local btnNextX = decadaPanelX
    local btnNextY = btnPrevY + decadaBtn.h + decadaBtn.gap

    if mouseJustPressed and isPointInRect(Mouse.x, Mouse.y, btnPrevX, btnPrevY, decadaBtn.w, decadaBtn.h) then
        decadaIndex = decadaIndex - 1
        if decadaIndex < 1 then decadaIndex = #decadas end
    elseif mouseJustPressed and isPointInRect(Mouse.x, Mouse.y, btnNextX, btnNextY, decadaBtn.w, decadaBtn.h) then
        decadaIndex = decadaIndex + 1
        if decadaIndex > #decadas then decadaIndex = 1 end
    end
    --#endregion

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
        --#region colocar a carta dentro do lote
        if cardBeingDragged ~= nil then
            local foundLotIndex = nil -- variavel para saber qual é o index do lot e se ele foi dropado em um lot

            -- 1. Primeiro: Descobrir se a carta foi solta em algum lote
            for i, lot in ipairs(Lots) do
                if lot:isCardInLot(cardBeingDragged.x, cardBeingDragged.y) then
                    foundLotIndex = i
                    break -- Encontrou o lote, não precisa continuar procurando
                end
            end

            local oldLotId = cardBeingDragged.lotId -- id do ultimo lot a ser usado

            if foundLotIndex ~= nil then
                local targetLot = Lots[foundLotIndex]

                -- Se ela mudou de lote ou é a primeira vez que entra em um
                if oldLotId ~= foundLotIndex then
                    
                    -- Se ela já estava em outro lote antes, remove o count do antigo
                    if oldLotId > 0 then
                        Lots[oldLotId].count = Lots[oldLotId].count - 1
                        debugNumber = debugNumber - 1
                    else
                        -- Se não tinha lote (estava solta), adiciona na tabela de controle
                        table.insert(cardInLot, cardBeingDragged)
                    end

                    -- Atualiza os dados para o novo lote
                    targetLot.count = targetLot.count + 1
                    debugNumber = debugNumber + 1
                    cardBeingDragged.lotId = foundLotIndex
                    cardBeingDragged.isCardInLot = true
                end

                -- Se o menu estiver aberto, tenta colocar em um slot do modal
                if targetLot.isMenuOpen and targetLot:tryPlaceCardInSlots(cardBeingDragged) then
                    -- colocado no slot, não empilha no lote
                else
                    -- Posicionamento (Centralização e Empilhamento)
                    -- lembre fazer animação da carta entrando no lot
                    local targetX, targetY = targetLot:CardStackedPosition(cardBeingDragged.width, cardBeingDragged.height)

                    -- Se houver mais de uma carta, cria o efeito de pilha
                    if targetLot.count > 1 then
                        targetY = targetY + (targetLot.count - 1) * 20 -- 20 é o espaço entre as cartas, esse valor é temporario
                    end

                    cardBeingDragged.x = targetX
                    cardBeingDragged.y = targetY
                    cardBeingDragged.angle = 0
                end

            elseif oldLotId > 0 then
                -- Diminui o contador do lote onde ela estava
                Lots[oldLotId].count = Lots[oldLotId].count - 1
                debugNumber = debugNumber - 1
                
                -- Limpa os dados da carta
                cardBeingDragged.lotId = 0
                cardBeingDragged.isCardInLot = false

                -- Remove da tabela global cardInLot (usando busca reversa segura)
                for i = #cardInLot, 1, -1 do
                    if cardInLot[i] == cardBeingDragged then
                        table.remove(cardInLot, i)
                        break
                    end
                end
            end
        end
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

    --#region layout estilo balatro (mão em arco)
    do
        local hand = {}
        for _, c in ipairs(Cards) do
            if c ~= cardBeingDragged and (not c.isCardInLot) and (c.lotId == 0) then
                table.insert(hand, c)
            end
        end

        local n = #hand
        if n > 0 then
            local screenW = love.graphics.getWidth()
            local screenH = love.graphics.getHeight()

            local centerX = screenW * 0.60
            local baseY = screenH - 170
            local spread = clamp(46, 34, 64)
            local maxAngle = math.rad(12)

            for i, c in ipairs(hand) do
                local t = (n == 1) and 0 or ((i - 1) / (n - 1)) * 2 - 1 -- -1..1
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

    --#region deck + UI decada
    local decadaPanelX = deckUI.x - (decadaBtn.w + 14)
    local decadaPanelY = deckUI.y + 10

    -- painel decada (lado esquerdo do deck)
    love.graphics.setColor(0, 0, 0, 0.35)
    love.graphics.rectangle("fill", decadaPanelX - 10, decadaPanelY - 10, decadaBtn.w + 20, (decadaBtn.h * 2) + decadaBtn.gap + 72, 8, 8)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Decada", decadaPanelX, decadaPanelY - 6)
    love.graphics.print(decadas[decadaIndex], decadaPanelX, decadaPanelY + 16)

    local btnPrevX = decadaPanelX
    local btnPrevY = decadaPanelY + 40
    local btnNextX = decadaPanelX
    local btnNextY = btnPrevY + decadaBtn.h + decadaBtn.gap

    love.graphics.setColor(0.18, 0.18, 0.22, 1)
    love.graphics.rectangle("fill", btnPrevX, btnPrevY, decadaBtn.w, decadaBtn.h, 6, 6)
    love.graphics.rectangle("fill", btnNextX, btnNextY, decadaBtn.w, decadaBtn.h, 6, 6)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("< anterior", btnPrevX, btnPrevY + 6, decadaBtn.w, "center")
    love.graphics.printf("proxima >", btnNextX, btnNextY + 6, decadaBtn.w, "center")

    -- deck
    love.graphics.setColor(0.1, 0.1, 0.1, 0.55)
    love.graphics.rectangle("fill", deckUI.x, deckUI.y, deckUI.w, deckUI.h, 10, 10)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", deckUI.x, deckUI.y, deckUI.w, deckUI.h, 10, 10)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("DECK", deckUI.x, deckUI.y + 10, deckUI.w, "center")
    --#endregion

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
    love.graphics.print(debugNumber, 600, 40)
    -- #cards para saber o tamanho de uma tabela é dessa forma
    --#endregion

    Mouse:draw()
end

return Manager