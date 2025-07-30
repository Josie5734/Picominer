--page for all jelpiblock related code

--[[
what is needed?

jelpi movement function

animation function

behaviour when reaching the surface

behaviour when robot dies
]]

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

function jelpianimate()

end

function jelpisurface()

end

function jelpiwait()

end