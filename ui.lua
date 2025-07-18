--drawing ui and camera



function updateui() -- currently unused, keeping just incase
end

function drawui()

    local toprow = uibar.ty + 2 -- value for top row of ui to avoid constant recalculating
    local x, y = uibar.tx, uibar.ty

    --bottom bar
    rect(x, y, x + 127, uibar.by, 11) --border
    rectfill(x + 1, y + 1, x + 126, uibar.by - 1, 0) --main 

    --ladders
    spr(112, x + 2, toprow)
    if stats.current.ladders < 10 then --put a 0 before the number if it is single digits
        print("0" .. stats.current.ladders,x + 11, toprow, 6) 
    else
        print(stats.current.ladders,x + 11, toprow, 6) 
    end

    line(x + 19, y, x + 19, uibar.by, 11) --divider

    --supports
    spr(114, x + 19, toprow)
    if stats.current.supports < 10 then --put a 0 before the number if it is single digits
        print("0" .. stats.current.supports, x + 26, toprow, 6)
    else
        print(stats.current.supports, x + 26, toprow, 6)
    end

    line(x + 34, y, x + 34, uibar.by, 11) --divider

    --energy section
    rect(x + 36, toprow, x + 61, y + 6, 6) --energy bar border
    rectfill(x + 37, toprow + 1, x + 60, y + 5, 8) --red behind the green
    rectfill(x + 37, toprow + 1, x + 37 + stats.current.energyper, y + 5, 11) --energy bar fill
    
    --batteries (currently static, doesnt change with energy)
    spr(9,x + 34, y + 8) 
    spr(9,x + 39, y + 8) 
    spr(9,x + 44, y + 8) 
    spr(9,x + 49, y + 8) 
    spr(9,x + 54, y + 8) 
     
    line(x + 61,y + 8, x + 61, y + 13) --battery meter (also static)

    line(x + 63, y, x + 63, uibar.by, 11) --divider

    --inventory
    spr(8, x + 65, toprow) --backpack sprite
    rect(x + 65, y + 11, x + 72, y + 13, 6) --inventory bar border
    line(x + 66, y + 12, x + 71, y + 12, 11) --green underneath
    if stats.current.inventoryitems > 0.1 then --only draw fill if inventory is above 0, otherwise it draws 1 pixel anyway
        line(x + 66, y + 12, x + 66 + stats.current.inventoryper, y + 12, 8) --draw red as inventory fills
    end

    --print inventory amount
    if stats.current.inventoryitems < 10 then --put a 0 before the number if it is single digits
        print("0" .. stats.current.inventoryitems .. "/" .. stats.max.inventoryitems, x + 75, toprow, 6)
    else
        print(stats.current.inventoryitems .. "/" .. stats.max.inventoryitems, x + 75, toprow, 6)
    end

    line(x + 95, y, x + 95, uibar.by, 11) --divider

    --money
    spr(11, x + 97, toprow) --coin sprite
    local z = sub("00000",1,6-#tostr(stats.current.money)) --add 0s to start of number
    print(z .. stats.current.money, x + 103, toprow, 6)
    
    --depth
    spr(12, x + 113, y + 10) --depth arrow
    if stats.current.depth < 10 then --put a 0 before the number if it is single digits
        print("0" .. stats.current.depth, x + 119, y + 10, 6) 
    else
        print(stats.current.depth, x + 119, y + 10, 6)
    end


end


