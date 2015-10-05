I just decided to release this little work of mine to demonstrate a 
way to do fast sprites.  I used an old graphics library of
mine called Escreen, recently remodeled and released as Emagine.

The procedure I optimized was draw_sprite().
You can see the results by opening new.ex and old.ex

OLD

--This procedure draws a sprite from the list into a buffer.
global procedure draw_sprite_buffer(integer id_b,sequence x_y, integer id)
    sequence data
    integer x,y
    
    x = x_y[1] --This is
    y = x_y[2] --probably faster.
    
    data = sprites[id]
    for line = 1 to length(data) do
	for solid_block = 1 to length(data[line]) do
            --the following line is a real mess!
	    set_buffer_pixel(id_b,data[line][solid_block][2],{x+data[line][solid_block][1],y+line})
	end for
    end for
end procedure

NEW

--This procedure draws a sprite from the list.
global procedure draw_sprite(sequence x_y, integer id)
    sequence data,ln
    integer x,y,ox,l
    atom m
    
    ox = x_y[1]  --Don't use x_y directly.
    y = x_y[2]   --Doing a subscript every loop will affect speed.
    
    m = buff+(x2*y) --Caluculate a base position and then add the
                    --screen width on to it on each loop instead of
                    --recalculating with new coordinates!
    
    data = sprites[id]
    for li = 1 to length(data) do

	ln = data[li] --Do as few subscripts as possible.

	for sb = 1 to length(ln) do
	    x = ox + ln[sb][1]-1 --MUCH faster
	    poke(m+x,ln[sb][2]) --Rather than calling an external procedure, poke directly.
                                --The external procedure must recalculate a position every time
                                --you call it. Your for loop can be a very powerful tool to 
                                --speed your code up
	end for

	m += x2 --I have a base memory address.  Now I add on the
                --screen width to skip down one line, instead of
                --recalculating a new address with new coordinates

    end for
end procedure

I hope you find this little lesson in speeding up graphics code
handy.
