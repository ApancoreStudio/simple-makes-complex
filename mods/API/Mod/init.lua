---Luanti mod
---@class Mod
---@field name       string Technical name of the mod.
---@field shortName  string
---@field path       string Path to the mod folder.
---@field Class      any    A public class that provides a mod.
---@field require    fun(FileName:string):table
Mod = {}

---Returns the mod name without prefixes
---@param name  string
---@return      string
local function getShortModName(name)
	local shortName = string.gsub(name, '%w*__', '')

	return shortName
end

---Return table with mod name, path and require function.
---@param modname?  string  Specify a name of mod to get its info
---@return {name: string, shortName: string, path: string, require: fun(FileName : string): table}
function Mod.getInfo(modname)
	local name = modname or core.get_current_modname()
	local shortName = getShortModName(name)
	local path = core.get_modpath(name)
	local require = Require.getModRequire(name, path)

	return {name = name, shortName = shortName, path = path, require = require}
end

--[[
function Mod:new()
	---@type Mod
	local instance = setmetatable(Mod.getInfo(), { __index = self })

	return instance
end

---Get an instance of a public class provided by a mod
---@param ... any?
---@return    table
function Mod:getModClassInstance(...)
	local classInstance = self.Class:new(...)

	return classInstance
end

---Inherits a child class from a parent class
---@param ParentClass  table
---@param ChildClass   table?
---@return             table
function Mod:getClassExtended(ParentClass, ChildClass)
	local childClass = setmetatable(ChildClass or {}, { __index = ParentClass })

	return childClass
end

---Inherits a child class from a parent public class provided by the mod.
---@param ChildClass   table?
---@return             table
function Mod:getModClassExtended(ChildClass)
	local childClass = Mod:getClassExtended(self.Class, ChildClass or {})

	return childClass
end  --]]

return Mod