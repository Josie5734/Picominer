--game stats and upgrades functions

--upgrades - max energy - inventory space (includes +ladder/supports), potentially darkmode width, dig efficiency



function updatestats()

    stats.current.depth = robot.cely - 11--update depth 

    --display stats
    stats.current.inventoryper = (5 * stats.current.inventoryitems) / stats.max.inventoryitems --was hadrcoded to 10 but i think this variable should be right
    stats.current.energyper = (23 * stats.current.energy) / stats.max.energy --same here was hardcoded to 100

    --reset/add values when surfacing
    if (not robot.underground) then
        if stats.current.inventoryitems > 0 then --add inventory value and reset inventory
            stats.current.money += stats.current.inventoryvalue --add inventory value to money
            stats.current.inventoryitems = 0 --clear items and value from inventory
            stats.current.inventoryvalue = 0
        end

        --reset ladders
        if stats.current.ladders < stats.max.ladders then stats.current.ladders = stats.max.ladders end 

        --reset energy
        if stats.current.energy < stats.max.energy then stats.current.energy = stats.max.energy end
    end

    --set state fail when energy == 0
    if stats.current.energy <= 0 and robot.alive then 
        robot.alive = false 
        robot.spr = 17
        printh("dead")
    end

    --status message
    if not robot.underground then --if on surface, give prompt for shop in status bar
        uibar.status = "🅾️ to open shop"  
    elseif stats.current.energy < stats.max.energy / 10 then --10% energy
        uibar.status = "low energy"
    elseif stats.current.ladders == 3 then --3 ladders left - should only show for 3 ladders, allows for low energy to have priority
        uibar.status = "low ladders"
    else uibar.status = "" end --no status to report

    shop.x = robot.x --update shop position

end

