local core, setmetatable = core, setmetatable

local modInfo = Mod.getInfo()

---@type MapGen.Region
local Region = modInfo.require("Region")

---@class MapGen.Region.Region3D : MapGen.Region
local Region3D = Api.getClassExtended(Region, {})

---@param params  table
---@return MapGen.Region.Region3D
function Region3D:new(params)
	local instance = Region:new(params)
	instance.type = "3d"
	return setmetatable(instance, {__index = Region3D})
end

function Region3D:initNoises()
	self.noiseCave = core.get_value_noise(self.noiseParamsCave)
	self.noiseTemp = core.get_value_noise(self.noiseParamsTemp)
	self.noiseHumid = core.get_value_noise(self.noiseParamsHumid)
end
