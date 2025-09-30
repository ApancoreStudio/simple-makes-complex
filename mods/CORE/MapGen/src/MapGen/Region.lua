-- TODO: replace `table` with `vector` for minPos and maxPos
---@class MapGen.Region
local Region = {}

---@param multinoiseParams  MapGen.Region.MultinoiseParams -- ??? TODO: should be it's own class in EmmyLua
---@return MapGen.Region.Multinoise
local function multinoiseParamsToMultinoise(multinoiseParams)
	---@type MapGen.Region.Multinoise
	local multinoise = {}

	for noiseName, noiseParams in pairs(multinoiseParams) do
		multinoise[noiseName] = core.get_value_noise(noiseParams)
	end

	return multinoise
end

---@param  minPos            table
---@param  maxPos            table
---@param  multinoiseParams  MapGen.Region.MultinoiseParams
---@return MapGen.Region
function Region:new(minPos, maxPos, multinoiseParams)

	local _minPos = minPos
	local _maxPos = maxPos
	local _multinoiseParams = multinoiseParams

	local _multinoise = {}

	local instance = setmetatable({}, {__index = self})

	---@return  {x:number, y:number, z:number}
	function instance:getMinPos()
		return _minPos
	end
	function instance:getMaxPos()
		return _maxPos
	end
	function instance:getMultinoiseParams()
		return  _multinoiseParams
	end

	---@return MapGen.Region.Multinoise
	function instance:getMultinoise()
		return _multinoise
	end

	function instance:initMultinoise()
		_multinoise = multinoiseParamsToMultinoise(_multinoiseParams)
	end

	return instance
end

return Region
