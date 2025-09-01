--this is a credits screen that can be included in all my games, intended to be accessed via the in-built pico menu

--this goes in _init to initialise credit menu
function creditsmenuinit()
    creditsmenu = false --state for showing menu or not
    menuitem(1,"credits",function() creditsmenu = true end) --add the menu option to the pause menu
end

--specific implementation of using the state for the menu is done on per game basis 

--this draws the menu, goes in draw
function creditsmenudraw()

    --variable things for who is credited, changed per cart
    local gamename = "picominer"
    local credits = "coding,art,music" --credit for me
    local sydney, sydneycredits = true, "art,logo design" --true if sydney credited, credit list for sydney

    local x,y = 3,3 --text ypos
    local line = 6 --line size for adding to next line
    local color = 7 --text color

    camera(0,0)--set camera to 0,0 

    cls() --set background color

    --text
    centerprint(gamename,64,y,color)
    y+=line*2

    centerprint(" is a game made with love by:",64,y,color)
    y+=line*2

    --josie credit
    print("josie:",x,y,color)
    y+=line
    print(" " .. credits,x,y,color)
    y+=line*2

    --sydney credit
    if sydney then 
        print("sydney:",x,y,color)
        y+=line
        print(" " .. sydneycredits,x,y,color)
    end
    y+=line*2

    --press to exit text
    print("press any button",x,104,color)
    print("to exit",x+18,110,color)

    --github link
    print("github.com/josie5734",x,119,color)

    --draw trans flag (20x20)
    rectfill(93,107,123,110,14)
    rectfill(93,103,123,106,12)
    rectfill(93,111,123,114,7)
    rectfill(93,115,123,118,14)
    rectfill(93,119,123,123,12)
end

--prints text in the center of the screen
function centerprint(string,middle,y,color)
    print(string, middle-(#string*2),y,color)
end