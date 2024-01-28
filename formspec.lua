-------------------------------------
-- Formspec colored boxes
-------------------------------------
local function highlight(item, line, w, h, r, g, b)
    local padding = 0
    local item = item - padding
    local line = line - padding
    w = w + padding * 2
    h = h + padding * 2
    return "box[" .. item .. "," .. line .. ";" .. w .. "," .. h .. ";#" ..
        r .. r .. g .. g .. b .. b .. "90]"
end

local function maketext(x, y, text, tag)
    return "hypertext[" .. x .. "," .. y .. ";10,10;a;" .. string.format("<%s>%s</%s>", tag, text, tag) .. "]"
end

local function padded_list_of_size(inventory, list, x, y, w, h, numx, numy, padding)
    x = x + padding
    y = y + padding
    local spacing = padding * 2
    w = w - spacing
    h = h - spacing
    local list_string =
        string.format("style_type[list;size=%s,%s;spacing=%s]", w, h, spacing) ..
        string.format("list[%s;%s;%s,%s;%s,%s]", inventory, list, x, y, numx, numy)
    print(list_string)
    return list_string
end

local function padded_list(inventory, list, x, y, numx, numy)
    return padded_list_of_size(inventory, list, x, y, 1, 1, numx, numy, 0.1)
end


-------------------------------------
-- Formspec button generators
-------------------------------------

local function _image_button(x, y, w, h, image, name, exit)
    local padding = 0.1
    x = x + padding
    y = y + padding
    w = w - padding * 2
    h = h - padding * 2
    return "image_button"..exit.."[" .. x .. "," .. y .. ";" .. w .. "," .. h .. ";" .. image .. ";" .. name .. ";]" ..
        "tooltip[" .. x .. "," .. y .. ";" .. w .. "," .. h .. ";" .. name .. "]"
end

local function item_image_button_padding(x,y,w,h,padding,name)
    x = x + padding
    y = y + padding
    w = w - padding * 2
    h = h - padding * 2
    return string.format("item_image_button[%s,%s;%s,%s;%s;%s;%s]", x, y, w, h, "vbots:"..name, name, "")
end

local function item_image_button(x,y,w,h,name)
    return item_image_button_padding(x,y,w,h,0,name)
end
local function image_button(x, y, w, h, image, name)
    return _image_button(x, y, w, h, image, name, "")
end
local function image_button_exit(x, y, w, h, image, name)
    return _image_button(x, y, w, h, image, name, "_exit")
end
local function button(x, y, image, name, exit)
    if not exit then
        return image_button(x, y, 1, 1, image, name)
    else
        return image_button_exit(x, y, 1, 1, image, name)
    end
end

local blank_space = "__blank"
local function cbutton(x, y, padding, name)
    if name == blank_space then
        return ""
    end
    --return image_button(x, y, 1, 1, "vbots_" .. name .. ".png", name)
    return item_image_button_padding(x, y, 1, 1, padding, name)
end


local function button_row_space(x, y, padding, nametable )
    local row = ""
    for i, name in pairs(nametable) do
        row = row .. cbutton(x + i - 1, y, padding, name)
    end
    return row
end

local function button_row(x, y, nametable)
    return button_row_space(x,y,0,nametable)
end

-------------------------------------
-- Main panel generators
-------------------------------------
local function panel_commands()
    local commands = {
        { "__blank", "move_forward", "__blank"},--,blank_space,blank_space, "move_up" },
        { "move_left",   "stand_still",      "move_right"},--, blank_space,"turn_anticlockwise", "stand_still","turn_clockwise" },
        { "__blank",    "move_backward",  "__blank" },--,blank_space, blank_space, "move_down", },
        --{"case_repeat","case_test","case_end","case_success","case_failure","case_yes","case_no" },
        --{"mode_examine","mode_pause","mode_wait"},
        -- { "number_2",       "number_3",           "number_4",       "number_5",  blank_space, "mode_speed" },
        -- { "number_6",       "number_7",           "number_8",       "number_9" },
        {""},
        {blank_space, "move_up" },
        {"turn_anticlockwise", "stand_still","turn_clockwise" },
        {blank_space, "move_down", },
        { "run_1",          "run_2",              "run_3",          "run_4",     "run_5",     "run_6" }
    }
    local panel = highlight(0, 1.5, 7, 8, "f", "f", "f")
    ..highlight(0, 5, 7, 4.5, "0", "0", "0")
    ..highlight(0, 5, 7, 4.5, "0", "0", "0")
    .. "container[0.25,0.25]"

    panel = panel
    ..button_row(0,1.5, { "__blank", "move_forward", "__blank"})
    ..button_row(0,2.5, { "move_left", "stand_still", "move_right"})
    ..button_row(0,3.5, { "__blank", "move_backward", "__blank"})
    ..button_row(3.5,1.5, {blank_space, "move_up" })
    ..button_row(3.5,2.5, {"turn_anticlockwise", "stand_still","turn_clockwise" })
    ..button_row(3.5,3.5, {blank_space, "move_down", })
    ..button_row_space(0.225,5,0,{"block_red", "block_orange", "block_yellow", "block_green", "block_grey", "block_clear"})
    ..button_row_space(0.225,6,0,{"block_cyan", "block_blue", "block_pink", "block_white", "block_black","add_1"})
    ..button_row_space(0.225,7,0,{"run_1", "run_2", "run_3", blank_space, "add_2", "add_4"})
    ..button_row_space(0.225,8,0,{"run_4", "run_5", "run_6", blank_space, "add_8", "add_16"})

    -- for row, namelist in pairs(commands) do
    --     panel = panel .. button_row(0, row + 0.5, namelist)
    -- end
    panel = panel .. "container_end[]"
    return panel
