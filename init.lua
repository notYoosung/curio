local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)


local curio = {
    modname = modname,
    modpath = modpath,
}
rawgset("curio", curio)


local files = {
    "api",
}

for _, filename in ipairs(files) do
    dofile(modpath .. "/" .. filename .. ".lua")
end


