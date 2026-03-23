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

local cardBeingDragged = nil
--#endregion

--#region variaveis para debug
local debugNumber = 0

--#endregion

function Manager:load()
    Mouse:load(0, 0)

    -- #region cards
    local CardTest1 = Card:new(400, 300)
    local CardTest2 = Card:new(300, 300)
    local CardTest3 = Card:new(200, 300)

    table.insert(Cards, cardTest1)
    table.insert(Cards, cardTest2)
    table.insert(Cards, cardTest3)
    --#endregion

    --#region lots
    local lotTest1 = Lot:new(100, 200)
    table.insert(Lots, lotTest1)
    --#endregion
end

function Manager:update(dt)
    Mouse.update(dt)

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

            table.remove(card, i)
            table.insert(Cards, card)
        end
    end

    if cardBeingDragged ~= nil and Mouse.isPressed then
        cardBeingDragged.x = cardBeingDragged.x + ((Mouse.x - cardBeingDragged.width/2 + 20) - cardBeingDragged.x) * dt * 15
        cardBeingDragged.y = cardBeingDragged.y + ((Mouse.y - cardBeingDragged.height/2 - 20) - cardBeingDragged.y) * dt * 15
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
end

function Manager:draw()
    Mouse:draw()
end