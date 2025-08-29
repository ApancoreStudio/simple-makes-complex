local modInfo = Mod.getInfo()
local Region = modInfo.require()("Region")

local core, setmetatable = core, setmetatable

-- 3D Region implementation
local Region3D = setmetatable({}, {__index = Region})

function Region3D:new(params)
	local instance = Region.new(self, params)
	instance.type = "3d"
	return setmetatable(instance, {__index = Region3D})
end

function Region3D:initNoises()
	self.noiseCave = core.get_value_noise(self.noiseParamsCave)
	self.noiseTemp = core.get_value_noise(self.noiseParamsTemp)
	self.noiseHumid = core.get_value_noise(self.noiseParamsHumid)
end
