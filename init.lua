-- vbots v1.0
-- (c) 2024 Jon Moeller
--
-- forked from:
-- Visual Bots v0.3
-- (c)2019 Nigel Garnett.
--
-- see licence.txt
--$


VBOTS={}
VBOTS.prefix = "vbots"
VBOTS.modpath = minetest.get_modpath("vbots")
VBOTS.bot_info = {}
dofile(VBOTS.modpath.."/stack.lua")
VBOTS.PROGRAM_SIZE = 12

VBOTS.vbots_on = "vbots:on"
VBOTS.vbots_off = "vbots:off"

VBOTS.debug = true

local debug = function(object)
    if VBOTS.debug == true and object ~= nil then
        print(tostring(object))
        minetest.chat_send_all(tostring(object))
    end
end


minetest.create_detached_inventory("bot_commands", {
    allow_move = function(inv, from_list, from_index, to_list, to_index, count, player2)
        return 0
    end,
    allow_put = function(inv, w, index, stack, player2)
        return 0
    end,
    allow_take = function(inv, listname, index, stack, player2)
        local name = player2 and player2:get_player_name() or ""
        if not minetest.is_creative_enabled(name) then
            return 0
        end
        return -1
    end,
    on_move = function(inv, from_list, from_index, to_list, to_index, count, player2)
    end,
    on_take = function(inv, listname, index, stack, player2)
        if stack and stack:get_count() > 0 then
            minetest.log("action", player_name .. " takes " .. stack:get_name().. " from creative inventory")
        end
    end,
}, player_name)

local trashInv = minetest.create_detached_inventory(
                    "bot_trash",
                    {
                       on_put = function(inv, toList, toIndex, stack, player)
                          inv:set_stack(toList, toIndex, ItemStack(nil))
                       end
                    })
trashInv:set_size("main", 1)
local mod_storage = minetest.get_mod_storage()

