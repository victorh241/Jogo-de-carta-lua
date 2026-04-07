-- vou fazer um jogo tipo balatro de pontuação cliquer com pegada diferente
local Mouse = require("PlayerRelated/mouse")
local Card = require("Entities/Card")
local Lot = require("Entities/lots")
local gameManager = require("GameManagers/GameManegar")

-- #region variaveis
local cards = {}
local cardBeingDragged = nil
local cardInLot = {}

local Lots = {}
--#endregion

function love.load()
    love.window.setMode(1280, 720)
    love.graphics.setBackgroundColor(0.2, 0.2, 0.3)

    gameManager:load()
end

function love.update(dt)
    gameManager:update(dt)
end

function love.draw()-- a ordem do desenho é definida pela chamada de função
    gameManager:draw()
end