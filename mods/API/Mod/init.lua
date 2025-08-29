--- Luanti mod
---@class Mod
---@field public name  string Technical name of the mod.
---@field public path  string Path to the mod folder.
---@field public Class  table A public class that provides a mod.
---@field public require  fun(FileName:string)
Mod = {
	name = nil,
	path = nil,
	require = nil,
	Class = nil,
}


--- Return table with mod name, path and require function.
---@return {name: string, path: string, require: fun(FileName : string)}
function Mod.getInfo()
	local name = core.get_current_modname()
	local path = core.get_modpath(name)
	local require = Require.getModRequire(name, path)

	return {name = name, path = path, require = require}
end

function Mod:new()
	---@type Mod
	self = setmetatable(Mod.getInfo(), { __index = self })

	return self
end

--- Get an instance of a public class provided by a mod
---@return table
-- TODO: возможно стоит создать какой-то абстрактный класс,
-- который будет является алеасом на table и будет обозначать наш класс
function Mod:getClassInstance()
	local instance = setmetatable({}, { __index = self.Class })

	return instance
end

--- Inherit from a class provided by the mod
---@param ChildClass  table
---@return table
function Mod:getClassExtended(ChildClass)
	local instance = setmetatable(ChildClass or {}, { __index = self.Class })

	return instance
end