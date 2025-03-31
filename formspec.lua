-------------------------------------
-- Formspec colored boxes
-------------------------------------
local function highlight(item, line, w, h, r, g, b, a)
    a = a or "f"
    local padding = 0
    local item = item - padding
    local line = line - padding
    w = w + padding * 2
    h = h + padding * 2
    return "box[" .. item .. "," .. line .. ";" .. w .. "," .. h .. ";#" ..
        r .. r .. g .. g .. b .. b .. a .. a .. "]"
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
    return list_string
end

local function padded_list(inventory, list, x, y, numx, numy)
    return padded_list_of_size(inventory, list, x, y, 1, 1, numx, numy, 0.1)
end


-------------------------------------
-- Formspec button generators
-------------------------------------

local function _image_button(x, y, w, h, image, name, tooltip, exit)
    local padding = 0.1
    x = x + padding
    y = y + padding
    w = w - padding * 2
    h = h - padding * 2
    return "image_button"..exit.."[" .. x .. "," .. y .. ";" .. w .. "," .. h .. ";" .. image .. ";" .. name .. ";]" ..
        "tooltip[" .. x .. "," .. y .. ";" .. w .. "," .. h .. ";" .. tooltip .. "]"
end

local function item_image_button_padding(x, y, w, h, padding, name)
    x = x + padding
    y = y + padding
    w = w - padding * 2
    h = h - padding * 2
    return string.format("item_image_button[%s,%s;%s,%s;%s;%s;%s]", x, y, w, h, "turtlebots:"..name, name, "")
end

local function image_button_tooltip(x, y, w, h, image, name, tooltip)
    return _image_button(x, y, w, h, image, name, tooltip, "")
end
local function image_button(x, y, w, h, image, name)
    return _image_button(x, y, w, h, image, name, name, "")
end
local function image_button_exit(x, y, w, h, image, name, tooltip)
    if not tooltip then
        tooltip = name
    end
    return _image_button(x, y, w, h, image, name, tooltip, "_exit")
end
local function button_tooltip(x, y, image, tooltip, command, exit)
    if not exit then
        return image_button_tooltip(x, y, 1, 1, image, command, tooltip)
    else
        return image_button_exit(x, y, 1, 1, image, command, tooltip)
    end
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
    return item_image_button_padding(x, y, 1, 1, padding, name)
end


local function button_row_space(x, y, padding, nametable)
    local row = ""
    for i, name in pairs(nametable) do
        row = row .. cbutton(x + i - 1, y, padding, name)
    end
    return row
end

-------------------------------------
-- Main panel generators
-------------------------------------
local function panel_commands()
    return highlight(0, 1.5, 7, 9, "f", "f", "f", "7")
    .."container[0.25,0.25]"
    ..button_row_space(0,1.75,0.01, { "__blank", "move_forward", "__blank"})
    ..button_row_space(0,2.75,0.01, { "move_left", "stand_still", "move_right"})
    ..button_row_space(0,3.75,0.01, { "__blank", "move_backward", "__blank"})
    ..button_row_space(3.5,1.75,0.01, {blank_space, "move_up" })
    ..button_row_space(3.5,2.75,0.01, {"turn_anticlockwise", "stand_still","turn_clockwise" })
    ..button_row_space(3.5,3.75,0.01, {blank_space, "move_down", })
    ..button_row_space(0.225,5.75,0.01,{"loadblock_red", "loadblock_orange", "loadblock_yellow", "loadblock_green", "loadblock_grey", "loadblock_clear"})
    ..button_row_space(0.225,6.75,0.01,{"loadblock_cyan", "loadblock_blue", "loadblock_pink", "loadblock_white", "loadblock_black","add_1"})
    ..button_row_space(0.225,7.75,0.01,{"run_1", "run_2", "run_3", "run_4", "add_2", "add_4"})
    ..button_row_space(0.225,8.75,0.01,{"run_5", "run_6", "run_7", "run_8", "add_8", "add_16"})
    .. "container_end[]"
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
end

