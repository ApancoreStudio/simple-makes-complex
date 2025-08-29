Api = {}
Core = {}
Environment = {}
Game = {}
Game.Items = {}
Game.Mobs = {}
Game.Structures = {}
Ui = {}

local allowedDomains = {
	Api = true,
	Core = true,
	Environment = true,
	Game = true,
	Ui = true
}

--- Adds a mod to the global space under specified domain structure
---@param mod       table     The mod table containing functionality to expose -- TODO: !!!Describe a Mod class to EmmyLua!!!
---@param location  string    Dot-separated path within domain structure (e.g. "Items.Log")
---@param force     boolean?  Whether to overwrite the target location.
Api.addModToGlobalSpace = function(mod, location, force)
	-- Ensure `mod` type and that it's not empty
	Ensure.argType(mod, 'table', 1, 'Api.addModToGlobalSpace')

	-- Ensure `location` type and that it's not empty
	Ensure.argType(location, 'string', 2, 'Api.addModToGlobalSpace')
	Ensure.stringArgNotEmpty(location, 2, 'Api.addModToGlobalSpace')

	-- Ensure `location` matches this format: 'field.subfield.subsubfield.<...>'
	if not location:match('^[%a_][%w_]*([%.][%a_][%w_]*)*$') then
		error('bad argument #2 to \'Api.addModToGlobalSpace\' (invalid format)')
	end

	-- Split `location` into fields -- TODO: !!!Make a String function!!!
	local fields = {}
	local domain = nil
	for field in string.gmatch(location, '[^.]+') do
		if domain ~= nil then
			table.insert(fields, field)
		else
			domain = field
		end
	end

	-- Ensure the domain is allowed
	Ensure.argIsAllowed(domain, allowedDomains , 2, 'Api.addModToGlobalSpace')

	-- Handle case where we're modifying the domain root directly
	if #fields == 0 then
		error('Not allowed to directly write into the \''.. domain ..'\' domain')
	end

	-- Start traversing from the domain's table
	local current = _G[domain]
	assert(type(current) == 'table', 'The global domain is not a table')

	-- Traverse each field of the location
	local num_fields = #fields
	for i = 1, num_fields - 1 do
		local field = fields[i]
		if current[field] == nil then
			current[field] = {}
		end
		current = current[field]
		assert(type(current) == 'table', 'intermediate field is not a table')
	end

	-- Assign mod to the final field
	local last_field = fields[num_fields]
	if force and current[last_field] ~= nil then
        error(string.format('field \'%s\' already exists in \'%s\'', last_field, location))
    end
	current[last_field] = mod
end
