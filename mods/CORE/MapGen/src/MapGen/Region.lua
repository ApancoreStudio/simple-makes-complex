--============================================================
--=======================WARNING!!!===========================
--============================================================
--======================THIS=FILE=IS==========================
--=======================STILL==WIP===========================
--=========================BY==ME=============================
--============================================================
--===================================Doloment=================
--============================================================

-- TODO: replace `table` with `vector` for minPos and maxPos
---@class MapGen.Region
---@field minPos  table
---@field maxPos  table
---@field noises  MapGen.Region.Noises
---@field noisesParams MapGen.Region.Noises -- ??? TODO: should be it's own class in EmmyLua
local Region = {}

---@param noisesParams  MapGen.Region.Noises -- ??? TODO: should be it's own class in EmmyLua
---@return              MapGen.Region.Noises
local function paramsToNoises(noisesParams)
	---@type MapGen.Region.Noises
	local noises = {}

	for noiseName, noiseParams in pairs(noisesParams) do
		noises[noiseName] = core.get_value_noise(noiseParams)
	end

	return noises
end

---@param  minPos        table
---@param  maxPos        table
---@param  noisesParams  MapGen.Region.Noises
---@return MapGen.Region
function Region:new(minPos, maxPos, noisesParams)

	local _minPos = minPos
	local _maxPos = maxPos
	local _noisesParams = noisesParams

	local _noises = {}

	local instance = setmetatable({}, {__index = self})

	function instance:getMinPos()        return        _minPos end
	function instance:getMaxPos()        return        _maxPos end
	function instance:getNoisesParams()  return  _noisesParams end
	function instance:getNoises()        return        _noises end

	function instance:initNoises()
		_noises = paramsToNoises(_noisesParams)
	end

	return instance
end

return Region