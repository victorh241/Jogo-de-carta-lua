-- vou fazer um jogo tipo balatro de pontuação cliquer com pegada diferente
local Mouse = require("PlayerRelated/mouse")
local Card = require("Entities/Card")
local Lot = require("Entities/lots")
local gameManager = require("GameManagers/GameManegar")

-- #region variaveis
local decay = -15
local cards = {}
local cardBeingDragged = nil
local cardInLot = {}

local Lots = {}
local debugNumber = 0
--#endregion

function lerp(a, b, dt)
    return b + (a-b) * math.exp(decay * dt)
end

local function spring(current, target, velocity, k, d, dt) -- depois fazer a animação
    local force = -k * (current - target) - d * velocity
    velocity = velocity + force * dt
    current = current + velocity * dt
    return current, velocity
end

function love.load()
    love.window.setMode(800, 600)
    love.graphics.setBackgroundColor(0.2, 0.2, 0.3)

    -- #region load cards
    --- cards
    cardTest1 = Card:new(400, 300)
    cardTest2 = Card:new(200, 300)
    cardTest3 = Card:new(300, 300)

    table.insert(cards, cardTest1)
    table.insert(cards, cardTest2)
    table.insert(cards, cardTest3)
    -- #endregion

    -- #region load lots
    
    lotTest1 = Lot:new(100, 200)
    table.insert(Lots, lotTest1)

    --#endregion
end

function love.update(dt)
    Mouse.update(dt)

    --#region card logica
    Mouse.isHovering = false
    
    for i = #cards, 1, -1 do
        local card = cards[i]
        local isCardPicked = card:isCardPicked(Mouse.x, Mouse.y, Mouse.isPressed, cardBeingDragged ~= nil)

        if card.isHovering then
            Mouse.isHovering = true
        end

        if isCardPicked then
            cardBeingDragged = card

            table.remove(cards, i)
            table.insert(cards, card)
            break
        end
    end
    --#endregion

    --#region lot logica
    -- revisar codigo para aprender mais sobre algoritomo
    if not Mouse.isPressed then
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

                -- Posicionamento (Centralização e Empilhamento)
                -- lembre fazer animação da carta entrando no lot
                local targetX, targetY = targetLot:CardStackedPosition(cardBeingDragged.width, cardBeingDragged.height)

                -- Se houver mais de uma carta, cria o efeito de pilha
                if targetLot.count > 1 then
                    targetY = targetY + (targetLot.count - 1) * 20 -- 20 é o espaço entre as cartas, esse valor é temporario
                end

                cardBeingDragged.x = targetX
                cardBeingDragged.y = targetY

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

            -- Finaliza o arrasto
            cardBeingDragged = nil
        end
    end
    --#endregion

    --#region animação pra pegar a carta
    if cardBeingDragged ~= nil and Mouse.isPressed then
        cardBeingDragged.x = cardBeingDragged.x + ((Mouse.x - cardBeingDragged.width/2) - cardBeingDragged.x) * dt * 15
        cardBeingDragged.y = cardBeingDragged.y + ((Mouse.y - cardBeingDragged.height/2 + 10) - cardBeingDragged.y) * dt * 15
    end
    --#endregion
end

function love.draw()-- a ordem do desenho é definida pela chamada de função
    --#region desenhar lots
    for i, lot in ipairs(Lots) do
        lot:draw()
    end
    --#endregion

    --#region desenhar cartas
    -- desenhar as cartas
    for i, card in ipairs(cards) do
        card:draw()
    end
    --#endregion

    --#region debug
    -- texto pra debugar
    local _mousePosX = Mouse.x
    local _mousePosY = Mouse.y
    
    love.graphics.setColor(1, 1, 1, 1) -- this is white
    love.graphics.print(_mousePosX, 500, 20)
    love.graphics.print(_mousePosY, 600, 20)
    love.graphics.print(debugNumber, 600, 40)
    print("Tipo de metatable: ", getmetatable(Lots[1]))
    -- #cards para saber o tamanho de uma tabela é dessa forma
    --#endregion

    Mouse:draw()
end