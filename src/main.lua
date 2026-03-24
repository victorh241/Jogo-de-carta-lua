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

    gameManager:load()
end

function love.update(dt)
    gameManager:update(dt)
end

function love.draw()-- a ordem do desenho é definida pela chamada de função
    gameManager:draw()
end