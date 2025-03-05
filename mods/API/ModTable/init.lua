ModTable = {}

local modLoggers = {}
local loadedModules = {}
local DS = '/'

function ModTable:getRequire()
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

function ModTable:new(name, path)
	local modTable = {
		name = name,
		path = path,
	}

	setmetatable(modTable, self)
	self.__index = self

	return modTable
end
