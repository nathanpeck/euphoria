include Emagine.e
include keyread.e
include objpos.e

--Only a few frames per second faster.
without type_check
without profile
without warning

--Easy use of get_keys()
global function get_key()
    sequence y
    y = get_keys()
    if compare(y,{}) = 0 then
	return -1
    else
	return y[1]
    end if
end function

clear_display(0)

sequence pic_index,keys

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

extent_x = 64*20
extent_y = 64*20

sequence tile1,tile2,spr1,spr2,pal
integer sid1,sid2
sequence rep1,rep2

tile1 = load_img("tile1.img")     --Load the back image
tile2 = load_img("tile2.img")     --Load the back image
spr1 = load_img("pcs1.img")     --Load the back image
spr2 = load_img("pcs2.img")     --Load the back image

sid1 = add_sprite(spr1,spr1[1][1])
sid2 = add_sprite(spr2,spr2[1][1])

pal = load_pal("Demo13.pal",1)   --Load the palette

constant backdrop = create_backbuffer({extent_x,extent_y}) --Create the backbuffer

if backdrop = -1 then
    puts(1,"Not enough free memory!")
end if

pal[17] = {0,0,0}  --17 is the screen border color.
			--Comment this out for an ugly green border!
			
pal = floor(pal/4) --Scale the palette

set_palette(pal) --Set it

for tile_x = 1 to extent_y/64 do
    for tile_y = 1 to extent_x/64 do
	if rand(2) = 1 then
	    buffer_display(backdrop,{(tile_x-1)*64,(tile_y-1)*64},tile1) --Tile the image
	else
	    buffer_display(backdrop,{(tile_x-1)*64,(tile_y-1)*64},tile2) --Tile the image
	end if
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
 
integer rx,ry,rxa,rya
integer p

p = 0
rx = 100
ry = 100
rxa = 1
rya = 1

clear_display(255)

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
	elsif key = 1 then
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
	
	--If don't do this the other window moves way to fast!
	if remainder(frames,2) = 0 then
	    rx = rx + rxa
	    ry = ry + rya
	end if
	
	if rx = 0 then
	    rx = 1
	    rxa = 1
	end if
	if ry = 0 then
	    ry = 1
	    rya = 1
	end if
	if rx = extent_x-x2-256 then
	    rx = extent_x-x2-256-1
	    rxa = -1
	    if rand(2) = 1 then
		rxa = 1
	    end if
	end if
	if ry = extent_y-y2-256 then
	    ry = extent_y-y2-256-1
	    rya = -1
	    if rand(2) = 1 then
		rxa = 1
	    end if
	end if
	
	rep1 = get_buffer(backdrop,{rx+(75-16),ry+(100-16)},{32,32})
	rep2 = get_buffer(backdrop,{x+(75-16),y+(100-16)},{32,32})
	
	draw_sprite_buffer(backdrop,{rx+(75-16),ry+(100-16)},sid1)
	draw_sprite_buffer(backdrop,{x+(75-16),y+(100-16)},sid2)
	
	copy_window(backdrop,{x,y},{150,200},{0,0}) --Copy to the screen
	copy_window(backdrop,{rx,ry},{150,200},{x2-150,0}) --Copy to the screen
	
	draw_display() --Draw it.
	
	buffer_display(backdrop,{rx+(75-16),ry+(100-16)},rep1)
	buffer_display(backdrop,{x+(75-16),y+(100-16)},rep2)
	
	if in_region({rx+(75-16),ry+(100-16)},{x+(75-16),y+(100-16)},40) = 1 then
	    if p = 0 then
		pal[256] = {255,255,255}
		set_palette(pal)
		p = 1
	    end if
	else
	    if p = 1 then
		pal[256] = {0,0,0}
		set_palette(pal)
		p = 0
	    end if
	end if
	
	frames = frames + 1
    end while
end procedure 

main()
 
t2 = time()
atom time2
time2 = t2 - t
puts(1,sprint(frames/time2)&" frames per second")

 
 
 
 





