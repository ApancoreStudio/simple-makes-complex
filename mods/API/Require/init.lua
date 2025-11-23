Require = {}
local loadedModules = {}
local DS = '/'

--- Creates a scoped require function for a specific module
--- This custom require handles module loading relative to a specific module path,
--- prevents duplicate loading, and caches results appropriately.
--- @param modName  string    Namespace identifier for the module (prevents global collisions)
--- @param modPath  string    Absolute base path to the module's directory
--- @return function require  Custom require function scoped to the specified module
function Require.getModRequire(modName, modPath)
	--- Custom require function for module-specific loading
    --- Resolves files relative to modPath/src, converts dot-notation to path separators
    --- @param fileName  string   Module path in dot-notation (e.g. "lib.utils")
    --- @return any loadedModule  The loaded module's return value or cached result
	local function require(fileName)
		local fullName = modName .. '..' .. fileName

		local module = loadedModules[fullName]
		if module ~= nil then
			return module
		end

		local result = dofile(modPath .. DS .. 'src' .. DS .. fileName:gsub('%.', DS) .. '.lua')

		if result ~= nil then
			loadedModules[fullName] = result
		else
			loadedModules[fullName] = true
		end

		return loadedModules[fullName]
	end

	return require
end

return Require