---For EmmyLua only

---@class MapGen.Region.NoiseParams
---@field offset number
---@field scale number
---@field spread vector -- TODO: describe vector class from Luanti (push Alek)
---@field seed number
---@field octaves number
---@field persistence number
---@field lacunarity number
---@field flags string?

---@class MapGen.Region.MultinoiseParams
---@field landscapeNoiseParams  MapGen.Region.NoiseParams?
---@field tempNoiseParams       MapGen.Region.NoiseParams?
---@field humidityNoiseParams   MapGen.Region.NoiseParams?
local MultinoiseParams = {}

return MultinoiseParams