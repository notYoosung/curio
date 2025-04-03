curio.inv = {
    has_in = function(itemstack, player, itemname, listname)
        if not player or not itemstack then return nil end

        local meta = itemstack:get_meta()
        local invmetastring = meta:get_string("curio_inv_content")
        if invmetastring ~= "" then
            local invtable = assert(minetest.deserialize(invmetastring))
            local t = invtable[listname]
            if not t then return nil end
            for i, v in pairs(t) do
                if v.name == itemname then return true end
            end
        end
        return false
    end,
    get_in = function(itemstack, player, listname)
        if not player or not itemstack then return nil end
        local meta = itemstack:get_meta()
        local invmetastring = meta:get_string("curio_inv_content")
        if invmetastring ~= "" then
            local invtable = assert(minetest.deserialize(invmetastring))
            local t = invtable[listname]
            if not t then return {} end
            return t
        else
            return {}
        end
    end,
    get_in_reversed_key_value = function(itemstack, player, listname)
        if not player or not itemstack then return nil end
        local meta = itemstack:get_meta()
        local invmetastring = meta:get_string("curio_inv_content")
        if invmetastring ~= "" then
            local invtable = minetest.deserialize(invmetastring)
            if not invtable then return {} end
            local t = invtable[listname]
            if not t then return {} end
            local t2 = {}
            for _, v in ipairs(t) do
                t2[v.name] = true
            end
            return t2
        else
            return {}
        end
    end,
    create_bag_inv = function(itemstack, player, width, height, invname, allow_bag_input, playername, meta, inv)
        --[[meta:set_int("curio_width_" .. listname, width)
        meta:set_int("curio_height_" .. listname, height)]]
        local invmetastring = meta:get_string("curio_inv_content")
        if invmetastring ~= "" then
            curio.inv.table_to_inv(inv, minetest.deserialize(invmetastring))

            itemstack, inv, player = curio.on_open_bag(itemstack, inv, player)
            curio.inv.save_bag_inv_itemstack(inv, itemstack)
        end
        return itemstack, inv, player
    end,
    save_bag_inv_itemstack = function(inv, stack, listname)
        stack, inv = curio.on_change_bag_inv(stack, inv)
        local meta = stack:get_meta()
        local ser = minetest.serialize(curio.inv.inv_to_table(inv))
        meta:set_string("curio_inv_content", ser)
        return stack
    end,
    save_bag_inv = function(inv, player, _)
        local playerinv = player:get_inventory()
        local bag_id = inv:get_location().name
        local playerlistname = "main"
        local size = playerinv:get_size(playerlistname)
        for i = 1, size, 1 do
            local stack = playerinv:get_stack(playerlistname, i)
            local meta = stack:get_meta()
            local stack_id = meta:get_string("curio_bag_identity")
            if stack_id == bag_id then
                stack = curio.inv.save_bag_inv_itemstack(inv, stack)
                playerinv:set_stack(playerlistname, i, stack)
            end
        end
        return inv
    end,
    inv_to_table = function(inv)
        local t = {}
        for _listname, list in pairs(inv:get_lists()) do
            local size = inv:get_size(_listname)
            if size then
                t[_listname] = {}
                for i = 1, size, 1 do
                    t[_listname][i] = inv:get_stack(_listname, i):to_table()
                end
            end
        end
        return t
    end,
    table_to_inv = function(inv, t)
        for _listname, list in pairs(t) do
            for i, stack in pairs(list) do
                inv:set_stack(_listname, i, stack)
            end
        end
    end,
}

local function get_formspec(name, width_main, height_main, width_cores, height_cores)
    --[[4.125]]
    local magic_inventory_x = 11.75 / 2 - width_main / 2
    local spellbook_inv_formspec = table.concat({
        "formspec_version[4]",
        "size[11.75,10.425]",

        width_cores and ("label[0.375,0.375;" .. F(C(mcl_formspec.label_color, S("Cores"))) .. "]") or "",

        width_cores and (mcl_formspec.get_itemslot_bg_v4(0.375, 0.75, width_cores, height_cores)) or "",
        width_cores and ("list[detached:" .. name .. ";cores;0.375,0.75;" .. width_cores .. "," .. height_cores .. ";]") or "",

        "label[" .. magic_inventory_x .. ",0.375;" .. F(C(mcl_formspec.label_color, S("Magic Inventory"))) .. "]",
        mcl_formspec.get_itemslot_bg_v4(magic_inventory_x, 0.75, width_main, height_main),
        "list[detached:" .. name .. ";main;" .. magic_inventory_x .. ",0.75;" .. width_main .. "," .. height_main .. ";]",
        "label[0.375,4.7;" .. F(C(mcl_formspec.label_color, S("Inventory"))) .. "]",

        mcl_formspec.get_itemslot_bg_v4(0.375, 5.1, 9, 3),
        "list[current_player;main;0.375,5.1;9,3;9]",

        mcl_formspec.get_itemslot_bg_v4(0.375, 9.05, 9, 1),
        "list[current_player;main;0.375,9.05;9,1;]",

        "listring[current_player;main]",
        "listring[detached:" .. name .. ";main]",
        "listring[current_player;main]",
        "listring[detached:" .. name .. ";cores]",
    })
    return spellbook_inv_formspec
end



local function curio_ccmd_func(player_name, params)
    core.show_formspec(player_name, "curio:main_fs", get_formspec(player_name))
end

core.register_chatcommand("c", {
    params = "",
    description = "",
    func = curio_ccmd_func,
})

core.register_chatcommand("curio", {
    params = "",
    description = "",
    func = curio_ccmd_func,
})



