-- pico miner
-- by josie


--[[ #include map.lua
#include movement.lua
#include actions.lua
#include ui.lua
#include stats.lua 
#include shop.lua
#include fallingobjs.lua]]

--flags: 0 = collide, 1 = can stand ontop, 2 = jelpiblock, 3 = support, 7 = mineable

function _init()

    --custom palette options
    poke(0x5f2e, 1)
    pal(3,132, 1) --change color 3 to color 132 (darker brown shade)
    pal(2,140, 1) --change color 2 to color 140 (darker blue shade)

    --map values
    worldinit()

    --world generation
    worldgeneration(world.x+1, world.levelgroundy, 126, 64-12-1)
    world.jelpix = flr(rnd(128)) --anywhere on the x axis
    world.jelpiy = flr(rnd(26) + 26) --in the bottom half of y axis
    mset(world.jelpix, world.jelpiy, 70)
    printh("world generated")

    --list for falling objects
    fallingobjs = {}
    --has x and y pos, timer values for events

    --create robot character
    robot = {
        spr = 1, --sprite number
        x = world.spawncelx*8, -- exact pixel position
        y = world.spawncely*8,
        celx = world.spawncelx, --map cell position
        cely = world.spawncely,
        f = false, --flip sprite left/right false/true
        underground = false, --is robot underground
        ecost = 2, --default energy cost for moving 
        falling = false, --is robot falling
        direction = "", --what was the last direction moved
        alive = true, --alive state
    }

    robot.depth = robot.y / 8

    --stats for jelpi
    jelpiinit()

    --shop initialisation
    shopinit()

    stats = { --table for tracking game stats
        max = { --max possible values
            ladders = 10,    --number of ladders
            supports = 5,   --number of supports
            money = 32750, --pico integer limit
            inventoryitems = 10, --how much items in inventory
            energy = 100, --energy count
            falldist = 4 --max fall height before death - if fall > falldist then die 
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
            falldist = 0 --max fall height before death - if fall > falldist then die 
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
        status = "", --status bar message
        statuscount = 0 --counter for uibar where applicable
    }

    visiondata = { --stats for the clipping rectangle 
        x = robot.x - 12 - screenx, --rectangle x coord
        y = robot.y - 12 - screeny, --rectangle y coord
        size = 32, --rectangle size
        myr = 16 --circle radius size
    }
    
    --variable for the dark clip mask when underground
    darkmask = false

    --the state variable for opening splash screen, true at start of game
    splashmenu = true

    --camera set to robot position
    scrollcam()

    --clear last thing
    cls()
end



function _update()

    --is the robot underground?
    robot.underground = robot.y > 88 --if the robots head is under the top layer of blocks, trigger underground mode

    if not robot.underground then --only update shop if on surface
        shopupdate()
    end 

    gravity()

    --controls
    if splashmenu == true then --if opening splash menu is there
        if btnp(0) or btnp(1) or btnp(2) or btnp(3) or btnp(4) or btnp(5) then splashmenu = false end 
    else --once splash menu is done, standard controls for rest of game
        if robot.alive and not shop.open then
            --player movement
            robomove()
            --support placement
            placesupport()
        
        elseif not robot.alive then --if not alive
            robot.spr = 17 --death sprite
            if btnp(5) then --x to respawn
                robot.alive = true --reset state
                respawn()
            end
        elseif shop.open then --shop menu controls
            shopcontrols()
        end
    end

    --stats
    updatestats()

    if not robot.alive then uibar.status = "❎ to respawn" end --respawn button prompt status message

    --jelpi update
    if jelpi.alive then --jelpi alive
        if not jelpi.saved then --if not saved
            if jelpi.follow then --if currently following
                jelpimove(robot.direction) --jelpi movement

                if not robot.underground and jelpi.cely < 12 then --if both on surface
                    --maybe have a thing to make him move to his house
                    jelpi.saved = true --set state as saved
                    jelpi.follow = false --stop following
                end --jelpi has been saved

                if not robot.alive then --if robot dies while jelpi is following
                    jelpi.follow = false --stop following
                end 
            else
                if robot.celx == jelpi.celx and robot.cely == jelpi.cely then --if robot is on samw block as jelpi
                    jelpi.follow = true --jelpi start following
                end 
            end
        else jelpidance() end --else saved, do dance animation
    end

    --falling object updating
    local i, j = 1, 1 --used for iterating through object list (cant use del() since objects are not uniquely named)
    while (fallingobjs[i]) do --loop through all the objects in the list
        if not fallingobjs[i]:update() then --if updating object returns false on the "finished" value
            if (i!=j) fallingobjs[j]=fallingobjs[i] fallingobjs[i]=nil --shift objects if necessary ?
            j += 1
        else fallingobjs[i]=nil end --if object update does return true on "finished", make that object nil (delete it)
        i += 1 --iterate to next object
    end


end



function _draw()
    cls()

    --has to be done after cls() but before anything else
    if robot.underground then --set the clipping rectangle for underground filter
        clip(visiondata.x, visiondata.y, visiondata.size, visiondata.size) 
    end
    
    rectfill(0,0,1024,512,3) --draws darker background layer

    scrollcam() --scrolls camera 

    --draw current map
    map(0,0,0,0,world.celw,world.celh)

    --draw splashscreen at start
    if splashmenu == true then 
        palt(10,true)
        palt(0,false)
        spr(83,screenx+19,screeny+2,11,3)
        palt()
    end
    
    --draw robot
    spr(robot.spr,robot.x,robot.y,1,1,robot.f)

    if not robot.underground then --if robot on surface
        spr(shop.spr, shop.x, shop.y) --draw shop sprite
        if shop.open then --draw shop ui
            shopdraw()
        end
    end

    --jelpi draw
    if jelpi.alive then
        spr(jelpi.spr, jelpi.x, jelpi.y,1,1,jelpi.f)

        if jelpi.saved then --draw saved speech bubble
            jelpisaved()
        end
    end

    --falling object sprite drawing
    for o in all(fallingobjs) do o:draw() end --do the draw function for every current object

    --draw ui above or below ground
    if robot.underground then
        clip() --reset clip mask for ui to go over top
        darkscreen(visiondata.myr) --fill in rectangle to a circle
        drawui()--draw the ui
    else
        drawui() --draw without clipping anyway
        rectfill(robot.x-55, robot.y+24,robot.x+72,robot.y+47,0)--rectangle to cover the underground when on the surface
    end

    

end



--function to fill in the corners of the underground filter using a quarter circle sprite on page 4
--gotten from https://www.lexaloffle.com/bbs/?tid=46286
function darkscreen(radius)
    palt(10,true)
    palt(0,false)
    local myx = robot.x + 4
    local myy = robot.y + 4 
    local myr = radius --default = 16
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

function respawn() --reset the robot back to the top
    printh("respawning")
    stats.current.energy = stats.max.energy --reset energy
    stats.current.inventoryitems = 0 --empty inventory
    stats.current.inventoryvalue = 0

    uibar.status = "" --reset status bar message

    robot.spr = 1 --reset sprite

    --reset position - needs system to avoid if spawnblock is empty
    
    --check spawn block
    local celx, cely = world.spawncelx, world.spawncely + 1
    local valid = false
    if fget(mget(celx,cely), 1) then --check block under spawn, if walkable then spawn there
        robot.x, robot.celx = world.spawncelx*8, world.spawncelx 
        robot.y, robot.cely = world.spawncely*8, world.spawncely
    else
        while not valid do --while block below isnt walkable, move one block left, recheck
            printh("checking left")
            if fget(mget(celx,cely), 1) then --if block is solid, spawn
                robot.x, robot.celx = celx*8, celx 
                robot.y, robot.cely = (cely - 1)*8, cely - 1
                valid = true
            else --else move left by one block
                celx -= 1
            end
        end --repeat until a valid block is found
    end
    --could be improved by having a fallback if there is not any solid surface block but that is probably overkill for now

    --reset ui
    screenx, screeny = robot.x + 8 - 63, robot.y + 8 - 63
    uibar.tx = screenx --x for top left pixel of border edge
    uibar.ty = screeny + 111 --y for top left pixel of border edge
    uibar.by = screeny + 127 -- y for bottom right pixel of border edge
    
end
