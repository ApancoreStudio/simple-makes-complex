local id = core.get_content_id

---@class MapGen.StaticLayer
---@field name                string
---@field minY                number
---@field maxY                number
---@field staticNode          string
---@field staticNodeID        number
---@field generateStaticNode  generateFunc
local StaticLayer = {}

---Definition table for the `MapGen.StaticLayer`.
---
---**Only for EmmyLua.**
---@class MapGen.StaticLayerDef
---@field minY                number
---@field maxY                number
---@field staticNode          string
---@field generateStaticNode  generateFunc

---@param self          MapGen.StaticLayer
---@param mapGenerator  MapGen
---@param data          number[]
---@param index         number
---@param x             number
---@param y             number
---@param z             number
local defaultGenerateStaticNode = function(self, mapGenerator, data, index, x, y, z)
	data[index] = self.staticNodeID
end

---@param name  string
---@param def   MapGen.StaticLayerDef
---@return      MapGen.StaticLayer
function StaticLayer:new(name, def)
	assert(def.maxY > def.minY, 'maxY there should be more minY')

	if def.generateStaticNode == nil then
		Logger.infoLog('MapGen.StaticLayer: The `%s` static layer does not have a specified `generateStaticNode()` function. The default function is used.', name)
		def.generateStaticNode = defaultGenerateStaticNode
	end

	local staticNodeID = id(def.staticNode)

	---@type MapGen.StaticLayer
	local instance = setmetatable({
		name               = name,
		minY               = def.minY,
		maxY               = def.maxY,
		staticNode         = def.staticNode,
		staticNodeID       = staticNodeID,
		generateStaticNode = def.generateStaticNode
	}, {__index = self})

	return instance
end

return StaticLayer
