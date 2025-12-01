local modInfo = Mod.getInfo('smc__core__map_gen')
local require = modInfo.require

---@type MapGen.Peak
local Peak = require('MapGen.Peak')

---Allows you to create a `MapGen.Peak` without specifying a noise parameter.
---
---**WARNING: MUST NOT BE PARTICIPATED IN GENERATION**
---@class MapGen.Triangulation.FakePeak : MapGen.Peak
---@field id          number
---@field getPeakPos  fun():vector
local FakePeak = Class.extend(Peak, {})

---Returns a fake `MapGen.Peak` that has no noise parameters.
---Note that the initialized peak should not be used in generation.
---@param peakPos  vector
---@return         MapGen.Peak
function FakePeak:new(peakPos)
	---@diagnostic disable-next-line: missing-fields, param-type-not-match
	local instance = Peak:new(peakPos, {}, 1)

	return instance
end

return FakePeak
