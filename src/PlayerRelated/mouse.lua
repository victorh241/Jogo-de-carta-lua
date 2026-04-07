local Mouse = {}

local imageCursor -- por hora eu não tenho vou fazer uma bola

function Mouse:load(x, y)
    Mouse = {
        x = x or 0,
        y = y or 0,
        isPressed = false,
        isHovering = false,
        cardBeingDragged = nil
    }

    setmetatable(Mouse, {__index = Mouse})
end

function Mouse:update(dt) -- só coisa basica o bruto eu vou colocar no gamamaneger
    self.x = love.mouse.getX()
    self.y = love.mouse.getY()
end

function Mouse:draw()
    if Mouse.isPressed then -- as cores só para debugging
        love.graphics.setColor(0, 1, 0, 1) -- cor: azul
    else
        love.graphics.setColor(0, 0, 1, 1) -- cor: verde
    end

    if Mouse.isHovering then
        love.graphics.setColor(1, 0, 0, 1) -- cor: vermelho
    end

    love.graphics.circle("fill", Mouse.x, Mouse.y, 15)
end

function love.mousepressed(x, y, button, istouch) -- função para saber se o mouse foi precionado
    if button == 1 then
        Mouse.isPressed = true
    end
end

function love.mousereleased(x, y, button, istouch) -- função para saber se o mouse foi solto
    if button == 1 then
        Mouse.isPressed = false
    end
end

return Mouse