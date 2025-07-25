--file for all shop related things

function shopinit()

    shop = {
        spr = 24, --shop sprite, cycles 24 and 25 or 26 and 27
        animtimer = 0, --change sprite every 5 frames
        x = robot.x, --stays above robot 
        y = robot.y - 24, --3 blocks above
        open = false, --shop menu open state
        itemlist={"energy","ladders","inventory","falldist"},
        currentitem = "energy", -- the upgrade to show
        itemcounter = 1 --counter for the itemlist
    }
    upgrades = {
        energy = {
            current = 1, --the current level
            next = 2, --the next level, is changed to max if current is 5
            cost = 500, --cost of current upgrade
            costinc = 500, --how much is added to cost for the next upgrade
            statinc = 50, --how much is added to the stats.max for given stat
        },
        ladders = {
            current = 1,
            next = 2,
            cost = 500,
            costinc = 500,
            statinc = 5,
        },
        inventory = {
            current = 1,
            next = 2,
            cost = 500,
            costinc = 500,
            statinc = 5,
        },
        falldist = {
            current = 1,
            next = 2,
            cost = 500,
            costinc = 500,
            statinc = 2,
        }
    }

end  

function shopupdate()

    shop.animtimer += 1 --iterate animation timer 

    --update shop sprite
    if shop.animtimer % 10 == 0 then --every 5 frames
        if shop.spr == 24 then shop.spr = 25 else shop.spr = 24 end --switch sprite
    else
        if shop.animtimer > 1000 then shop.animtimer = 0 end --reset to prevent a too large number
    end 

    if btnp(4) and not shop.open then --open shop menu
        shop.open = true 
        printh("shop opened") 
    elseif shop.open and btnp(4) then --close shop menu
        shop.open = false 
        printh("shop closed") 
    end 
    

    printh(shop.animtimer)
    printh(shop.spr)

end

function shopdraw()

    --values for the corners of the shop menu
    local topx, topy = robot.x + 16, robot. y - 48
    local bottomx, bottomy = topx + 48, topy + 48
    local width, height = 48, 48

    --draw main menu section
    rect(topx,topy,bottomx,bottomy,11) --green border 
    rectfill(topx+1,topy+1,bottomx-1,bottomy-1,0) --black background fill 
    line(topx,topy + 8, topx + width, topy + 8, 11) --first section
    print("upgrade", topx+11,topy+2,6) --title text
    spr(13,topx+2,topy + 2) --left arrow
    spr(13,topx+39,topy + 2,1,1,true) --right arrow

    drawpage(shop.currentitem,topx,topy)

end

function drawpage(upgrade,x,y) --draw the text in the shop page for an upgrade - could potentially be optimised with a separate centering function?
    local mid = x + 24 --middle point for centering texts
    local string = upgrade --string stored for the length calculation
    print(string, mid - (#string * 2), y + 10, 6) --upgrade name
    if upgrades[upgrade].current == 5 then string = "current: max" else string = "current: " .. upgrades[upgrade].current end
    print(string, mid - (#string * 2), y + 16, 6) --current level
    string = "next: " .. upgrades[upgrade].next 
    print(string, mid - (#string * 2), y + 22, 6) --next level
    string = "cost: " .. upgrades[upgrade].cost
    print(string, mid - (#string * 2), y + 28, 6)--upgrade cost
    string = "buy ❎"
    print(string, mid - (#string * 2), y + 38, 6) 

end

function shopcontrols()

    if btnp(2) or btnp(3) then --up/down - close shop 
        shop.open = false 
        printh("shop closed")
    end 

    if btnp(1) then --right - scroll right
        if shop.itemcounter == 4 then 
            shop.itemcounter = 1
        else shop.itemcounter += 1 end 
        shop.currentitem = shop.itemlist[shop.itemcounter]
    end

    if btnp(0) then --left - scroll left
        if shop.itemcounter == 1 then 
            shop.itemcounter = 4
        else shop.itemcounter -= 1 end 
        shop.currentitem = shop.itemlist[shop.itemcounter]
    end

    if btnp(5) then --X - select item if not max and has enough money
        if upgrades[shop.currentitem].current < 5 then 
            if stats.current.money > upgrades[shop.currentitem].cost then
                shopupgrade(shop.currentitem)
            else printh("not enough money") end --maybe add a visual indicator of not enough money
        end
    end

end

--function to upgrade a stat
function shopupgrade(upgrade)
    printh("upgrading " .. upgrade)

    stats.current.money -= upgrades[upgrade].cost --spend money

    if upgrade == "energy" then --increase the stats.max value for the given upgrade
        stats.max.energy += upgrades[upgrade].statinc 
    elseif upgrade == "ladders" then 
        stats.max.ladders += upgrades[upgrade].statinc 
    elseif upgrades == "inventory" then 
        stats.max.inventoryitems += upgrades[upgrade].statinc 
    elseif upgrade == "falldist" then 
        stats.max.falldist += upgrades[upgrade].statinc
    end

    --increase relevant values
    upgrades[upgrade].current += 1
    upgrades[upgrade].next += 1
    upgrades[upgrade].cost += upgrades[upgrade].costinc 
    if upgrades[upgrade].next == 6 then
        upgrades[upgrade].next = "X" 
        upgrades[upgrade].cost = "X"
    end --set next to a 'nil' when maxxed

end