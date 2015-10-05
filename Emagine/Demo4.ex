include Emagine.e
include image.e

without type_check
without profile
without warning

clear_display(0)

sequence pic

pic =          {
		{0,0,0,0,0,0,0,0},
		{0,0,20,20,20,20,0,0},
		{0,20,20,20,21,21,20,0},
		{0,20,20,20,20,21,20,0},
		{0,20,20,20,20,20,20,0},
		{0,0,20,20,20,20,0,0},
		{0,0,0,0,0,0,0,0}
	       }

pic = magnify(pic,1) --Change 1 to some other number, like 3
   
sequence squares                squares = repeat({0,0,0,0,0},200)
 
for counter = 1 to length(squares) do
    squares[counter][1] = 10
    squares[counter][2] = 10
    if rand(2) = 1 then
	squares[counter][3] = -1
    else
	squares[counter][3] = 1
    end if
    if rand(2) = 1 then
	squares[counter][4] = -1
    else
	squares[counter][4] = 1
    end if
    squares[counter][5] = pic
 end for
 
 atom x_pos                     x_pos = 1
 atom y_pos                     y_pos = 1
 atom numx                      numx = 1
 atom numy                      numy = 1

 while get_key() != 13   do
    for counter = 1 to length(squares)  do
	x_pos = squares[counter][1]
	if x_pos = 0  then
	    x_pos = 1
	end if
	y_pos = squares[counter][2]
	if y_pos = 0 then
	    y_pos = 1
	end if
	numx = squares[counter][3]
	numy = squares[counter][4]
	display_bmp({x_pos,y_pos},squares[counter][5])
	x_pos = x_pos + numx
	y_pos = y_pos + numy
	if x_pos >= x2-length(squares[counter][5][1])-1 then
	    numx = -1
	    if rand(2) = 1 then
		numy = -1
	    end if
	elsif x_pos <= 1 then
	    numx = 1
	    if rand(2) = 1 then
		numy = 1
	    end if
	end if
	if y_pos >= y2 - length(squares[counter][5])-1 then
	    numy = -1
	    if rand(2) = 1 then
		numx = -1
	    end if
	elsif y_pos <= 1 then
	    numy = 1
	    if rand(2) = 1 then
		numx = 1
	    end if
	end if
	squares[counter][1] = x_pos  
	squares[counter][2] = y_pos  
	squares[counter][3] = numx  
	squares[counter][4] = numy  
    end for
    draw_display()
    clear_display(0)
end while
 
 
 
 
 





