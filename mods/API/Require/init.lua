_G.Require = {}
local loadedModules = {}
local DS = '/'

function Require.getModRequire()
	return function(fileName)
		local modName = self.name
		local modPath = self.path
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
end
