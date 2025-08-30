local MapGen = Mod:new()
local require = MapGen.require

MapGen.Class = require('MapGen')
MapGen.Class:enable()

Api.addModToGlobalSpace(MapGen, 'Core.MapGen')
