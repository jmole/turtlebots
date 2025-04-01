-- Function to display a command particle above the bot
local function vector_multiply(vec, scalar)
    return {
        x = vec.x * scalar,
        y = vec.y * scalar,
        z = vec.z * scalar
    }
end

local function show_command_sprite(pos, command)
    command = string.gsub(command, ":", "_")
    local node = minetest.get_node(pos)
    local dir = minetest.facedir_to_dir(node.param2)
    local right = {x = -dir.z, y = dir.y, z = dir.x}
    local left = {x = dir.z, y = dir.y, z = -dir.x}
    local particle = {
        pos = pos,
        velocity = {x=dir.x/5, y=1, z=dir.z/5},
        drag = 1,
        texture = command..".png",
        vertical = false,
        size = 4,
        expirationtime = 3,
        jitter = {x=0.1, y=0.1, z=0.1},
        glow = 8
    }
    if string.find(command, "loadblock") then
        particle.pos = particle.pos + vector_multiply(right,0.25)
    elseif string.find(command, "run_") then
        particle.size = 8
        particle.pos = particle.pos + vector_multiply(left,1)
    end
    minetest.add_particle(particle)
end

-- Function to push the current state onto the stack
local function push_state(pos,a,b,c)
    local meta = minetest.get_meta(pos)
    local stack = meta:get_string("stack")
    local push = a..","..b..";"
    meta:set_string("stack", push..stack)
    -- print(meta:get_string("stack"))
end

-- Function to pull the last state from the stack
local function pull_state(pos)
    local meta = minetest.get_meta(pos)
    local stack = meta:get_string("stack")
    local top = string.find(stack,";")
    if top then
        local vars = string.split(string.sub(stack,1,top-1), ",")
        meta:set_int("PC",tonumber(vars[1]))
        meta:set_int("PR",tonumber(vars[2]))
        if stack:len() > top then
            meta:set_string("stack",stack:sub(top+1))
        else
            meta:set_string("stack","")
        end
    end
    -- print(meta:get_string("stack"))
end

-- Function to clear the block stack
local function clear_block_stack(pos)
    local meta = minetest.get_meta(pos)
    meta:set_string("block_stack", "")
end

-- Function to add a block to the stack
local function add_block_to_stack(pos, block)
    print("Addblock:"..block)
    local meta = minetest.get_meta(pos)
    local bs = meta:get_string("block_stack")
    meta:set_string("block_stack", bs..block..";")
    -- print(meta:get_string("block_stack"))
end

-- Function to get a block from the stack
local function get_block_from_stack(pos)
    local meta = minetest.get_meta(pos)
    local bs = meta:get_string("block_stack")
    local front = string.find(bs,";")
    if front then
        local block = string.sub(bs,1,front-1)
        if (bs:len() > front) then
            meta:set_string("block_stack",bs:sub(front+1))
        else
            meta:set_string("block_stack","")
        end
        -- print(meta:get_string("block_stack"))
        return block
    end
    -- print(meta:get_string("block_stack"))
    return nil
end

-- Callback function to check if a player can interact with the bot
local function interact(player,pos,isempty)
    local name = player:get_player_name()
    local meta = minetest.get_meta(pos)
    local player_is_owner = ( name == meta:get_string("owner") )
    local has_server_priv = minetest.check_player_privs(player, "server")
    if has_server_priv or player_is_owner then
        return true
    end
    return false
end

-- Function to clean up the bot table and storage
local function clean_bot_table()
    for bot_key,bot_data in pairs( TURTLEBOTS.bot_info) do
        local meta = minetest.get_meta(bot_data.pos)
        local bot_name = meta:get_string("name")
        if bot_name=="" then
            TURTLEBOTS.bot_info[bot_key] = nil
        end
    end
end

-- Function to change the bot's facing direction
local function facebot(facing,pos)
    local node = minetest.get_node(pos)
    minetest.swap_node(pos,{name=node.name, param2=facing})
end

-- Function to turn the bot clockwise
local function bot_turn_clockwise(pos)
    local node = minetest.get_node(pos)
    local newface = (node.param2+1)%4
    facebot(newface,pos)
end

-- Function to turn the bot anticlockwise
local function bot_turn_anticlockwise(pos)
    local node = minetest.get_node(pos)
    local newface = (node.param2-1)%4
    facebot(newface,pos)
end

-- Function to turn the bot in a random direction
local function bot_turn_random(pos)
    if math.random(2)==1 then
        bot_turn_clockwise(pos)
    else
        bot_turn_anticlockwise(pos)
    end
end

-- Function to check if a node is essentially empty (air-like)
local function basically_empty(node)
	local def = minetest.registered_nodes[node.name]
	if node.name == "air" or
			def.drawtype=="airlike" or
			def.groups.not_in_creative_inventory==1 or
			def.buildable_to==true then
		return true
	else
		return false
	end
