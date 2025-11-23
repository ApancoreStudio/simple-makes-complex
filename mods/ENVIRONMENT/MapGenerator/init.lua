-- World generation runs in the mapgen environment (separate thread)
-- The Mapgen environment is isolated from the main enviroment.

core.register_mapgen_script(core.get_modpath(core.get_current_modname())..'/MapGenerator.lua')