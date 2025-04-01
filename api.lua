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
    players = {}
})


function curio.register_globalstep(id, func)
    curio.registered_globalsteps[id] = func
end

function curio.register_globalstep_slow(id, func)
    curio.registered_globalsteps_slow[id] = func
end

function curio.register_player_globalstep(id, func)
    curio.registered_player_globalsteps[id] = func
end

function curio.register_player_globalstep_slow(id, func)
    curio.registered_player_globalsteps_slow[id] = func
end

function curio.register_damage_modifier(id, func)
    curio.registered_damage_modifiers[id] = func
end

function curio.register_on_player_receive_fields(id, func)
    curio.registered_on_player_receive_fields[id] = func
end

function curio.register_on_joinplayer(id, func)
    curio.registered_on_joinplayer[id] = func
end

function curio.register_on_leaveplayer(id, func)
    curio.registered_on_leaveplayer[id] = func
end

if not mcl_util._magikacia_main_init then
    mcl_util._magikacia_main_init = true
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
end
