_G.Mod = {}

function Mod:new(addToGlobal)
	for key, value in pairs(addToGlobal) do
		_G[key] = value
	end
	local modName = core.get_current_modname()
	local modPath = core.get_modpath(modName)

	local modTable = ModTable:new(modName, modPath)
	modTable.require = ModTable:getRequire()
end
