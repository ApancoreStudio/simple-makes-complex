local modInfo = Mod.getInfo()
local require = modInfo.require

---@type MapGen.Peak
local Peak = require('MapGen.Peak')

---@class MapGen.Triangulation.FakePeak : MapGen.Peak
---@field id          number
---@field getPeakPos  fun():vector
local FakePeak = Mod:getClassExtended(Peak, {})

---@param peakPos  vector
---@return         MapGen.Peak
function FakePeak:new(peakPos)
	---@diagnostic disable-next-line: missing-fields, param-type-not-match
	local instance = Peak:new(peakPos, {}, 1)

	return instance
end

return FakePeak