end

-- Function to move the bot to a new position
local function position_bot(pos,newpos)
    local meta = minetest.get_meta(pos)
    local R = meta:get_int("steptime")
    local bot_owner = meta:get_string("owner")
    if not minetest.is_protected(newpos, bot_owner) then
        local moveto_node = minetest.get_node(newpos)
        if basically_empty(moveto_node) then
            local node = minetest.get_node(pos)
            local hold = meta:to_table()
            minetest.set_node(pos,{name="air"})
            minetest.set_node(newpos,{name=node.name, param2=node.param2})
            minetest.get_node_timer(newpos):start(1/R)
            if hold then
                minetest.get_meta(newpos):from_table(hold)
            end
            minetest.check_for_falling(newpos)
            return true
        else
            minetest.sound_play("ouch",{pos = newpos, gain = 10})
            minetest.check_for_falling(newpos)
            return false
        end
    else
        minetest.sound_play("ouch",{pos = newpos, gain = 10})
        return false
    end
end

-- Function for the bot to build at a specific position
local function bot_build(pos, buildpos)
    local block_type = get_block_from_stack(pos)
    -- print(block_type)

    if (block_type) then
        local block_name = "turtlebots:block_"..block_type
        minetest.set_node(buildpos,{name=block_name})
    end
end

-- Function to move the bot in a specific direction
local function move_bot(pos,direction)
    local meta = minetest.get_meta(pos)
    local bot_owner = meta:get_string("owner")
    local player = minetest.get_player_by_name(bot_owner)
    -- print(bot_owner)
    local ppos
    if player then
        ppos = player:get_pos()
        -- print(dump(pos))
        -- print(dump(ppos))
    end
    local node = minetest.get_node(pos)
    local dir = minetest.facedir_to_dir(node.param2)
    local newpos
    if direction == "u" then -- upwards
        newpos = {x = pos.x, y = pos.y+1, z = pos.z}
    elseif direction == "d" then -- downwards
        newpos = {x = pos.x, y = pos.y-1, z = pos.z}
    elseif direction == "f" then -- forwards
        newpos = {x = pos.x-dir.x, y = pos.y, z = pos.z-dir.z}
    elseif direction == "b" then -- backwards
        newpos = {x = pos.x+dir.x, y = pos.y, z = pos.z+dir.z}
    elseif direction == "l" then -- left
        newpos = {x = pos.x+dir.z, y = pos.y, z = pos.z-dir.x}
    elseif direction == "r" then -- right
        newpos = {x = pos.x-dir.z, y = pos.y, z = pos.z+dir.x}
    end
    if newpos then
        -- Check if the new position is not occupied by another bot
        if (not string.find(minetest.get_node(newpos).name, TURTLEBOTS.turtlebots_on))
           and (not string.find(minetest.get_node(newpos).name, TURTLEBOTS.turtlebots_off)) then
            if not minetest.is_protected(newpos, bot_owner) then
                minetest.set_node(newpos,{name="air"})
                if (position_bot(pos,newpos)) then
                    bot_build(newpos,pos)
                end
                -- Check if the player is close enough to the bot to be moved along with it
                if ppos then
                    if math.abs(ppos.x-pos.x)<1.1 and
                            math.abs(ppos.z-pos.z)<1.1 and
                            math.abs(ppos.y-pos.y)<2 and
                            ppos.y>pos.y then
                        player:set_pos({x=newpos.x, y=newpos.y+0.5, z=newpos.z })
                    end
                end
            end
        else
            minetest.sound_play("ouch",{pos = newpos, gain = 10})
        end
    end

end

-- Function to parse and execute bot commands
local function bot_parsecommand(pos,item)
    local meta = minetest.get_meta(pos)
    if item == "turtlebots:move_forward" then
        move_bot(pos,"f")
    elseif item == "turtlebots:move_backward" then
        move_bot(pos,"b")
    elseif item == "turtlebots:move_up" then
        move_bot(pos,"u")
    elseif item == "turtlebots:move_down" then
        move_bot(pos,"d")
    elseif item == "turtlebots:move_left" then
        move_bot(pos,"l")
    elseif item == "turtlebots:move_right" then
        move_bot(pos,"r")
    elseif item == "turtlebots:move_home" then
        local newpos = minetest.deserialize(meta:get_string("home"))
        if newpos then
            position_bot(pos,newpos)
        end
    elseif item == "turtlebots:turn_clockwise" then
        bot_turn_clockwise(pos)
    elseif item == "turtlebots:turn_anticlockwise" then
        bot_turn_anticlockwise(pos)
    elseif item == "turtlebots:turn_random" then
        bot_turn_random(pos)
    elseif item == "turtlebots:mode_speed" then
        local R = meta:get_int("repeat")
        if R > 1 then
            meta:set_int("repeat",0)
            meta:set_int("steptime",R+1)
        else
            meta:set_int("steptime",1)
        end
    elseif string.find(item, "turtlebots:loadblock_") then
        local item_parts = string.split(item,"_")
        local block_action = item_parts[2]
        if (block_action == "clear") then
            clear_block_stack(pos)
        elseif block_action then
            add_block_to_stack(pos, block_action)
        end
    end

    local item_parts = string.split(item,"_")
    if item_parts[1]=="turtlebots:run" then
        local PC = meta:get_int("PC")
        local PR = meta:get_int("PR")
        local R = meta:get_int("repeat")
        push_state(pos,PC,PR,R)
        meta:set_int("PR", item_parts[2])
        meta:set_int("PC", 0)
        meta:set_int("repeat", 0)
    end
