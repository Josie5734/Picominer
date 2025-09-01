--player movement controls for picominer



function robomove()

    --movement controls 

    if btnp(0) then --left
        if checkflag("left",0) then --if collision = true
            if checkflag("left",7) then --if mineable
                if checkflag("left",2) then --if block is jelpiblock, spawn jelpi
                    jelpi.alive = true
                    jelpi.follow = true
                end
                mine(robot.celx - 1, robot.cely) -- dig block  
                moveleft() --move
            else uibar.status = "unbreakable" end --status message for not breakable
        else --if collision != true
            moveleft() --move
        end
    end

    if btnp(1) then --right
        if checkflag("right",0) then 
            if checkflag("right",7) then 
                if checkflag("right",2) then --if block is jelpiblock, spawn jelpi
                    jelpi.alive = true
                    jelpi.follow = true
                end
                mine(robot.celx + 1, robot.cely) 
                moveright()
            else uibar.status = "unbreakable" end --status message for not breakable
        else
            moveright()
        end
    end

    if btnp(2) and robot.underground and not robot.falling then --UP 
        if mget(robot.celx,robot.cely-1) != 65 and mget(robot.celx,robot.cely-1) != 71 then --if block above is not stone or sprite 71(empty sprite used as stone stand in during falling animation, removed once stone starts falling)
            if mget(robot.celx, robot.cely) != 113 then --if current block is not ladder
                if stats.current.ladders > 0 then --if ladder counter > 0 
                    stats.current.ladders -= 1 --remove 1 ladder from inventory
                    if mget(robot.celx,robot.cely) == 114 then --if block is a support
                        mset(robot.celx,robot.cely,115) --place a supported ladder
                    elseif mget(robot.celx,robot.cely) == 0 then --if block is empty
                        mset(robot.celx, robot.cely, 113) --place a normal ladder  
                    end --no check for support ladders, should just go up as if it is an existing ladder
                    if checkflag("up",2) then --if block is jelpiblock, spawn jelpi
                        jelpi.alive = true
                        jelpi.follow = true
                    end
                    if checkflag("up",6) == false then --mine block above if it isnt air/ladder
                        mine(robot.celx, robot.cely - 1) 
                    end 

                    moveup()  
                end --cannot move up
            else --block is ladder
                if checkflag("up",6) == false then mine(robot.celx, robot.cely - 1) end --mine block above if it isnt air/ladder/support
                moveup()  
            end
        else uibar.status = "unbreakable" end --status message for not breakable
    end

    if btnp(3) then --down
        if checkflag("down",0) then 
            if checkflag("down",7) then
                if checkflag("down",2) then --if block is jelpiblock, spawn jelpi
                    jelpi.alive = true
                    jelpi.follow = true
                end
                mine(robot.celx, robot.cely + 1) 
                movedown()
            else uibar.status = "unbreakable" end --status message for not breakable
        else
            movedown()
        end
    end 
    
end

--animate robot on movement
function animate(o)
    if o % 16 != 0 then --every other frame
        robot.spr = 1
    else 
        robot.spr = 2
    end 

    --jelpi animation
    if jelpi.spr < 52 then jelpi.spr += 1 elseif jelpi.spr == 52 then jelpi.spr = 49 end --move sprite along

end

function mine(xx,yy) --xx, yy is block to be mined

    local block = mget(xx,yy) --get sprite number of next block
    local money = 0

    if block >= 66 and block <= 69 then --if block is an ore
        if stats.current.inventoryitems < stats.max.inventoryitems then  --if there is space in inventory
            stats.current.inventoryitems += 1 --add one to inventory item count
            for ore,vals in pairs(orevalues) do  --iterate through ore table 
                if vals.sprite == block then money = vals.value end --find sprite value and assign money to the value from that sprite
            end
            stats.current.inventoryvalue += money --add money value to inventory
            printh("mined " .. block)
        else printh("inventory full, ore destroyed") end --inventory is full
        for ore,vals in pairs(orevalues) do --iterate to find energy usage for an ore
            if vals.sprite == block then stats.current.energy -= robot.ecost * vals.ecost end --remove energy 
        end
    else stats.current.energy -= robot.ecost end --not an ore, - default ecost

    mset(xx, yy, 0)--mine block

    fallingcheck(xx,yy-1) --do a falling check on the mined block
