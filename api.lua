local S = minetest.get_translator(minetest.get_current_modname())
local F = minetest.formspec_escape
local C = minetest.colorize

--#5e7dde
table.merge(curio, {
    textures = {},
    registered_globalsteps = {},
    registered_globalsteps_slow = {},
    registered_player_globalsteps = {},
    registered_player_globalsteps_slow = {},
    registered_damage_modifiers = {},
    registered_on_leaveplayer = {},
    registered_on_joinplayer = {},
    registered_on_player_receive_fields = {},
    registered_controls_on_press = {},
    registered_controls_on_release = {},
    registered_controls_on_hold = {},
    players = {}
})

function curio.make_registration()
	local t = {}
	local registerfunc = function(func)
		t[#t + 1] = func
		core.callback_origins[func] = {
			-- may be nil or return nil
			-- mod = core.get_current_modname and core.get_current_modname() or "??",
			name = debug.getinfo(1, "n").name or "??"
		}
	end
	return t, registerfunc
end

function curio.make_registration_reverse()
	local t = {}
	local registerfunc = function(func)
		table.insert(t, 1, func)
		core.callback_origins[func] = {
			-- may be nil or return nil
			-- mod = core.get_current_modname and core.get_current_modname() or "??",
			name = debug.getinfo(1, "n").name or "??"
		}
	end
	return t, registerfunc
end

curio.registered_globalsteps, curio.register_globalstep = curio.make_registration()

curio.registered_globalsteps_slow, curio.register_globalstep_slow = curio.make_registration()

curio.registered_player_globalsteps, curio.register_player_globalstep = curio.make_registration()

curio.registered_player_globalsteps_slow, curio.register_player_globalstep_slow = curio.make_registration()

curio.registered_damage_modifiers, curio.register_damage_modifier = curio.make_registration()

curio.registered_on_player_receive_fields, curio.register_on_player_receive_fields = curio.make_registration()

curio.registered_on_joinplayer, curio.register_on_joinplayer = curio.make_registration()

curio.registered_on_leaveplayer, curio.register_on_leaveplayer = curio.make_registration()

local globalstep_slow_timer = 0

minetest.register_globalstep(function(dtime)
    globalstep_slow_timer = globalstep_slow_timer + dtime
    if globalstep_slow_timer >= 5 then
        globalstep_slow_timer = globalstep_slow_timer - 5
        for func_id, func in pairs(curio.registered_globalsteps_slow) do
            func(dtime)
        end
    end
    for func_id, func in pairs(curio.registered_globalsteps) do
        func(dtime)
    end
end)
mcl_player.register_globalstep(function(player, dtime)
    for func_id, func in pairs(curio.registered_player_globalsteps) do
        func(player, dtime)
    end
end)
mcl_player.register_globalstep_slow(function(player, dtime)
    for func_id, func in pairs(curio.registered_player_globalsteps_slow) do
        func(player, dtime)
    end
end)
minetest.register_on_joinplayer(function(player)
    local playername = player:get_player_name()
    curio.players[playername] = curio.players[playername] or {}
    for func_id, func in pairs(curio.registered_on_joinplayer) do
        func(player)
    end
end)
minetest.register_on_leaveplayer(function(player)
    local playername = player:get_player_name()
    curio.players[playername] = nil
    for func_id, func in pairs(curio.registered_on_leaveplayer) do
        func(player)
    end
end)
mcl_damage.register_modifier(function(obj, damage, reason)
    for func_id, func in pairs(curio.registered_damage_modifiers) do
        func(obj, damage, reason)
    end
end, 2048)
minetest.register_on_player_receive_fields(function(player, formname, fields)
    for func_id, func in pairs(curio.registered_on_player_receive_fields) do
        func(player, formname, fields)
    end
end)



local static_objs = {
    "mcl_chests:chest",
    "mcl_itemframes:item",
    "mcl_enchanting:book",
    "curio:effect_entity_sprite",
    "curio:effect_entity_3d",
}
function curio.is_obj_static(obj)
    if not obj then
        return true
    end
    if not obj:is_valid() then
        return true
    end
    if obj:is_player() and obj:get_pos() then
        return false
    end
    local le = obj:get_luaentity()
    if not le then
        return true
    end
    if le.is_mob then
        return false
    end
    for _, name in ipairs(static_objs) do
        if name == le.name then
            return true
        end
    end
    if obj:get_pos() then
        return false
    else
        return true
    end
end


--[[
jump
right
left
LMB
RMB
sneak
aux1
down
up
zoom
dig
place
]]

curio.registered_controls_on_press, curio.register_controls_on_press = curio.make_registration()
curio.registered_controls_on_release, curio.register_controls_on_release = curio.make_registration()
curio.registered_controls_on_hold, curio.register_controls_on_hold = curio.make_registration()
controls.register_on_press(function(player, control_name)
	-- called on initial key-press
	-- control_name: see above
    for k, v in pairs(curio.registered_controls_on_press) do
        curio.registered_controls_on_press(k, player, control_name)
    end
end)
controls.register_on_release(function(player, control_name, time)
	-- called on key-release
	-- control_name: see above
	-- time: seconds the key was pressed
    for k, v in pairs(curio.registered_controls_on_release) do
        curio.registered_controls_on_release(k, player, control_name)
    end
end)
controls.register_on_hold(function(player, control_name, time)
	-- called every globalstep if the key is pressed
	-- control_name: see above
	-- time: seconds the key was pressed
    for k, v in pairs(curio.registered_controls_on_hold) do
        curio.registered_controls_on_hold(k, player, control_name)
    end
end)
