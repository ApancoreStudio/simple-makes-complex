---@class MapGen.Cell
---@field getCellPos           fun():vector
---@field getMultinoiseParams  fun():MapGen.Cell.MultinoiseParams
---@field getMultinoise        fun():MapGen.Cell.Multinoise
---@field initMultinoise       fun()
---@field getWeightFactor      fun():number
local Cell = {}

---@param multinoiseParams  MapGen.Cell.MultinoiseParams
---@return MapGen.Cell.Multinoise
local function multinoiseParamsToMultinoise(multinoiseParams)
	---@type MapGen.Cell.Multinoise
	local multinoise = {}

	for noiseName, noiseParams in pairs(multinoiseParams) do
		multinoise[noiseName] = core.get_value_noise(noiseParams)
	end

	return multinoise
end

---@param  cellPos           vector
---@param  multinoiseParams  MapGen.Cell.MultinoiseParams
---@param  weightFactor      number  TODO: возможно этот параметр не пригодится
---@return MapGen.Cell
function Cell:new(cellPos, multinoiseParams, weightFactor)
	---@type  vector
	local _cellPos = cellPos
	---@type  MapGen.Cell.MultinoiseParams
	local _multinoiseParams = multinoiseParams

	if weightFactor < 0 then
		weightFactor = 1
	end

	---@type MapGen.Cell.Multinoise
	local _multinoise = {} -- note: must be empty until luanti mapgen objects are loaded.

	---@type MapGen.Cell
	local instance = setmetatable({}, {__index = self})

	function instance:getCellPos()
		return _cellPos
	end

	function instance:getMultinoiseParams()
		return  _multinoiseParams
	end

	function instance:getMultinoise()
		return _multinoise
	end

	function instance:initMultinoise()
		if not table.is_empty(_multinoise) then
			minetest.log('warning', 'Multinoise has already been initialized. Re-initialization is not recommended.')
		end

		_multinoise = multinoiseParamsToMultinoise(_multinoiseParams)
		print(dump(_multinoise))
	end

	function instance.getWeightFactor()
		return weightFactor
	end

	return instance
end

return Cell
