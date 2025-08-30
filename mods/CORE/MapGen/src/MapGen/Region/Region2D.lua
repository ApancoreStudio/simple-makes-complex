local core, setmetatable = core, setmetatable

local modInfo = Mod.getInfo()

---@type MapGen.Region
local Region = modInfo.require("Region")

---@class MapGen.Region.Region2D : MapGen.Region
local Region2D = Mod:getClassExtended(Region, {})

---@param params  table
---@return MapGen.Region.Region2D
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
