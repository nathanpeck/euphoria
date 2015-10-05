include Escreen.e
include image.e

without type_check
without profile
without warning

constant color = 100

sequence img
img = 
{
{color,color},
{color,color}
}

sequence pal

pal = repeat(0,256)

for counter = 1 to length(pal) do
    pal[counter] = {counter-1,0,0}
end for

set_palette(pal)

clear_display(0) --You must first clear the screen buffer.

atom t,t2,fps,frames
atom display,var,v2,x,y,r

x = x2/2
y = y2

v2 = 1
var = 20

display = 1
frames = 0

r = 1

set_palette(floor(pal/var*6))
t = time()
while get_key() != 13 do
    for counter = 1 to y2 do
	set_pixel(repeat(counter,x2),{1,counter}) --Set a pixel
    end for
    if r = 1 then
	for counter = 1 to length(pal) do
	    pal[counter] = {counter-1,counter-1,0}
	end for
    elsif r = 2 then
	for counter = 1 to length(pal) do
	    pal[counter] = {counter-1,0,counter-1}
	end for
    elsif r = 3 then
	for counter = 1 to length(pal) do
	    pal[counter] = {0,counter-1,0}
	end for
    elsif r = 4 then
	for counter = 1 to length(pal) do
	    pal[counter] = {counter-1,0,0}
	end for
    elsif r = 5 then
	for counter = 1 to length(pal) do
	    pal[counter] = {0,0,counter-1}
	end for
    elsif r = 6 then
	for counter = 1 to length(pal) do
	    pal[counter] = {counter-1,counter-1,counter-1}
	end for
    elsif r = 7 then
	for counter = 1 to length(pal) do
	    pal[counter] = {0,counter-1,counter-1}
	end for
    end if
    if remainder(frames,100) = 0 then
	r = r + 1
	if r = 8 then
	    r = 1
	end if
    end if
    set_palette(floor(pal/var*6))
    draw_display() --Draw the display
    frames = frames + 1
end while
t2 = time()

fps = frames/(t2-t)

puts(1,"FPS: "&sprint(fps))


