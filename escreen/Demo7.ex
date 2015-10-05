include Escreen.e

without type_check
without profile
without warning

clear_display(0)

sequence pic_index,keys
sequence wall_img,wall_pal

object old
object pic

atom extent_x
atom extent_y
atom t
atom t2
atom frames
atom x_pos
atom y_pos
atom numx
atom numy
atom moving_up
atom moving_right
atom moving_down
atom moving_left
atom scroll

integer key
integer still_running
integer x
integer y

extent_x = 256*5
extent_y = 256*5

wall_img = load_img("wall.img")     --Load the back image
wall_pal = load_pal("wall.pal",1)   --Load the palette

constant backdrop = create_backbuffer({extent_x,extent_y}) --Create the backbuffer

if backdrop = -1 then
    puts(1,"Not enough free memory!")
end if

if compare(wall_img,-1) = 0 or compare(wall_pal,-1) = 0 then
    puts(1,"Error loading!")
    abort(0)
end if

wall_pal[17] = {0,0,0}  --17 is the screen border color.
			--Comment this out for an ugly green border!
			
wall_pal = floor(wall_pal/4) --Scale the palette

set_palette(wall_pal) --Set it

for tile_x = 1 to 4 do
    for tile_y = 1 to 4 do
	buffer_display(backdrop,{(tile_x-1)*256,(tile_y-1)*256},wall_img) --Tile the image
    end for
end for

--Set some needed values
frames = 0
   
scroll = 50 --This is the distance to scroll with each key press.
	    --Change it for some interesting effects.

numx = 1
numy = 1
x_pos = 1
y_pos = 1
x = 1
y = 1
moving_up = 0
moving_down = 0
moving_right = 0
moving_left = 0
 
still_running = 1
 
procedure main()
    t = time()
    --The main loop
    while still_running  = 1 do
	key = get_key()
	if key = 333 then
	    moving_right = scroll
	elsif key = 331 then
	    moving_left = scroll
	elsif key = 328 then
	    moving_up = scroll
	elsif key = 336 then
	    moving_down = scroll
	elsif key = 13 then
	    still_running = -1
	    exit
	end if
	if moving_right then
	    moving_right = moving_right - 1
	    x = x + 1
	end if
	if moving_down then
	    moving_down = moving_down - 1
	    y = y + 1
	end if
	if moving_left then
	    moving_left = moving_left - 1
	    x = x - 1
	end if
	if moving_up then
	    moving_up = moving_up - 1
	    y = y - 1
	end if
	if x = 0 then
	    x = 1
	end if
	if y = 0 then
	    y = 1
	end if
	if x = extent_x-x2-256 then
	    x = extent_x-x2-256-1
	end if
	if y = extent_y-y2-256 then
	    y = extent_y-y2-256-1
	end if
	copy_to_display(backdrop,{x,y}) --Copy to the screen
	draw_display() --Draw it.
	frames = frames + 1
    end while
end procedure 

main()
 
t2 = time()
atom time2
time2 = t2 - t
puts(1,sprint(frames/time2)&" frames per second")

 
 
 
 





