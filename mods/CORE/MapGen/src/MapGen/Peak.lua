---@class MapGen.Peak
---@field id                   number
---@field getPeakPos           fun():vector
---@field getMultinoiseParams  fun():MapGen.Peak.MultinoiseParams
---@field getMultinoise        fun():MapGen.Peak.Multinoise
---@field initMultinoise       fun()
---@field getWeightFactor      fun():number
local Peak = {
	id = 0,
}

---@param multinoiseParams  MapGen.Peak.MultinoiseParams
---@return MapGen.Peak.Multinoise
local function multinoiseParamsToMultinoise(multinoiseParams)
	---@type MapGen.Peak.Multinoise
	local multinoise = {}

	for noiseName, noiseParams in pairs(multinoiseParams) do
		multinoise[noiseName] = core.get_value_noise(noiseParams)
	end

	return multinoise
end

---@param  peakPos           vector
---@param  multinoiseParams  MapGen.Peak.MultinoiseParams
---@param  weightFactor      number  TODO: возможно этот параметр не пригодится
---@return MapGen.Peak
function Peak:new(peakPos, multinoiseParams, weightFactor)
	---@type  vector
	local _peakPos = peakPos
	---@type  MapGen.Peak.MultinoiseParams
	local _multinoiseParams = multinoiseParams

	if weightFactor < 0 then
		weightFactor = 1
	end

	---@type MapGen.Peak.Multinoise
	local _multinoise = {} -- note: must be empty until luanti mapgen objects are loaded.

	---@type MapGen.Peak
	local instance = setmetatable({}, {__index = self})

	function instance:getPeakPos()
		return _peakPos
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
	end

	function instance.getWeightFactor()
		return weightFactor
	end

	return instance
end

---@param other  MapGen.Peak
function Peak:__eq( other )
	local pos1 = self:getPeakPos()
	local pos2 = other:getPeakPos()

	return pos1.x == pos2.x and pos1.z == pos2.z
end

function Peak:toString()
	return ('Peak (%s) x: %.2f y: %.2f'):format( self.id, self:getPeakPos().x, self:getPeakPos().y )
end

---@param p MapGen.Peak
function Peak:dist2(p)
	local pos1 = self:getPeakPos()
	local pos2 = p:getPeakPos()

	local dx, dy = (pos1.x - pos2.x), (pos1.z - pos2.z)
	return dx * dx + dy * dy
end

---@param p MapGen.Peak
function Peak:dist(p)
	return math.sqrt(self:dist2(p))
end

function Peak:isInCircle(cx, cy, r)
	local pos = self:getPeakPos()

	local dx = (cx - pos.x)
	local dy = (cy - pos.z)

	return ((dx * dx + dy * dy) <= (r * r))
end

return Peak
