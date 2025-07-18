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

    end


    --update money when selling / buying

end

