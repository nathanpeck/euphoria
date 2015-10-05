include Emagine.e
include image.e
include retrace.e

without type_check
without profile
without warning

clear_display(0)

constant gravity = .04 
constant frequency = 80

atom t
atom t2
atom time2
atom frames
integer counter
frames = 1
   
sequence pix

pix = {{0,0,0,0,0,0}}

sequence pal

pal = repeat({0,0,0},256)
for c = 1 to floor(256/3) do
    pal[c] = {c,0,0}
    pal[c+floor(256/3)] = {0,c,0}
    pal[c+(floor(256/3)*2)] = {0,0,c}
end for

pal[17] = {0,0,0} --17 is the border color.

set_palette(pal)

procedure explode(sequence location)
    integer c,r
    integer x3
    integer y3
    for counter = 1 to 100 do
	sound(counter)
	r = rand(3)
	if r = 1 then
	    c = 65
	elsif r = 2 then
	    c = 150
	else
	    c = 236
	end if
	pix = append(pix,{c,(rand(400)-200)/100,(rand(400)-200)/100,location[1],location[2],floor(256/3)-20})
	if pix[length(pix)][2] = 0 then
	    pix[length(pix)][2] = -1
	end if
	if pix[length(pix)][3] = 0 then
	    pix[length(pix)][3] = -1
	end if
    end for
    sound(0)
end procedure
   
procedure remove(integer num,integer length_)
    if num = 1 then
	pix = pix[2..length(pix)]
    elsif num = length_ then
	pix = pix[1..length(pix)-1]
    else
	pix = pix[1..num-1]&pix[num+1..length(pix)]
    end if
    if num > 1 then
	counter = counter - 1
    end if
end procedure

procedure run_explosions()
    integer not_done
    counter = 0
    not_done = 1
    while not_done = 1 do
	counter = counter + 1
	if counter >= length(pix) then
	    not_done = -1
	else
	    pix[counter][6] = pix[counter][6] - 1
	    if pix[counter][6] = -1 then
		remove(counter,length(pix))
	    else
		pix[counter][5] = pix[counter][5] + pix[counter][2]
		pix[counter][4] = pix[counter][4] + pix[counter][3]
		if pix[counter][4] <= 2 then
		    remove(counter,length(pix))
		elsif pix[counter][4] >= x2-2 then
		    remove(counter,length(pix))
		elsif pix[counter][5] <= 2 then
		    remove(counter,length(pix))
		elsif pix[counter][5] >= y2-2 then
		    remove(counter,length(pix))
		else
		    if pix[counter][1] = 0 then
			remove(counter,length(pix))
		    else
			set_pixel(floor(pix[counter][1]),{floor(pix[counter][4]),floor(pix[counter][5])})
		    end if
		end if
		pix[counter][1] = pix[counter][1] - 1
		pix[counter][2] = pix[counter][2] + gravity
	    end if
	end if
    end while
end procedure

atom pos
pos = 0

--Get things started!
explode({rand(x2-100)+50,rand(y2-100)+50}) --Keep them in a good area.
if rand(10) = 1 then
    explode({rand(x2-100)+50,rand(y2-100)+50}) --Keep them in a good area.
end if

t = time()
while get_key() != 13 do
  if rand(frequency) = rand(frequency) then
      explode({rand(x2-100)+50,rand(y2-100)+50}) --Keep them in a good area.
      if rand(10) = 1 then
	  explode({rand(x2-100)+50,rand(y2-100)+50}) --Keep them in a good area.
      end if
  end if
  run_explosions()
  draw_display() --Display the graphics
  clear_display(0) --Clear the screen
  call(retrace_vertical) --Wait for a retrace
  frames = frames + 1
end while
t2 = time()

time2 = frames/(t2-t)
 
puts(1,"FPS: "&sprint(time2))

fade(pal,repeat({0,0,0},256),1)
 
 
 
 