end

--may need reassessing after movement overhaul
function gravity()
    --if block below does not have flag 1 (ladder) and does not have flag 0 (solid)
    --move robot down by 2 pixels until it stands on one that does
    if not fget(mget(robot.celx, robot.cely + 1),1) and not checkflag("down",0) then 
        robot.y += 2
        robot.cely += 0.25 --move cell position
        animate(robot.y)
        screeny += 2  --stops the clipping rectangle from offsetting during movement
        uibar.ty += 2 --move ui
        uibar.by += 2
        robot.falling = true --bool for falling to prevent placing ladders while falling
        robot.direction = "down" --set direction 
        stats.current.falldist += 0.25 --add blocks fallen
    else 
        if stats.current.falldist > stats.max.falldist then --check falldist
            robot.alive = false --die if fell too far
        end
        robot.falling = false 
        stats.current.falldist = 0 --reset fall distance
    end 

end

--simple collision
function checkflag(direction,flag)
    --stop from moving through blocks
    local value = false

    --for inputted direction give flag
    if direction == "left" then value = fget(mget(robot.celx - 1, robot.cely), flag)  
    elseif direction == "right" then value = fget(mget(robot.celx + 1, robot.cely), flag) 
    elseif direction == "up" then value = fget(mget(robot.celx, robot.cely - 1), flag) 
    elseif direction == "down" then value = fget(mget(robot.celx, robot.cely + 1), flag) end 

    return value
end

--functions for moving (done as function because move is called in 2 possible places, saves like 10 tokens each)
function moveleft()
    robot.x -= 8 --move left
    robot.celx -= 1 --move cell position
    robot.f = false --dont flip sprite
    --animation, change sprite each move
    animate(robot.x)
    screenx -= 8  --stops the clipping rectangle from offsetting during movement
    uibar.tx -=8 --move ui
    stats.current.energy -= robot.ecost --use energy for moving
    robot.direction = "left" --direction moved
end

function moveright()
    robot.x += 8 --move right
    robot.celx += 1 --move cell position
    robot.f = true --flip sprite
    animate(robot.x)
    screenx += 8  --stops the clipping rectangle from offsetting during movement
    uibar.tx +=8 --move ui
    stats.current.energy -= robot.ecost
    robot.direction = "right" --direction moved
end

function moveup()
    robot.y -= 8 
    robot.cely -= 1 --move cell position
    animate(robot.y)
    screeny -= 8  --stops the clipping rectangle from offsetting during movement
    uibar.ty -= 8 --move ui
    uibar.by -= 8
    robot.direction = "up" --direction moved
    if fget(mget(robot.celx, robot.cely-1),1) then stats.current.energy -= robot.ecost end --dont take energy if block above is surface
end

function movedown()
    robot.y += 8 
    robot.cely += 1 --move cell position
    animate(robot.y)
    screeny += 8  --stops the clipping rectangle from offsetting during movement
    uibar.ty += 8 --move ui
    uibar.by += 8
    robot.direction = "down" --direction moved
    stats.current.energy -= robot.ecost
end

--support placement
function placesupport()
    if robot.underground then --if robot is underground
        if btnp(4) then --Z to place support 
            if fget(mget(robot.celx,robot.cely+1),3) or fget(mget(robot.celx,robot.cely+1),0) then --if block below is support or solid
                if fget(mget(robot.celx,robot.cely),3) then --if flag for cell is 3(support or ladder support) then
                    if mget(robot.celx,robot.cely) == 115 then --if block is a support ladder
                        mset(robot.celx,robot.cely,113) --set to just a ladder
                        stats.current.supports += 1 --add support to inventory
                    else --else block is a regular support
                        mset(robot.celx,robot.cely,0) --set to nothing
                        stats.current.supports += 1 --add support to inventory
                    end
                else --block is not already a support
                    if stats.current.supports > 0 then --if have supports in inventory
                        if mget(robot.celx,robot.cely) == 113 then --if block is ladder
                            mset(robot.celx,robot.cely,115) --set to support ladder
                            stats.current.supports -= 1 --use 1 support
                        else --else it is empty
                            mset(robot.celx,robot.cely,114) --set block to support
                            stats.current.supports -= 1 --use 1 support
                        end
                    end
                end    
            end 
        end
    end
end