-- pico miner
-- by josie


--[[ #include map.lua
#include movement.lua
#include actions.lua
#include ui.lua
#include stats.lua ]]

--flags: 0 = collide, 1 = can stand ontop, 7 = mineable

function _init()

    --custom palette options
    poke(0x5f2e, 1)
    pal(3,132, 1) --change color 3 to color 132 (darker brown shade)
    pal(2,140, 1) --change color 2 to color 140 (darker blue shade)

    --map values
    world = {
        x = 0, --x 
        celw = 128, --map width in map cells
        celh = 64, -- map height in map cells
        levelskyy = 0, --y mapcell positions for each level
        levelgroundy = 12, --where the dirt starts
        jelpix = 0, jelpiy = 0 --position of the jelpi block
    }

    orevalues = { --table for information on each ore
        stone = { --each ore has its own subtable
            sprite = 65, --store sprite location
            rarity = 0.07, --the rarity for worldgen
            value = 0, --the value in coins 
            ecost = 1, --the multiplier for energy cost (actual ecost = robot.ecost * ore.ecost)
        },
        copper = {
            sprite = 66,
            rarity = 0.03,
            value = 10,
            ecost = 1.1
        },
        gold = {
            sprite = 67,
            rarity = 0.02,
            value = 20,
            ecost = 1.25
        },
        cobalt = {
            sprite = 68,
            rarity = 0.02,
            value = 30,
            ecost = 1.3
        },
        quartz = {
            sprite = 69,
            rarity = 0.01,
            value = 50,
            ecost = 1.5
        }
    }

    --create robot character
    robot = {
        spr = 1, --sprite number
        x = 64*8, -- exact pixel position
        y = 8*8,
        celx = 64, --map cell position
        cely = 8,
        f = false, --flip sprite left/right false/true
        underground = false, --is robot underground
        ecost = 5, --energy cost of mining a block 
        falling = false
    }

    robot.depth = robot.y / 8

    stats = { --table for tracking game stats
        max = { --max possible values
            ladders = 10,    --number of ladders
            supports = 5,   --number of supports
            money = 32750, --pico integer limit
            inventoryitems = 10, --how much items in inventory
            energy = 100, --energy count
        }, 
        current = { --current values
            ladders = 10,    --number of ladders
            supports = 5,   --number of supports
            money = 0, --money count
            inventoryitems = 0, --how much items in inventory
            inventoryvalue = 0, --value of items in inventory
            inventoryper = 0,  --percent of inventory for showing in backpack bar
            energy = 100, --energy count
            energyper = 100,  --percent of battery for bat bar
            depth = robot.cely - 11, --depth
        },
    } 
    stats.current.inventoryper = (5 * stats.current.inventoryitems) / stats.max.inventoryitems --was hadrcoded to 10 but i think this variable should be right
    stats.current.energyper = (23 * stats.current.energy) / stats.max.energy --same here was hardcoded to 100
    stats.current.batteryalive = ceil(stats.current.energy / (stats.max.energy / 20)) --currently unused
    
    --screen location
    screenx, screeny = robot.x + 8 - 63, robot.y + 8 - 63

    --values for the ui bar at the bottom of the screen
    uibar = {
        tx = screenx, --x for top left pixel of border edge
        ty = screeny + 111, --y for top left pixel of border edge
        by = screeny + 127, -- y for bottom right pixel of border edge
    }
    
    --variable for the dark clip mask when underground
    darkmask = false

    --camera set to robot position
    scrollcam()

    --world generation
    worldgeneration(world.x+1, world.levelgroundy, 126, 64-12-1)
    world.jelpix = flr(rnd(128)) --anywhere on the x axis
    world.jelpiy = flr(rnd(26) + 26) --in the bottom half of y axis
    mset(world.jelpix, world.jelpiy, 70)
    printh("world generated")

    --clear last thing
    cls()
end



function _update()

    --is the robot underground?
    robot.underground = robot.y > 88 --if the robots head is under the top layer of blocks, trigger underground mode

    gravity()

    --player movement
    robomove()

    --stats
    updatestats()



end



function _draw()
    cls()

    --has to be done after cls() but before anything else
    if robot.underground then --set the clipping rectangle for underground filter
        clip(robot.x - 12 - screenx, robot.y - 12 - screeny, 32, 32) --robot.x - 12,robot.y - 12    robot.x - 16 ,robot.y - 16
    end
    
    rectfill(0,0,1024,512,3) --draws darker background layer

    scrollcam() --scrolls camera 

    --draw current map
    map(0,0,0,0,world.celw,world.celh)
    
    --draw robot
    spr(robot.spr,robot.x,robot.y,1,1,robot.f)
    
    --draw ui above or below ground
    if robot.underground then
        clip() --reset clip mask for ui to go over top
        darkscreen() --fill in rectangle to a circle
        drawui()--draw the ui
    else
        drawui() --draw without clipping anyway
    end

end

--function to fill in the corners of the underground filter using a quarter circle sprite on page 4
--gotten from https://www.lexaloffle.com/bbs/?tid=46286
function darkscreen()
    palt(10,true)
    palt(0,false)
    local myx = robot.x + 4
    local myy = robot.y + 4 
    local myr = 16
    local sx = 112 --(110 % 16) * 8 
    local sy = 48--(110 \ 16) * 8
    sspr(sx,sy,16,16,myx-myr,myy-myr,myr,myr)
    sspr(sx,sy,16,16,myx,myy-myr,myr,myr,true)
    sspr(sx,sy,16,16,myx-myr,myy,myr,myr,false,true)
    sspr(sx,sy,16,16,myx,myy,myr,myr,true,true)
    palt()
end 

--function to scroll the camera, keeping player locked in center
function scrollcam()
    camera(robot.x - 55, robot.y - 55)
end



