---@class MapGen.Region
---@field getPolyhedron          fun():Polyhedron
---@field getMultinoiseParams    fun():MapGen.Region.MultinoiseParams
---@field getMultinoise          fun():MapGen.Region.Multinoise
---@field getBufferZone          fun():MapGen.Region.BufferZone
---@field getInterpolationPreset fun():string
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

---@param  polyhedron        Polyhedron
---@param  multinoiseParams  MapGen.Region.MultinoiseParams
---@param  bufferZone        MapGen.Region.BufferZone
---@return MapGen.Region
function Region:new(polyhedron, multinoiseParams, bufferZone)
    local _polyhedron = polyhedron
    local _multinoiseParams = multinoiseParams
    local _bufferZone = bufferZone
    local _interpolationPreset = bufferZone.preset or "linear"
    local _multinoise = {}

    local instance = setmetatable({}, {__index = self})

    function instance:getPolyhedron() return _polyhedron end
    function instance:getMultinoiseParams() return _multinoiseParams end
    function instance:getMultinoise() return _multinoise end
    function instance:getBufferZone() return _bufferZone end
    function instance:getInterpolationPreset() return _interpolationPreset end
    
    function instance:initMultinoise()
        _multinoise = multinoiseParamsToMultinoise(_multinoiseParams)
    end

    return instance
end

return Region