end

-- Function to handle punching the bot
local function punch_bot(pos,player)
    local meta = minetest.get_meta(pos)
    local bot_owner = meta:get_string("owner")
    if bot_owner == player:get_player_name() then
        local item = player:get_wielded_item():get_name()
        if item == "" then
            TURTLEBOTS.bot_togglestate(pos)
        end
    end
end

-- Function to handle the bot's timer events
local function bot_handletimer(pos)
    local meta = minetest.get_meta(pos)
    local PC = meta:get_int("PC")
    local PR = meta:get_int("PR")
    local stack = meta:get_string("stack")
    local programs = meta:get_string("programs")
    programs = minetest.deserialize(programs)
    if not programs then
        return false
    end
    local command = programs[PR][PC] or "return"
    meta:set_int("PC",PC+1)
    meta:set_int("PR",PR)
    meta:set_string("stack",stack)
    if command ~= "return" then
        bot_parsecommand(pos, command)
        show_command_sprite(pos,command)
        return true
    else
        if PR ~=0 then
            pull_state(pos)
            return true
        else
            TURTLEBOTS.bot_togglestate(pos)
            return false
        end
    end
end

-- Function to register a bot node
local function register_bot(node_name,node_desc,node_tiles,node_groups)
    minetest.register_node(node_name, {
        drawtype = "mesh",
        mesh = "turtle.obj",
        description = node_desc,
        use_texture_alpha = "clip",
        tiles = {"turtle_texture.png"},
        stack_max = 1,
        is_ground_content = false,
        paramtype2 = "facedir",
        legacy_facedir_simple = true,
        groups = node_groups,
        light_source = 14,
        diggable = true,  -- Prevent default digging behavior
        on_blast = function() end,
        after_place_node = function(pos, placer, itemstack, pointed_thing)
            TURTLEBOTS.bot_init(pos, placer)
            local facing = minetest.dir_to_facedir(placer:get_look_dir())
            facing = (facing+2)%4
            facebot(facing,pos)
        end,
        on_punch = function(pos, node, player, pointed_thing)
            punch_bot(pos,player)
        end,
        on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
            local name = clicker:get_player_name()
            if name == "" then
                return 0
            end
            if interact(clicker,pos) then
                TURTLEBOTS.bot_restore(pos)
                minetest.after(0, TURTLEBOTS.show_formspec, clicker, pos)
            end
        end,
        on_timer = function(pos, elapsed)
            return bot_handletimer(pos)
        end,
        can_dig = function(pos, player)
            -- Only allow digging (destroying turtlebot) if:
            -- 1. The player is wielding something (not empty hand)
            -- 2. The player has permission to interact
            local wielded = player:get_wielded_item()
            local wielded_name = wielded:get_name()
            local i = interact(player, pos)
            if wielded_name ~= "" and i then
                return true
            end
            return false
        end,
        on_destruct = function(pos)
            local meta = minetest.get_meta(pos)
            local bot_key = meta:get_string("key")
            TURTLEBOTS.bot_info[bot_key] = nil
            clean_bot_table()
        end
    })
end

-- Register inactive bot node
register_bot(TURTLEBOTS.turtlebots_off, "Turtle Bot", {
            "turtlebots_turtle_top.png",
            "turtlebots_turtle_bottom.png",
            "turtlebots_turtle_right.png",
            "turtlebots_turtle_left.png",
            "turtlebots_turtle_tail.png",
            "turtlebots_turtle_face.png",
            },
            {cracky = 1,
             snappy = 1,
             crumbly = 1,
             oddly_breakable_by_hand = 1,
             }
)

-- Register active bot node
register_bot(TURTLEBOTS.turtlebots_on, "Activated Turtle Bot", {
            "turtlebots_turtle_top4.png",
            "turtlebots_turtle_bottom.png",
            "turtlebots_turtle_right.png",
            "turtlebots_turtle_left.png",
            "turtlebots_turtle_tail.png",
            "turtlebots_turtle_face.png",
            },
            {cracky = 1,
             snappy = 1,
             crumbly = 1,
             oddly_breakable_by_hand = 1,
             not_in_creative_inventory = 1,
             }
)