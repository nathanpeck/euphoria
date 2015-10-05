include Emagine.e

without type_check
without profile
without warning

clear_display(0)

constant NUM_SQUARES = 1
constant color = 7 --Try 1 here for a amazing fractal!
		   --Try other numbers too.  I think 1-7 are the best.
sequence pic

pic = repeat(repeat(color,4),4) --Try other designs that aren't a solid block!

pic = magnify(pic,5)

sequence pal,pal2
pal = repeat({0,0,0},256)
for counter = 1 to floor(256/3) do
    pal[counter] = {counter,0,0}
    pal[counter+floor(256/3)] = {0,counter,0}
    pal[counter+(floor(256/3)*2)] = {0,0,counter}
end for
pal2 = repeat({0,0,0},256)
for counter = 1 to floor(256/3) do
    pal2[counter] = {0,counter,counter}
    pal2[counter+floor(256/3)] = {counter,counter,0}
    pal2[counter+(floor(256/3)*2)] = {counter,0,counter}
end for
set_palette(pal)
 
sequence squares
squares = repeat({0,0,0,0,0},NUM_SQUARES)
 
for counter = 1 to length(squares) do
    squares[counter][1] = 1
    squares[counter][2] = 1
    if counter = 1 then
	squares[counter][3] = -1
	squares[counter][4] = 1
    elsif counter = 2 then
	squares[counter][3] = 1
	squares[counter][4] = -1
    elsif counter = 3 then
	squares[counter][3] = 1
	squares[counter][4] = 1
    elsif counter = 4 then
	squares[counter][3] = -1
	squares[counter][4] = -1
    else
	squares[counter][3] = 1
	squares[counter][4] = 0
    end if
    squares[counter][5] = pic
 end for
 
 atom x_pos,y_pos,numx,numy,c
 numx = 1
 numy = 1
 x_pos = 1
 y_pos = 1
 c = 0
 
 procedure wait(atom t2)
    atom t
    t = time()
    while t+t2 > time() do
	
    end while
 end procedure
 
 while get_key() = -1   do
    for counter = 1 to length(squares)  do
	x_pos = squares[counter][1]
	y_pos = squares[counter][2]
	numx = squares[counter][3]
	numy = squares[counter][4]
	sprite_fast({x_pos,y_pos},squares[counter][5])
	x_pos = x_pos + numx
	y_pos = y_pos + numy
	if x_pos >= x2-length(squares[counter][5][1])-1 then
	    numx = -1
	elsif x_pos <= 1 then
	    numx = 1
	end if
	if y_pos >= y2 - length(squares[counter][5])-1 then
	    numy = -1
	elsif y_pos <= 1 then
	    numy = 1
	end if
	squares[counter][1] = x_pos  
	squares[counter][2] = y_pos  
	squares[counter][3] = numx  
	squares[counter][4] = numy  
    end for
    
    --Uncommenting the below gives an interesting effect!
    
    --c = c + 1
    --if c = 3000 then
	--set_palette(pal2)
	--c = 0
    --elsif c = 1500 then
	--set_palette(pal)
    --end if
    draw_display()
end while
 

 
 
 
 





