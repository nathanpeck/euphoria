include Emagine.e
include image.e

without type_check
without profile
without warning

clear_display(0)

constant NUM_SQUARES = 4
integer color

color = 1

sequence pic

	 pic = {
		{color,color,color,color,color,color,color,color,color},
		{color,0,0,0,0,0,0,0,color},
		{color,0,0,0,0,0,0,0,color},
		{color,0,0,0,0,0,0,0,color},
		{color,0,0,0,0,0,0,0,color},
		{color,0,0,0,0,0,0,0,color},
		{color,0,0,0,0,0,0,0,color},
		{color,color,color,color,color,color,color,color,color}
	       }

pic = magnify(pic,5)

sequence pal,pal2
pal = repeat({0,0,0},256)
for counter = 1 to floor(256/3) do
    pal[counter] = {counter,0,0}
    pal[counter+floor(256/3)] = {0,counter,0}
    pal[counter+(floor(256/3)*2)] = {0,0,counter}
end for
set_palette(pal)
 
sequence squares
squares = repeat({0,0,0,0,0},NUM_SQUARES)
 
for counter = 1 to length(squares) do
    squares[counter][1] = 1
    squares[counter][2] = counter*length(pic)-length(pic)+2
    squares[counter][3] = 0
    squares[counter][4] = 1
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
 
 while get_key() = -1 do
    for counter = 1 to length(squares)  do
	x_pos = squares[counter][1]
	y_pos = squares[counter][2]
	numx = squares[counter][3]
	numy = squares[counter][4]
	if x_pos >= x2-length(squares[counter][5][1])-1 then
	    numx = -.5
	elsif x_pos <= 1 then
	    numx = .5
	end if
	if y_pos >= y2 - length(squares[counter][5])-1 then
	    numy = -1
	elsif y_pos <= 1 then
	    numy = 1
	end if
	x_pos = x_pos + numx
	y_pos = y_pos + numy
	sprite_fast({floor(x_pos),floor(y_pos)},squares[counter][5])
	squares[counter][1] = x_pos  
	squares[counter][2] = y_pos  
	squares[counter][3] = numx  
	squares[counter][4] = numy  
    end for
    draw_display()
end while
 

 
 
 
 





