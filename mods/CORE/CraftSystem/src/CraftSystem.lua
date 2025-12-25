local HASH_SPLITTER = '&'

local modInfo = Mod.getInfo('smc__core__craft_system')
local require = modInfo.require

---@alias CraftSystem.shapelessCraftsList   table<CraftSystem.Craft.Group, table<string, CraftSystem.ShapelessCraft[]>>
---@alias CraftSystem.processualCraftsList  table<CraftSystem.Craft.Group, table<string, CraftSystem.ProcessualCraft[]>>

---@class CraftSystem
---@field shapelessCraftsList   CraftSystem.shapelessCraftsList
---@field processualCraftsList  CraftSystem.processualCraftsList
local CraftSystem = {
	shapelessCraftsList = {},
	processualCraftsList = {},
}

---@alias CraftSystem.Craft.Type
---|'shapeless'
---|'processual'
---@alias CraftSystem.Craft.Group   string
---@alias CraftSystem.Craft.Recipe  string[]

---@alias shapelessCraftFunc   fun(self:CraftSystem.ShapelessCraft,  input:ItemStack[], workbenchMeta:NodeMetaRef?):boolean
---@alias processualCraftFunc  fun(self:CraftSystem.ProcessualCraft, input:ItemStack[], workbenchMeta:NodeMetaRef?, processTime:number):boolean

---@class CraftSystem.BaseCraft
---@field type        CraftSystem.Craft.Type
---@field group       CraftSystem.Craft.Group
---@field output      string
---@field recipe      CraftSystem.Craft.Recipe
---@field return      table? TODO: доделать тут тип
---@field craftFunc  (fun(self, ...):boolean)?

---@class CraftSystem.ShapelessCraft : CraftSystem.BaseCraft
---@field craftFunc  shapelessCraftFunc?

---@class CraftSystem.ProcessualCraft : CraftSystem.BaseCraft
---@field processTime  number
---@field craftFunc    processualCraftFunc?

---@param type  CraftSystem.Craft.Type
---@return      CraftSystem.shapelessCraftsList|CraftSystem.processualCraftsList
local function getCraftList(type)
	local craftList

	if     type == 'shapeless' then
		craftList = CraftSystem.shapelessCraftsList
	elseif type == 'processual' then
		craftList = CraftSystem.processualCraftsList
	else
		error(string.format('Craft type `%s` does not exist.', type))
	end

	return craftList
end

---@param type   CraftSystem.Craft.Type
---@param group  CraftSystem.Craft.Group
---@return       table<string, table>
local function getCraftGroup(type, group)
	local craftList = getCraftList(type)

	---@type  table<string, table>?
	local craftGroup = craftList[group]

	assert(craftGroup ~= nil, string.format('Craft group `%s` does not exist.', type))

	return craftGroup
end

---@param type   CraftSystem.Craft.Type
---@param group  CraftSystem.Craft.Group
function CraftSystem.registerCraftGroup(type, group)
	local craftList = getCraftList(type)

	assert(craftList[group] == nil, string.format('Craft group `%s` is already registered.', type))

	craftList[group] = {}
end

---@param recipe  CraftSystem.Craft.Recipe
---@return        string
function CraftSystem.getCraftHash(recipe)
	table.sort(recipe)

	local hash = ''

	for i = 0, #recipe-1 do
		hash = hash..recipe[i]..HASH_SPLITTER
	end

	return hash..recipe[#recipe]
end

---@param craftDef  CraftSystem.ShapelessCraft|CraftSystem.ProcessualCraft
function CraftSystem.registerCraft(craftDef)
	local craftGroup = getCraftGroup(craftDef.type, craftDef.group)

	local hash = CraftSystem.getCraftHash(craftDef.recipe)

	table.insert(craftGroup[hash], craftDef)
end

---@param type   CraftSystem.Craft.Type
---@param group  CraftSystem.Craft.Group
---@return       CraftSystem.ShapelessCraft[]        |
---              CraftSystem.processualCraftsList[]  |
---              nil
function CraftSystem.getCraftResults(type, group, recipe)
	local craftGroup = getCraftGroup(type, group)

	local hash = CraftSystem.getCraftHash(recipe)

	return craftGroup[hash]
end

return CraftSystem