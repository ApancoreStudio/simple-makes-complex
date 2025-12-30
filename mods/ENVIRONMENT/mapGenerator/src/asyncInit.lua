-- MAPGEN ENVIROMENT ONLY
-- https://api.luanti.org/core-namespace-reference/#mapgen-environment

-- This environment is isolated from the main environment,
-- so global tables need to be preloaded manually.

-- --- Global APIs load --
-- Class
dofile(core.get_modpath('smc__api__class')..'/init.lua')

-- Ensure
dofile(core.get_modpath('smc__api__ensure')..'/init.lua')

-- Logger
dofile(core.get_modpath('smc__api__logger')..'/init.lua')

-- Math
dofile(core.get_modpath('smc__api__math')..'/init.lua')

-- Require
dofile(core.get_modpath('smc__api__require')..'/init.lua')

-- Mod
dofile(core.get_modpath('smc__api__mod')..'/init.lua')

-- TODO: исправить загрузку строковых библиотек (хотя они пока что не юзаются в мапгене)
-- Они не работают из-за get_current_modname внутри utf8
-- UTF-8
-- dofile(core.get_modpath('smc__api__utf8')..'/init.lua')

-- String
-- dofile(core.get_modpath('smc__api__string')..'/init.lua')

-- Table
dofile(core.get_modpath('smc__api__table')..'/init.lua')

-- TODO: пока что закоментировано, поскольку вызывает ошибку из-за global_step
-- Api loader
-- dofile(core.get_modpath('smc__api__api_loader')..'/init.lua')

---@type  MapGen
local mapGenerator = dofile(core.get_modpath('smc__core__map_generator')..'/src/mapGenerator.lua')

mapGenerator:run()