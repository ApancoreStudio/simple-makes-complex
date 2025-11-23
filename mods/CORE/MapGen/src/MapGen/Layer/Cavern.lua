local mathMin,  mathMax,  mathAbs
	= math.min, math.max, math.abs

---@class MapGen.Layer.Cavern
---@field name            string
---@field minY            number
---@field maxY            number
---@field smoothDistance  number
---@field threshold       number
---@field getNoise        fun():ValueNoise
---@field initNoise       fun()
---@field getGroups       fun():table<string, number>
local Cavern = {}

---Definition table for the `MapGen.Layer.Cavern`.
---
---**Only for EmmyLua.**
---@class MapGen.Layer.CavernDef
---@field minY            number
---@field maxY            number
---@field noiseParams     NoiseParams
---@field smoothDistance  number
---@field threshold       number?
---@field groups          table<string, number>?

---@param name  string
---@param def   MapGen.Layer.CavernDef
---@return      MapGen.Layer.Cavern
function Cavern:new(name, def)
	assert(def.maxY > def.minY, 'maxY there should be more minY')
	assert(def.smoothDistance < mathAbs(def.maxY - def.minY)/2, 'The smoothing distance cannot be greater than half the distance between minY and maxY')

	---@type NoiseParams
	local _noiseParams = def.noiseParams

	---@diagnostic disable-next-line: missing-fields
	---@type ValueNoise
	local _noise = {} -- note: must be nil until luanti mapgen objects are loaded.

	if def.threshold == nil then
		def.threshold = 0.0
	end

	local _groups

	if def.groups == nil then
		_groups = {}
	else
		_groups = def.groups
	end

	---@type MapGen.Layer.Cavern
	local instance = setmetatable({
		name           = name,
		minY           = def.minY,
		maxY           = def.maxY,
		smoothDistance = def.smoothDistance,
		threshold      = def.threshold,
	}, {__index = self})

	function instance:getNoise()
		return _noise
	end

	function instance:initNoise()
		--if not table.is_empty(_noise) then
		--	minetest.log('warning', 'Cavern noise has already been initialized. Re-initialization is not recommended.')
		--end

		_noise = core.get_value_noise(_noiseParams)
	end

	function instance:getGroups()
		return table.copy_with_metatables(_groups)
	end

	return instance
end

---@param y               number
---@param minY            number
---@param maxY            number
---@param smoothDistance  number
---@return                number
local function calcCavernWeight(y, smoothDistance, minY, maxY)
	local maxDist = maxY - y
	local minDist = y - minY

	return mathMax(0, mathMin(maxDist / smoothDistance, minDist / smoothDistance, 1))
end

---@param x          number
---@param y          number
---@param z          number
---@return           boolean
function Cavern:isCavern(x, y, z)
	local minY, maxY = self.minY, self.maxY

	if y > maxY or y < minY then
		return false
	end

	local noise = self:getNoise()
	local weight = calcCavernWeight(y, self.smoothDistance, minY, maxY)

	return noise:get_3d({x = x, y = y, z = z}) * weight > self.threshold
end

return Cavern