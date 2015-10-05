include Emagine.e

without type_check
without profile
without warning

clear_display(0) --You must first clear the screen buffer.

sequence pal        pal = repeat(0,256)

for counter = 1 to length(pal) do
    pal[counter] = {counter-1,counter-1,0}
end for

sequence old_pal    old_pal = pal

atom r              r = 1
atom frames         frames = 0

integer var         var = 20
integer update      update = 0

set_palette(floor(pal/var*6))

for counter = 0 to y2-1 do
    set_pixel(repeat(counter,x2),{0,counter}) --Set a pixel
end for

draw_display()

while get_key() != 13 do
    if r = 1 then
	update = 1
	old_pal = pal
	for counter = 1 to length(pal) do
	    pal[counter] = {counter-1,counter-1,0}
	end for
    elsif r = 2 then
	update = 1
	old_pal = pal
	for counter = 1 to length(pal) do
	    pal[counter] = {counter-1,0,counter-1}
	end for
    elsif r = 3 then
	update = 1
	old_pal = pal
	for counter = 1 to length(pal) do
	    pal[counter] = {0,counter-1,0}
	end for
    elsif r = 4 then
	update = 1
	old_pal = pal
	for counter = 1 to length(pal) do
	    pal[counter] = {counter-1,0,0}
	end for
    elsif r = 5 then
	update = 1
	old_pal = pal
	for counter = 1 to length(pal) do
	    pal[counter] = {0,0,counter-1}
	end for
    elsif r = 6 then
	update = 1
	old_pal = pal
	for counter = 1 to length(pal) do
	    pal[counter] = {counter-1,counter-1,counter-1}
	end for
    elsif r = 7 then
	update = 1
	old_pal = pal
	for counter = 1 to length(pal) do
	    pal[counter] = {0,counter-1,counter-1}
	end for
    end if
    if remainder(frames,100) = 0 then
	r = rand(7)
    end if
    if update = 1 then
	set_palette(floor(pal/var*6))
	update = 0
    end if
    frames = frames + 1
end while

