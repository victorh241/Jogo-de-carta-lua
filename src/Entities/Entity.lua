local Entity = {}
EntityType = ""
Entity.__index = Entity

function Entity:new(type, x, y)
    local newEntity = {}
    newEntity.x = x or 0
    newEntity.y = y or 0
    newEntity.type = type or ""

    setmetatable(newEntity, self)
    self.__index = self

    return newEntity
end

return Entity