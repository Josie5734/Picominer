--map generation 

function worldinit() --initialise data for the map
    world = {
        x = 0, --x 
        celw = 128, --map width in map cells
        celh = 64, -- map height in map cells
        levelskyy = 0, --y mapcell positions for each level
        levelgroundy = 12, --where the dirt starts
        jelpix = 0, jelpiy = 0, --position of the jelpi block
        spawncelx = 64, spawncely = 11 --spawn point in map cells
    }

    orevalues = { --table for information on each ore
        stone = { --each ore has its own subtable
            sprite = 65, --store sprite location
            rarity = 0.07, --the rarity for worldgen
            value = 0, --the value in coins 
            ecost = 1, --the multiplier for energy cost (actual ecost = robot.ecost * ore.ecost) (example in stone, not actually applicable)
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
            ecost = 1.5
        },
        quartz = {
            sprite = 69,
            rarity = 0.01,
            value = 50,
            ecost = 2
        }
    }
end

--generates all the ores in the world
function worldgeneration(x,y,w,h)
    local total = w * h
    
    --percentage of the world that each block makes up
    local blocks = {
        stone = (0.07 * total), --flr(rnd(0.08 * total) + (0.02 * total)),
        copper = (0.03 * total),--flr(rnd(0.07 * total) + (0.01 * total)),
        gold = (0.02 * total),--flr(rnd(0.07 * total) + (0.007 * total)),
        cobalt = (0.02 * total),--flr(rnd(0.07 * total) + (0.009 * total)),
        quartz = (0.01 * total)--flr(rnd(0.05 * total) + (0.005 * total))
    }

    for ore,value in pairs(blocks) do --go through list and distribute each ore
        printh("distributing " .. ore)
        oredistribution(y,w,h,blocks,ore)
        printh("distributed " .. ore)
    end
end 

function oredistribution(y,w,h,blocks,ore) --function to distribute an ore across the map

    local orespr = {
        stone = 65,
        copper = 66,
        gold = 67,
        cobalt = 68,
        quartz = 69
    }

    while blocks[ore] > 0 do --until no more ore left to place    --blocks[ore] rarity values
        local mx,my = flr(rnd(w)), flr(rnd(h) + y) --generate a random x,y value within the layer
        
        if mget(mx,my) == 64 then --if selected block is currently dirt,
            mset(mx,my,orespr[ore]) --replace current block with ore
            blocks[ore] -= 1 --remove 1 from ore counter  
        end
    end

end


--currently unused but could be useful for a save function later on 
--or atleast put into its own cart as a library function for other games

--takes a given section of map starting from x,y with width and height and stores it to a table, overwrites section as empty
function storemap(x,y,w,h)
    printh("storing map")
    local m = {}  --table to hold map values

    for r = 0, w do --for each row
        for c = 0, h do --for each column
            add(m,mget(c,r)) --add the sprite value to the table
            mset(c,r,0) --clear that map square
        end
    end  --goes left to right, row by row

    printh("map stored")
    return m
end

--takes a stored map data table and applies it to the map at x,y for width, height
function loadmap(x,y,w,h,m)
    printh("generating map")
    local counter = 1 --iterate through table

    for r = 0, w do --reverse of the map reading function
        for c = 0, h do 
            mset(c,r,m[counter]) --sets map tiles 
            counter += 1 --iterate next table value
        end
    end

    printh("map generated")
end

