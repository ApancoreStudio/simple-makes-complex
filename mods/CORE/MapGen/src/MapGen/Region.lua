---@class MapGen.Region
---@field minPos  table
---@field maxPos  table
---@field noises  MapGen.Region.Noises
local Region = {}

---@param noisesParams  MapGen.Region.Noises
---@return              MapGen.Region.Noises
local function paramsToNoises(noisesParams)
	---@type MapGen.Region.Noises
	local noises = {}

	for noiseName, noiseParams in pairs(noisesParams) do
		noises[noiseName] = core.get_value_noise(noiseParams)
	end

	return noises
end

---@param  minPos    table
---@param  maxPos    table
---@param  noisesParams    MapGen.Region.Noises
---@return MapGen.Region
function Region:new(minPos, maxPos, noisesParams)
	---@type MapGen.Region
	local instance = setmetatable({
		minPos = minPos,
		maxPos = maxPos,
		noises = noisesParams --paramsToNoises(noisesParams)
	}, {__index = self})

	return instance
end

return Region