local modInfo = Mod.getInfo()
local Region = modInfo.require()("Region")

local core, setmetatable = core, setmetatable

-- 2D Region implementation
local Region2D = setmetatable({}, {__index = Region})

function Region2D:new(params)
	local instance = Region.new(self, params)
	instance.type = "2d"
	return setmetatable(instance, {__index = Region2D})
end

function Region2D:initNoises()
	self.noiseHeight = core.get_value_noise(self.noiseParamsHeight)
	self.noiseTemp = core.get_value_noise(self.noiseParamsTemp)
	self.noiseHumid = core.get_value_noise(self.noiseParamsHumid)
end
