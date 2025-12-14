---@class CraftSystem
---@field registeredCrafts  table
local CraftSystem = {
	registeredCrafts = {}
}

function CraftSystem.registerCraftType()
end

function CraftSystem.registerCraft(type, recipe, craftFunction)
end

function CraftSystem.getCraftResult(type, recipe, craftFunction)
end

return CraftSystem