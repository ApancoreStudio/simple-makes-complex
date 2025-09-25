---@class MapGenV.Region
---@field minPos  table
---@field maxPos  table
---@field noises  MapGenV.Region.Noises
local Region = {}

---@param noisesParams  MapGenV.Region.Noises
---@return              MapGenV.Region.Noises
local function paramsToNoises(noisesParams)
	---@type MapGenV.Region.Noises
	local noises = {}

	for noiseName, noiseParams in pairs(noisesParams) do
		noises[noiseName] = core.get_value_noise(noiseParams)
	end

	return noises
end

---@param  minPos    table
---@param  maxPos    table
---@param  noisesParams    MapGenV.Region.Noises
---@return MapGenV.Region
function Region:new(minPos, maxPos, noisesParams)
	---@type MapGenV.Region
	local instance = setmetatable({
		minPos = minPos,
		maxPos = maxPos,
		noises = noisesParams --paramsToNoises(noisesParams)
	}, {__index = self})

	return instance
end

return Region