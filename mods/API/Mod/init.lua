--- Luanti mod
---@class Mod
---@field public name  string Technical name of the mod.
---@field public path  string Path to the mod folder.
---@field public Class  table A public class that provides a mod.
---@field public require  fun(FileName:string):table
Mod = {}


--- Return table with mod name, path and require function.
---@return {name: string, path: string, require: fun(FileName : string): table}
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
---@param ... any?
---@return    table
-- TODO: возможно стоит создать какой-то абстрактный класс,
-- который будет является алеасом на table и будет обозначать наш класс
function Mod:getModClassInstance(...)
	local instance = self.Class:new(...)

	return instance
end

--- Inherits a child class from a parent class
---@static
---@param ParentClass  table
---@param ChildClass   table?
---@return table
function Mod:getClassExtended(ParentClass, ChildClass)
	local ChildClass = setmetatable(ChildClass or {}, { __index = ParentClass })

	return ChildClass
end

--- Inherits a child class from a parent public class provided by the mod.
---@static
---@param ChildClass   table?
---@return table
function Mod:getModClassExtended(ChildClass)
	local ChildClass = Mod:getClassExtended(self.Class, ChildClass or {})

	return ChildClass
end