end

local function panel_main(pos, mode)
    local panel
    if mode == 0 then
        panel = panel_commands()
    else
        panel = "list[current_player;main;0,5;8,4;]" ..
            "list[nodemeta:" .. pos .. ";main;0,1;8,4;]" ..
            "listring[current_player;main]" ..
            "listring[nodemeta:" .. pos .. ";main]" ..
            highlight(0, 1, 8, 4, "a", "a", "f")
    end
    return panel
        .. highlight(0.5 + mode, 0, 1, 1, "a", "a", "f")
        .. button(0.5, 0, "vbots_gui_commands.png", "commands")
        .. button(1.5, 0, "vbots_location_inventory.png", "player_inv")
end

local function draw_subroutines(pos, program)
    local subroutines = ""
    subroutines = subroutines .. "container[1,0]"

    -- highlight coding area in grey
    subroutines = subroutines .. highlight(7, 1.5, 9, 7, "9", "9", "9")
    -- highlight selected program in pink
    subroutines = subroutines .. highlight(7, 1.5 + program, 9, 1, "f", "a", "f")


    for i = 0, 6 do
        -- program list
        subroutines = subroutines
            .. padded_list("nodemeta:" .. pos, "p" .. i, 8, i + 1.5, VBOTS.PROGRAM_SIZE, 1)

        -- selector button for subroutine
        subroutines = subroutines
            .. button(7, 1.5 + i, "vbots_program_" .. i .. ".png", "sub_" .. i)
    end
    subroutines = subroutines .. "container_end[]"
    return subroutines
end

-------------------------------------
-- Main panel generator
-------------------------------------
local function panel_code(pos, program)
    return
        highlight(9, 0, 1, 1, "5", "5", "f")
        .. highlight(14, 0, 1, 1, "5", "5", "f")
        .. highlight(11, 0, 2, 1, "5", "5", "f")
        .. button(9, 0, "vbots_gui_run.png", "run", true)
        --..button(11,0,"vbots_gui_check.png","check")
        .. button(14, 0, "vbots_gui_nuke.png", "reset")
        .. button(11, 0, "vbots_gui_load.png", "load", true)
        .. button(12, 0, "vbots_gui_save.png", "save", true)

        .. highlight(15, 0, 1, 1, "f", "0", "0")
        .. button(15, 0, "vbots_gui_exit.png", "exit", true)

        -- trash can
        .. highlight(6.5, 0, 2, 1, "0", "0", "0")
        .. button(6.5, 0, "vbots_gui_trash.png", "trash")
        .. padded_list("detached:bot_trash", "main", 7.5, 0, 1, 1)
        --    .."list[detached:bottrash;main;7.5,0;1,1;]"
        --           .."listring[nodemeta:" .. pos .. ";p"..program.."]"

        .. draw_subroutines(pos, program)
end




-------------------------------------
-- Formspec generator
-------------------------------------
local function get_formspec(pos, meta)
    local bot_key = meta:get_string("key")
    local bot_owner = meta:get_string("owner")
    local bot_name = meta:get_string("name")
    local bot_pos = pos.x .. "," .. pos.y .. "," .. pos.z
    local fs_panel = meta:get_int("panel")
    local fs_program = meta:get_int("program")
    --print(dump(meta:to_table().fields))
    --print("Panel:"..fs_panel)
    --print("Program:"..fs_program)
    local formspec = "formspec_version[7]"
        .. "size[17.5,10]"
        .. "container[0.25,0.25]"
        .. maketext(3, 0.25, bot_name, "big")
        .. panel_main(bot_pos, fs_panel)
        .. panel_code(bot_pos, fs_program)
        .. "container_end[]"
    return formspec
end



-------------------------------------
-- callback from bot node on_rightclick
-------------------------------------
function VBOTS.show_formspec(clicker, pos)
    local meta = minetest.get_meta(pos)
    local bot_key = meta:get_string("key")
    minetest.show_formspec(clicker:get_player_name(),
        bot_key,
        get_formspec(pos, meta)
    )
end
