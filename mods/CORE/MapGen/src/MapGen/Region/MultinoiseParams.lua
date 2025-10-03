---For EmmyLua only

 -- TODO: Когда в хелпер добавятся аннотации шумов, надо будет удалить этот класс и заменить его на хелперский
---@class MapGen.Region.NoiseParams
---@field offset       number
---@field scale        number
---@field spread       vector
---@field seed         number
---@field octaves      number
---@field persistence  number
---@field lacunarity   number
---@field flags string?

---@class MapGen.Region.MultinoiseParams
---@field landscapeNoise  MapGen.Region.NoiseParams?
---@field tempNoise       MapGen.Region.NoiseParams?
---@field humidityNoise   MapGen.Region.NoiseParams?
local MultinoiseParams = {}

return MultinoiseParams
