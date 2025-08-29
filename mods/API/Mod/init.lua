-- TODO: ANNOTATE!!!!!!!!!!
Mod = {}

function Mod.getInfo()
	local name = core.get_current_modname()
	local path = core.get_modpath(name)
	local require = Require.getModRequire(name, path)
	
	return {name = name, path = path, require = require}
end

-- Mod.

-- Mod Extend

function Mod:new()
	local mod = Mod.getInfo()

	setmetatable(mod, self)
	self.__index = self

	return mod
end
