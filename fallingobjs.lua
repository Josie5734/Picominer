-- functions for falling objects



--checks if block above can be a falling object 
function fallingcheck()

    local block = mget(robot.celx,robot.cely-1)

    --check if block above is stone
    if block == 65 or block == 114 or block == 115 then --if block above is stone or support

        --create stone object
        local object = {
            x = robot.x, y = robot.y - 8, --position of stone in x,y for specific movements
            celx = robot.celx, cely = robot.cely - 1, --map cel of stone
            sprite = block, --sprite number of object
            timer = 0, --tracks how long the stone has been spawned for, used to decide what to do with it
            finished = false, --stone has reached the final placement and object is ready to be removed
            update = fallingupdate, draw = fallingdraw, --the update function for the stone
        }
        add(fallingobjs,object) --add new object to the stone objects list

    end

end

--the update function for the stone objects  
function fallingupdate(o)

    --remove map block where object is at start
    if o.timer == 0 then 
        if o.sprite == 115 then --in specific case of support ladders
            mset(robot.celx,robot.cely-1,113) --set the block to just a ladder
            o.sprite = 114 --set the object to just a support so only the support falls
        else --object is not a support ladder
            mset(o.x/8,o.y/8,0) --just remove block
        end
    end

    --initial wobble animation
    if o.timer > 1 and o.timer <= 60 then --for the first 60 frames (s seconds)
        if o.timer % 5 == 0 and o.timer % 10 != 0 then --if frames is a multiple of 5 but not 10 e.g 5,15,25
            o.y += 1 --move block one pixel down
        elseif o.timer % 10 == 0 then --if frames is a multiple of 10 e.g 10,20,30
            o.y -= 1 --move back up 1 pixel
        end
    end

    --collision to break ladders when halfway over them and to squish the robot
    if o.sprite == 65 then --only applies to stone object
        if o.y % 8 == 4 then --if stone is halfway over block
            if mget(o.celx,o.cely+1) == 113 then --if block is ladder
                mset(o.celx,o.cely+1,0) --remove ladder
            end
            if robot.x == o.x and robot.y == o.y + 4 then --if robot is in same x pos and 4 pixels below top of stone
                robot.alive = false --kill robot
            end
        end
    end

    --falling sequence   - 1 pixel every 4 frames, until collision with block below
    if o.timer > 60 then --after 60 frames
        if o.timer % 2 == 0 then --every 4 frames
            if fget(mget(o.celx,o.cely+1),0) == false or fget(mget(o.celx,o.cely+1),3) then --collision detection, checks flag of map cel below current for either 0 or 3 (solid block or support)
                o.y += 1 --move down one pixel
            else --if flag is 0 (there is a block there) - end of falling sequence
                if o.sprite == 114 and mget(o.celx,o.cely) == 113 then --if the sprite is a support and final block is a ladder
                    mset(o.celx,o.cely,115) --set block to support ladder
                else --else empty block, set to stone or support
                    mset(o.celx,o.cely,o.sprite) --set the map tile to object
                end
                o.finished = true --set finished flag to true
            end
        end
        --update the current cel of the object while falling
        o.cely = (o.y - (o.y % 8)) / 8 
    end

    o.timer += 1 --iterate timer 
    
    return o.finished --return the state of the object

end

--draw the stone as a sprite, used for the FOR to be able to loop through objects
function fallingdraw(o) 
    spr(o.sprite,o.x,o.y)
end
