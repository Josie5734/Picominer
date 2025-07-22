--file for all shop related things

function shopinit()

    shop = {
        spr = 24, --shop sprite, cycles 24 and 25 or 26 and 27
        animtimer = 0, --change sprite every 5 frames
        x = robot.x, --stays above robot 
        y = robot.y - 24, --3 blocks above
        open = false --shop menu open state
    }

end  

function shopupdate()

    --update shop sprite
    if not robot.underground then
        if shop.animtimer % 5 == 0 then --every 5 frames
            if shop.spr == 24 then shop.spr = 25 else shop.spr = 24 end --switch sprite
        end 
        shop.animtimer += 1 --iterate animation timer 

        if btnp(4) then shop.open = true printh("shop opened") end 
    end

end

function shopdraw()

    --values for the corners of the shop menu
    local topx, topy = robot.x + 16, robot. y - 48
    local bottomx, bottomy = topx + 48, topy + 48

    --draw main menu section
    rect(topx,topy,bottomx,bottomy,11)
    rectfill(topx+1,topy+1,bottomx-1,bottomy-1,0)
    --layout for shop
    --is going to be on the right
    --robot has 8 tiles to the right - make shop 6 wide with 1 on either side
    --an have 3 options shown at once
    --vertical height undecided
    --may need some contrasting border colors if the bottom goes over the dirt layer

    --upgrades to be listed:
        --battery, inventory, ladders&supports, pointer to jelpi block

end



function shopcontrols()

    if btnp(0) or btnp(1) then --left/right/Z - close shop 
        shop.open = false 
        printh("shopclosed")
    end

    if btnp(2) then --up - scroll up 
        --scroll up
    end

    if btnp(3) then --down - scroll down
        --scroll down
    end

    if btnp(5) then --X - select item
        --select
    end

end