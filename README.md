# visual-bots
## A minetest programmable bot
Vbots are single block "turtle" style bots, programmable in an entirely visual way.
They came into existence to amuse my 5 year old daughters, and teach them the basics
of computer programming, without too much writing.

## Basics
Punch an idle vbot with an empty hand to make it run it's program (or click the run icon in the menu [see below]).

Punch a running vbot with an empty hand to stop the program.

Right click (double tap on android) to open the menu (see below).

Dig the bot by hitting it with anything except an empty hand, but bear in mind the bot can only be 
dug out if it's inventory is empty.

## The Main menu

![Main Menu 1](/images/doc_menu1.png)

The icons ![commands](/textures/vbots_gui_commands.png) and ![inventory](/textures/vbots_location_inventory.png) are used to switch between the 2 panels shown here.

The panel above contains the commands for the bot, which can be added to the current sub-program (the red area on the right) simply by clicking on them.

The panel below shows the inventory panel, with the bot's inventory above, and the players inventory below.
This panel is used to add things to the bot's inventory (so it can build with them) or to remove things from the bot's inventory after it has been digging.


![Main Menu 2](/images/doc_menu2.png)

The trash ![Trash](/textures/vbots_gui_trash.png) icon, when pressed, deletes the last instruction on the current sub-program page. Bext to the icon is another 1x1 inventory slot which works as a trash can, anything dropped into it is destroyed.

The run ![run](/textures/vbots_gui_run.png) icon, works like punching the bot with an open hand, It starts the program runnng.

The save ![save](/textures/vbots_gui_save.png) icon saves the current program & sub-programs under the name of the bot.

the load ![load](/textures/vbots_gui_load.png) icon allows you to choose and load a program into the bot. Also on this menu are icons which allow the deleting & renaming of programs. 

The sub-program panel (the red one on the right) has 7 pages.
The ![Lion](/textures/vbots_program_0.png) icon is the page for the 'Main' program, execution starts here when the bot is activated.
The other 6 pages are sub-programs which can be called via the 6 'run sub program' icons at the bottom of the command panel.

## Commands
Excepting the run sub program commands mentioned earlier, here is a list of the commands.
