--page for all jelpiblock related code

function jelpiinit() --inital jelpi data creation
    jelpi = {
        spr = 49, --sprite numner
        frame = 0, --frame counter used for winning dance animation
        f = false, --flip sprite
        x = world.jelpix * 8, --exact x position
        y = world.jelpiy * 8, --exact y position
        celx = world.jelpix, --celx position
        cely = world.jelpiy, --cely position
        saved = false, --has reached the surface
        alive = false, --has jelpi been spawned from the block
        follow = false, --is jelpi following the robot
    }
end

function jelpimove(direction)
    printh("jelpi move")

    if direction == "left" then 
        jelpi.x = robot.x + 8  --set position one to the right of the robot e.g the block it just moved from
        jelpi.celx = robot.celx + 1 
        jelpi.y = robot.y --go to same y position
        jelpi.cely = robot.cely 
        jelpi.f = true --flip sprite
    elseif direction == "right" then 
        jelpi.x = robot.x - 8
        jelpi.celx = robot.celx + 1
        jelpi.y = robot.y 
        jelpi.cely = robot.cely 
        jelpi.f = false --unflip sprite
    elseif direction == "up" then 
        jelpi.y = robot.y + 8
        jelpi.cely = robot.cely + 1
        jelpi.x = robot.x
        jelpi.celx = robot.celx
    elseif direction == "down" then 
        jelpi.y = robot.y - 8
        jelpi.cely = robot.cely - 8
        jelpi.x = robot.x
        jelpi.celx = robot.celx
    end

end

function jelpidance()

    jelpi.frame += 1

    if jelpi.frame % 10 == 0 then --advance animation position every 10 frames
        if jelpi.spr < 52 then 
            jelpi.spr += 1
        else jelpi.spr = 49 end
    elseif jelpi.frame > 1000 then jelpi.frame = 0 end --reset counter to avoid too large integer

end

function jelpisaved()

    --draw speech bubble
    palt(10,true)
    palt(0,false)
    spr(78,jelpi.x - 5, jelpi.y - 16,2,2)
    palt()

end