local function draw_subroutines(pos, program)
    local subroutines = ""
    subroutines = subroutines .. "container[1,0]"

    -- highlight coding area in purple
    subroutines = subroutines .. highlight(7, 1.5, TURTLEBOTS.PROGRAM_SIZE+1, program, "9", "9", "f", "7")
    subroutines = subroutines .. highlight(7, 1.5+program+1,TURTLEBOTS.PROGRAM_SIZE+1, 8-program, "9", "9", "f", "7")
    -- highlight selected program in light grey
    subroutines = subroutines .. highlight(6, 1.5 + program, TURTLEBOTS.PROGRAM_SIZE+2, 1, "f", "f", "f", "7")
    subroutines = subroutines .. string.format("image[%s,%s;1,1;turtlebots_selected.png]",6, 1.5 + program)

    local prog_names = {
        "Click to modify code in START",
        "Click to modify code in PROGRAM A",
        "Click to modify code in PROGRAM B", 
        "Click to modify code in PROGRAM C",
        "Click to modify code in PROGRAM D",
        "Click to modify code in PROGRAM E",
        "Click to modify code in PROGRAM F",
        "Click to modify code in PROGRAM G",
        "Click to modify code in PROGRAM H"
    }
    for i = 0, 8 do
        -- program list
        subroutines = subroutines
            .. padded_list("nodemeta:" .. pos, "p" .. i, 8, i + 1.5, TURTLEBOTS.PROGRAM_SIZE, 1)

        -- selector button for subroutine
        subroutines = subroutines
            .. button_tooltip(7, 1.5 + i, "turtlebots_program_" .. i .. ".png", prog_names[i+1], "sub_" .. i)
    end
    subroutines = subroutines .. "container_end[]"
    return subroutines
end

-------------------------------------
-- Main panel generator
-------------------------------------
local function panel_code(pos, program)
    return
        -- run button
        highlight(8, 0, 1, 1, "5", "5", "f")
        .. button_tooltip(8, 0, "turtlebots_gui_run.png", "Click to Run code in START", "run", true)
        -- exit button
        .. highlight(8+TURTLEBOTS.PROGRAM_SIZE, 0, 1, 1, "f", "0", "0")
        .. button_tooltip(8+TURTLEBOTS.PROGRAM_SIZE, 0, "turtlebots_gui_exit.png", "Close the code editor.", "exit", true)
        -- trash can
        .. highlight(8+TURTLEBOTS.PROGRAM_SIZE/2, 0, 2, 1, "5", "5", "f")
        .. button_tooltip(8+TURTLEBOTS.PROGRAM_SIZE/2, 0, "turtlebots_gui_trash.png", "Delete last code block in selected program.", "trash")
        .. padded_list("detached:bot_trash", "main", 9+TURTLEBOTS.PROGRAM_SIZE/2, 0, 1, 1)
        -- subroutines
        .. draw_subroutines(pos, program)
end




-------------------------------------
-- Formspec style definitions
-------------------------------------
local function get_formspec_style()
    -- Base style string with each element carefully documented
    local style = ""

    -- Set inventory slot colors
    -- param1: Slot background color (semi-transparent light gray)
    -- param2: Slot border color (semi-transparent white)
    -- param3: Selected slot highlight (very transparent white)
    -- param4: Text color (black)
    -- param5: Text highlight color (white)
    style = style .. "listcolors[#3337;#FFF7;#FFF0;#000;#FFF]"

    -- Style for image buttons
    -- Removes default border and applies custom background
    -- bgimg_middle defines the 9-slice scaling points
    style = style .. "style_type[image_button;border=false;"
                  .. "bgimg=turtlebots_button9.png;"
                  .. "bgimg_pressed=turtlebots_button9_pressed.png;"
                  .. "bgimg_middle=2,2]"

    -- Style for regular buttons (same as image buttons)
    style = style .. "style_type[button;border=false;"
                  .. "bgimg=turtlebots_button9.png;"
                  .. "bgimg_pressed=turtlebots_button9_pressed.png;"
                  .. "bgimg_middle=2,2]"

    -- Text styling for various elements
    -- Uses a dark gray that's easy to read on both light and dark backgrounds
    style = style .. "style_type[field;textcolor=#323232]"
           .. "style_type[label;textcolor=#323232]"
           .. "style_type[textarea;textcolor=#323232]"
           .. "style_type[checkbox;textcolor=#323232]"

    -- Set fully transparent base background
    -- This allows our bgcolor setting to work properly
    style = style .. "bgcolor[#00000000]"
    style = style .. "background9[0,0;1,1;turtlebots_background9.png;true;7]"
    return style
end

local function get_formspec(pos, meta)
    local bot_name = meta:get_string("name")
    local bot_pos = pos.x .. "," .. pos.y .. "," .. pos.z
    local fs_panel = meta:get_int("panel")
    local fs_program = meta:get_int("program")

    local formspec = "formspec_version[7]"
        .. string.format("size[%s,11]",9.5+TURTLEBOTS.PROGRAM_SIZE)
        .. "bgcolor[#00000080]"
        .. get_formspec_style()
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
function TURTLEBOTS.show_formspec(clicker, pos)
    local meta = minetest.get_meta(pos)
    local bot_key = meta:get_string("key")
    minetest.show_formspec(clicker:get_player_name(),
        bot_key,
        get_formspec(pos, meta)
    )
end