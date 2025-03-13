-------------------------------------
-- COMMANDS
-------------------------------------

local register_command = function(itemname,description,image)
    minetest.register_craftitem("turtlebots:"..itemname, {
        description = description,
        inventory_image = image,
        wield_image = "wieldhand.png",
        stack_max = 1,
        groups = { bot_commands = 1, not_in_creative_inventory = 1},
        on_place = function(itemstack, placer, pointed_thing)
            return nil
        end,
        on_drop = function(itemstack, dropper, pos)
            return nil
        end,
    })
end

register_command("move_forward","Move bot forward","turtlebots_move_forward.png")
register_command("move_backward","Move bot backward","turtlebots_move_backward.png")
register_command("move_up","Move bot up","turtlebots_move_up.png")
register_command("move_down","Move bot down","turtlebots_move_down.png")
register_command("move_left","Move bot left","turtlebots_move_left.png")
register_command("move_right","Move bot right","turtlebots_move_right.png")
register_command("stand_still","Do Nothing","turtlebots_stand_still.png")

register_command("turn_clockwise","Turn bot 90° clockwise","turtlebots_turn_clockwise.png")
register_command("turn_anticlockwise","Move bot 90° anti-clockwise","turtlebots_turn_anticlockwise.png")
register_command("turn_random","Move bot 90° in a random direction","turtlebots_turn_random.png")


register_command("loadblock_red","Add a red block to your queue", "turtlebots_loadblock_red.png")
register_command("loadblock_orange","Add an orange block to your queue", "turtlebots_loadblock_orange.png")
register_command("loadblock_yellow","Add a green block to your queue", "turtlebots_loadblock_yellow.png")
register_command("loadblock_green","Add a green block to your queue", "turtlebots_loadblock_green.png")
register_command("loadblock_grey","Add a grey block to your queue", "turtlebots_loadblock_grey.png")
register_command("loadblock_white","Add a white block to your queue", "turtlebots_loadblock_white.png")
register_command("loadblock_black","Add a black block to your queue", "turtlebots_loadblock_black.png")
register_command("loadblock_blue","Add a blue block to your queue", "turtlebots_loadblock_blue.png")
register_command("loadblock_cyan","Add a cyan block to your queue", "turtlebots_loadblock_cyan.png")
register_command("loadblock_pink","Add a pink block to your queue", "turtlebots_loadblock_pink.png")
register_command("loadblock_clear","Remove all blocks from your queue", "turtlebots_loadblock_clear.png")


register_command("add_1","plus one more time", "turtlebots_plus_1.png")
register_command("add_2","plus two more times", "turtlebots_plus_2.png")
register_command("add_4","plus four more times", "turtlebots_plus_4.png")
register_command("add_8","plus eight more times", "turtlebots_plus_8.png")
register_command("add_16","plus sixteen more times", "turtlebots_plus_16.png")

register_command("run_1","START PROGRAM A","turtlebots_run_1.png")
register_command("run_2","START PROGRAM B","turtlebots_run_2.png")
register_command("run_3","START PROGRAM C","turtlebots_run_3.png")
register_command("run_4","START PROGRAM D","turtlebots_run_4.png")
register_command("run_5","START PROGRAM E","turtlebots_run_5.png")
register_command("run_6","START PROGRAM F","turtlebots_run_6.png")
register_command("run_7","START PROGRAM G","turtlebots_run_7.png")
register_command("run_8","START PROGRAM H","turtlebots_run_8.png")

register_command("done","Program finished","turtlebots_done.png")

-------------------------------------
-- COLORED BLOCKS
-------------------------------------

local function create_block(color)
    minetest.register_node(TURTLEBOTS.get_block_name(color), {
        description = color.." block",
        tiles = {TURTLEBOTS.get_block_texture(color)},
        groups = {cracky=3,oddly_breakable_by_hand=3, bot_commands = 1, not_in_creative_inventory = 1},
        stack_max = 1,
    })
    minetest.register_node(TURTLEBOTS.get_block_name(color).."_create", {
        description = color.." block",
        tiles = {TURTLEBOTS.get_block_texture(color)},
        groups = {cracky=3,oddly_breakable_by_hand=3},
        stack_max = 64,
    })
end

create_block("red")
create_block("orange")
create_block("yellow")
create_block("green")
create_block("grey")
create_block("white")
create_block("black")
create_block("blue")
create_block("cyan")
create_block("pink")

