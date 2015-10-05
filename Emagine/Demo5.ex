include Emagine.e

clear_display(0)

without warning
without type_check
without trace

constant ant = 
 {{0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,8},
  {0,4,4,0,0,4,1,0},
  {4,4,4,4,4,4,4,0},
  {0,4,7,7,7,0,0,0},
  {0,7,0,7,0,7,0,0}}
  
constant ant2 = 
 {
  reverse({0,0,0,0,0,0,0,0}),
  reverse({0,0,0,0,0,0,0,8}),
  reverse({0,4,4,0,0,4,1,0}),
  reverse({4,4,4,4,4,4,4,0}),
  reverse({0,4,7,7,7,0,0,0}),
  reverse({0,7,0,7,0,7,0,0})
  }
  
constant gnat = 
{
{0,0,0,0},
{7,0,0,7},
{0,8,8,0},
{0,8,8,0}
}

constant ant_id = add_sprite(ant,0),
	 ant2_id = add_sprite(ant2,0),
	 length_pic = 8

atom frames,t,t2

frames = 0

t = time()
  
sequence squares
squares = repeat({0,0,0,0,0},500)

for counter = 1 to length(squares) do
    squares[counter][1] = rand(x2-10)
    squares[counter][2] = rand(y2-10)
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
    squares[counter][5] = ant_id
end for

atom x_pos      x_pos = 1
atom y_pos      y_pos = 1
atom numx       numx = 1
atom numy       numy = 1

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
	draw_sprite({floor(x_pos),floor(y_pos)},squares[counter][5])
	x_pos = x_pos + numx
	y_pos = y_pos + numy
	if x_pos >= x2-length_pic-1 then
	    numx = -1
	    if rand(2) = 1 then
		numy = -1
		numy = numy - ((rand(10)-5)/10)
	    end if
	    squares[counter][5] = ant2_id  
	elsif x_pos <= 1 then
	    numx = 1
	    if rand(2) = 1 then
		numy = 1
		numy = numy + ((rand(10)-5)/10)
		
	    end if
	    squares[counter][5] = ant_id 
	end if
	if y_pos >= y2-length_pic-1 then
	    numy = -1
	    if rand(2) = 1 then
		numx = -1
		numx = numx - ((rand(10)-5)/10)
		
		squares[counter][5] = ant2_id  
	    end if
	elsif y_pos <= 1 then
	    numy = 1
	    if rand(2) = 1 then
		numx = 1
		numx = numx + ((rand(10)-5)/10)
		
		squares[counter][5] = ant_id 
	    end if
	end if
	squares[counter][1] = x_pos  
	squares[counter][2] = y_pos  
	squares[counter][3] = numx  
	squares[counter][4] = numy  
    end for
    draw_display()
    clear_display(0)
    frames = frames + 1
end while

t2 = time()

puts(1,"FPS : "&sprint(frames/(t2-t)))







