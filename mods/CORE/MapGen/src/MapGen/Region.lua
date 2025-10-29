---@class MapGen.Region
---@field getMinPos            fun():vector
---@field getMaxPos            fun():vector
---@field getMultinoiseParams  fun():MapGen.Region.MultinoiseParams
---@field getMultinoise        fun():MapGen.Region.Multinoise
---@field initMultinoise       fun()
---@field getWeightFactor      fun():number
local Region = {}

---@param multinoiseParams  MapGen.Region.MultinoiseParams
---@return MapGen.Region.Multinoise
local function multinoiseParamsToMultinoise(multinoiseParams)
	---@type MapGen.Region.Multinoise
	local multinoise = {}

	for noiseName, noiseParams in pairs(multinoiseParams) do
		multinoise[noiseName] = core.get_value_noise(noiseParams)
	end

	return multinoise
end

---@param  minPos            vector
---@param  maxPos            vector
---@param  multinoiseParams  MapGen.Region.MultinoiseParams
---@param  weightFactor      number
---@return MapGen.Region
function Region:new(minPos, maxPos, multinoiseParams, weightFactor)

	---@type  vector
	local _minPos = minPos
	---@type  vector
	local _maxPos = maxPos
	---@type  MapGen.Region.MultinoiseParams
	local _multinoiseParams = multinoiseParams

	if weightFactor < 0 then
		weightFactor = 1
	end

	---@type MapGen.Region.Multinoise
	local _multinoise = {}

	---@type MapGen.Region
	local instance = setmetatable({}, {__index = self})

	function instance:getMinPos()
		return _minPos
	end

	---@return  vector
	function instance:getMaxPos()
		return _maxPos
	end

	function instance:getMultinoiseParams()
		return  _multinoiseParams
	end

	function instance:getMultinoise()
		return _multinoise
	end

	function instance:initMultinoise()
		_multinoise = multinoiseParamsToMultinoise(_multinoiseParams)
		print(dump(_multinoise))
	end

	function instance.getWeightFactor()
		return weightFactor
	end

	return instance
end

return Region
