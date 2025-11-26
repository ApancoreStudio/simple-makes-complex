---@class MapGen.Peak
---@field id                   number
---@field getPeakPos           fun():vector
---@field getMultinoiseParams  fun():MapGen.Peak.MultinoiseParams
---@field getMultinoise        fun():MapGen.Peak.Multinoise
---@field initMultinoise       fun()
---@field getGroups            fun():table<string, number>
local Peak = {
	id = 0,
}

-- --- Helpers functions ---

---@param  multinoiseParams  MapGen.Peak.MultinoiseParams
---@return MapGen.Peak.Multinoise
local function multinoiseParamsToMultinoise(multinoiseParams)
	---@diagnostic disable-next-line: missing-fields
	---@type MapGen.Peak.Multinoise
	local multinoise = {}

	for noiseName, noiseParams in pairs(multinoiseParams) do
		multinoise[noiseName] = core.get_value_noise(noiseParams)
	end

	return multinoise
end



-- --- Class registration ---

---@param peakPos           vector
---@param multinoiseParams  MapGen.Peak.MultinoiseParams
---@param groups?           table<string, number>
---@return                  MapGen.Peak
function Peak:new(peakPos, multinoiseParams, groups)
	---@type  vector
	local _peakPos = peakPos
	---@type  MapGen.Peak.MultinoiseParams
	local _multinoiseParams = multinoiseParams

	local _groups

	if groups == nil then
		_groups = {}
	else
		_groups = groups
	end

	---@diagnostic disable-next-line: missing-fields
	---@type MapGen.Peak.Multinoise
	local _multinoise = {} -- note: must be empty until luanti mapgen objects are loaded.

	---@type MapGen.Peak
	local instance = setmetatable({},
	{
		__index    = self,
		__tostring = self.toString,
		__eq       = self.eq
	})

	function instance:getPeakPos()
		return vector.new(_peakPos.x, _peakPos.y, _peakPos.z)
	end

	function instance:getMultinoiseParams()
		return  _multinoiseParams
	end

	function instance:getMultinoise()
		if not table.is_empty(_multinoise) then
			error('Attempt to get `MapGen.Triangulation.FakePeak` noise (empty noise).')
		end

		return _multinoise
	end

	function instance:initMultinoise()
		if not table.is_empty(_multinoise) then
			Logger.warningLog('Multinoise has already been initialized. Re-initialization is not recommended.')
		end

		if not table.is_empty(_multinoiseParams) then
			error('Attempt to initialize `MapGen.Triangulation.FakePeak` noise (noise parameter empty).')
		end

		_multinoise = multinoiseParamsToMultinoise(_multinoiseParams)
	end

	function instance:getGroups()
		return _groups
	end

	return instance
end

---Returns a string describing the object in a readable form.
---@return string
function Peak:toString()
	local pos = self:getPeakPos()
	return ('Peak (%s) x: %.2f y: %.2f z: %.2f'):format( self.id, pos.x, pos.y, pos.z)
end

---Returns true if the peaks are equivalent.
---@param other  MapGen.Peak
---@return       boolean
function Peak:eq(other)
	local pos1 = self:getPeakPos()
	local pos2 = other:getPeakPos()

	return pos1.x == pos2.x and pos1.z == pos2.z
end

return Peak