local function bot_namer()
    local first = {
        "Robo", "Cyber", "Mecha", "Gizmo", "Bionic", "Nano", "Astro", "Zippy", "Electro", "Super",
        "Turbo", "Giga", "Hyper", "Atomic", "Laser", "Jet", "Rocket", "Metal", "Power", "Circuit"
    }
    local last = {
        "Buddy", "Pal", "Friend", "Eater", "Pooper", "Zoomer", "Meower", "Chomper", "Bot", "Breaker"
    }
    return first[math.random(#first)] .. " " .. last[math.random(#last)]
end


-------------------------------------
-- Generate 32 bit key for formspec identification
-------------------------------------
function VBOTS.get_key()
    math.randomseed(minetest.get_us_time())
    return tostring( math.random(256*256*256*256) )
end

-------------------------------------
-- callback from bot node on_rightclick
-------------------------------------
VBOTS.bot_restore = function(pos)
    local meta = minetest.get_meta(pos)
    local bot_key = meta:get_string("key")
    local bot_owner = meta:get_string("owner")
    local bot_name = meta:get_string("name")
    if not VBOTS.bot_info[bot_key] then
        VBOTS.bot_info[bot_key] = { owner = bot_owner, pos = pos, name = bot_name}
        meta:set_string("infotext", bot_name .. " (" .. bot_owner .. ")")
    end
end


-------------------------------------
-- callback from bot node after_place_node
-------------------------------------
VBOTS.bot_init = function(pos, placer)
    local bot_owner = placer:get_player_name()
    local bot_name = bot_namer()
    local bot_key = VBOTS.get_key()
    VBOTS.bot_info[bot_key] = { owner = bot_owner, pos = pos, name = bot_name}
    local meta = minetest.get_meta(pos)
	meta:set_string("infotext", bot_name .. " (" .. bot_owner .. ")")
    local inv = meta:get_inventory()
    inv:set_size("p0", VBOTS.PROGRAM_SIZE)
    inv:set_size("p1", VBOTS.PROGRAM_SIZE)
    inv:set_size("p2", VBOTS.PROGRAM_SIZE)
    inv:set_size("p3", VBOTS.PROGRAM_SIZE)
    inv:set_size("p4", VBOTS.PROGRAM_SIZE)
    inv:set_size("p5", VBOTS.PROGRAM_SIZE)
    inv:set_size("p6", VBOTS.PROGRAM_SIZE)
    inv:set_size("p7", VBOTS.PROGRAM_SIZE)
    inv:set_size("p8", VBOTS.PROGRAM_SIZE)
    inv:set_size("main", 32)
    inv:set_size("trash", 1)

    meta:set_int("program",0)
    meta:mark_as_private("program")
    meta:set_string("home",minetest.serialize(pos))
    meta:mark_as_private("home")
    meta:set_int("panel",0)
    meta:mark_as_private("panel")
    meta:set_int("steptime",1)
    meta:mark_as_private("steptime")
    meta:set_string("key", bot_key)
    meta:mark_as_private("key")
	meta:set_string("owner", bot_owner)
    meta:mark_as_private("owner")
	meta:set_string("name", bot_name)
    meta:mark_as_private("name")
	meta:set_int("PC", 0)
    meta:mark_as_private("PC")
	meta:set_int("PR", 0)
    meta:mark_as_private("PR")
	meta:set_string("stack","")
    meta:mark_as_private("stack")
end

VBOTS.wipe_programs = function(pos)
    local meta = minetest.get_meta(pos)
    local meta_table = meta:to_table()
    local inv = meta:get_inventory()
    local inv_list = {}
    for i,t in pairs(meta_table.inventory) do
        if i ~= "main" then
            size = inv:get_size(i)
            for a=1,size do
                inv:set_stack(i,a, "")
            end
        end
    end
end

VBOTS.save = function(pos)
    VBOTS.bot_restore(pos)
    local meta = minetest.get_meta(pos)
    local meta_table = meta:to_table()
    local botname = meta:get_string("name")
    local name = meta:get_string("owner")
    local inv_list = {}
    for i,t in pairs(meta_table.inventory) do
        if i ~= "main" then
            for _,s in pairs(t) do
                --local itemname = s:get_name()
                --if s and s:get_count()>0 and itemname:sub(1,5)=="vbots" then
				inv_list[#inv_list+1] = i.." "..s:get_name().." "..s:get_count()
                --end
            end
        end
    end
    mod_storage:set_string(name..",vbotsep,"..botname,minetest.serialize(inv_list))
end

VBOTS.load = function(pos,player,mode)
    VBOTS.bot_restore(pos)
    local meta = minetest.get_meta(pos)
    local key = meta:get_string("key")
    local data = mod_storage:to_table().fields
    local bot_list = ""
    local parts
    for n,d in pairs(data) do
        parts = string.split(n,",vbotsep,")
        if #parts == 2 and parts[1] == player:get_player_name() then
            bot_list = bot_list..parts[2]..","
        end
    end
    bot_list = bot_list:sub(1,#bot_list-1)
    local formspec
    local formname
    if not mode then
        formspec = "size[5,9]"..
                 "image_button_exit[4,8;1,1;vbots_gui_check.png;ok;]"..
                 "image_button_exit[4,0;1,1;vbots_gui_delete.png;delete;]"..
                 "tooltip[4,0;1,1;delete]"..
                 "image_button_exit[4,1;1,1;vbots_gui_rename.png;rename;]"..
                 "tooltip[4,1;1,1;rename]"..
                 "textlist[0,0;4,9;saved;"..bot_list.."]"
        formname = "loadbot,"..key
    elseif mode == "delete" then
        formspec = "size[5,9]no_prepend[]"..
                 "image_button_exit[4,8;1,1;vbots_gui_check.png;ok;]"..
                 "bgcolor[#F00]"..
                 "textlist[0,0;4,9;saved;"..bot_list.."]"
        formname = "delete,"..key
    elseif mode == "rename" then
        formspec = "size[5,9]no_prepend[]"..
                 "image_button_exit[4,8;1,1;vbots_gui_check.png;ok;]"..
                 "bgcolor[#0F0]"..
                 "textlist[0,0;4,9;saved;"..bot_list.."]"
        formname = "rename,"..key
    elseif mode:sub(1,10) == "renamefrom" then
        local fromname = mode:sub(12)
        formspec = "size[6,6]no_prepend[]"..
                 "image_button_exit[5,5;1,1;vbots_gui_check.png;ok;]"..
                 "bgcolor[#00F]"..
                 "field[0,0;5,2;oldname;Old Name;"..fromname.."]"..
                 "field[0,1;5,4;newname;New Name;]"
        formname = "renamefrom,"..key
    end
    minetest.after(0.2, minetest.show_formspec, player:get_player_name(), formname, formspec)
end


VBOTS.get_block_name = function(color)
    return "vbots:block_"..color
end

VBOTS.get_block_texture = function(color)
    return "vbots_block_"..color..".png"
end

-------------------------------------
-- Serialize the program from the node metadata
-------------------------------------
VBOTS.serialize_program = function(node_metadata)
    local inventory = node_metadata:get_inventory()
    local programs = {}
    for i=0,8 do
        local inventory_name = "p"..i
        programs[i] = {}
        local stack_in = Stack:new()
        local stack_out = Stack:new()
        for j=1,VBOTS.PROGRAM_SIZE do
            local code = inventory:get_stack(inventory_name, j):get_name()
            if code then
                stack_in:push(code)
            end
        end

        local do_it_again = 1
        for code in stack_in:iterator() do
            local number = code:match("vbots:add_(%d+)")
            if number then
                do_it_again = do_it_again + tonumber(number)
            elseif code ~= "" then
                for j=1,do_it_again do
                    stack_out:push(code)
                end
                do_it_again = 1
            end
        end

        local j = 0
        for code in stack_out:iterator() do
            debug(tostring(i)..":"..tostring(j)..":"..code)
            programs[i][j] = code
            j = j + 1
        end
    end
    debug(programs)
    return programs
end


VBOTS.bot_togglestate = function(pos,mode)
    local meta = minetest.get_meta(pos)
    local node = minetest.get_node(pos)
    local timer = minetest.get_node_timer(pos)
    local newname
    if not mode then
        if node.name == VBOTS.vbots_off then
            mode = "on"
        elseif node.name == VBOTS.vbots_on then
            mode = "off"
        end
    end
    if mode == "on" then
        newname = VBOTS.vbots_on
        meta:set_int("steptime", 10)
        timer:start(1/meta:get_int("steptime"))
        meta:set_int("PC",0)
        meta:set_int("PR",0)
        meta:set_string("stack","")
        meta:set_string("home",minetest.serialize(pos))
        local programs = minetest.serialize(VBOTS.serialize_program(meta))
        debug("Serialized: ")
        debug( programs)
        meta:set_string("programs", programs)
    elseif mode == "off" then
        newname = VBOTS.vbots_off
        timer:stop()
        meta:set_int("PC",0)
        meta:set_int("PR",0)
        meta:set_string("stack","")
    end
    debug(node.name.." "..newname)
    if newname then
        minetest.swap_node(pos,{name=newname, param2=node.param2})
    end
end


dofile(VBOTS.modpath.."/formspec.lua")
dofile(VBOTS.modpath.."/formspec_handler.lua")
dofile(VBOTS.modpath.."/register_bot.lua")
dofile(VBOTS.modpath.."/register_commands.lua")
dofile(VBOTS.modpath.."/register_joinleave.lua")

-- override all items to have range = 10
for name, def in pairs(minetest.registered_items) do
    minetest.override_item(name, {
        range = 10,
    });
end