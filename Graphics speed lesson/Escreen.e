--A simple sprite engine.  It does no clipping, so it's up to you to prevent
--mistakes.

include graphics.e
include machine.e
include file.e
include ports.e

without type_check
without profile
without warning

atom result
result = graphics_mode(19)

if result = -1 then
    puts(1,"Your graphics card does not support mode 19!")
    while get_key() = -1 do
	
    end while
    if graphics_mode(-1) then end if
    abort(1)
end if

global integer rows,cols,x1,y1,x2,y2,a
global atom e
global atom buff
global sequence vc
global sequence buffers,sprites
buffers = {}
sprites = {}

vc = video_config() --Get the needed video configuration
x1 = 1
y1 = 1
x2 = vc[VC_XPIXELS]
y2 = vc[VC_YPIXELS]

e = x2*y2

cols=x2
rows=y2
buff=allocate(x2*y2)
a=#A0000  

--The type graphics_point
global type graphic_point(sequence p)
    return length(p) = 2 and p[1] >= 1 and p[2] >= 1 and p[1] <= x2 and p[2] >= y2
end type

--Set a pixel or a row of pixels on the main virtual screen
global procedure set_pixel(object s, graphic_point x_y)
    atom x,y
    x = x_y[1]
    y = x_y[2]
    poke(buff+(x2*y)+x-1,s) --Plot the position in the buffer and set it
end procedure

--Draw the main buffer
global procedure draw_display()
    mem_copy(a,buff,e) --Quick and fast
end procedure

--Clear the buffer
global procedure clear_display(atom color)
    mem_set(buff,color,e)
end procedure

--This procedure magnifies an image.
global function magnify(sequence img, atom size)
    sequence done
    done = repeat(repeat(0,length(img[1])*size),length(img)*size)
    for y = 1 to length(img) do
	for x = 1 to length(img[y]) do
	    for enlarge_y = 1 to size do
		for enlarge_x = 1 to size do
		    done[(y*size)+enlarge_y-size][(x*size)+enlarge_x-size] = img[y][x]
		end for
	    end for
	end for
    end for
    return done
end function

--This procedure draws a sprite from the list.
global procedure draw_sprite(sequence x_y, integer id)
    sequence data,ln
    integer x,y,ox,l
    atom m
    
    ox = x_y[1]
    y = x_y[2] --faster than doing the subscripts every time!
    
    m = buff+(x2*y)
    
    data = sprites[id]
    for li = 1 to length(data) do
	ln = data[li]
	for sb = 1 to length(ln) do
	    x = ox + ln[sb][1]-1
	    poke(m+x,ln[sb][2])
	end for
	m += x2
    end for
end procedure

--This procedure adds a sprite to Escreens internal list.
global function add_sprite(sequence img, integer clear)
    integer c,x2,pos1
    sequence done
    done = repeat({},length(img))
    for y = 1 to length(img) do
	x2 = -1
	for x = 1 to length(img[y]) do
	    c = img[y][x]
	    if c = clear then --If the color is clear...
		if x2 = 1 then
		    done[y] = append(done[y],{pos1,img[y][pos1..x-1]}) --Add data
		    x2 = -1
		end if
	    else              --If the color is not clear...
		if x2 = -1 then
		    x2 = 1
		    pos1 = x
		else
		    --Don't reset the position
		end if
	    end if
	end for
	if x2 = 1 then
	    done[y] = append(done[y],{pos1,img[y][pos1..length(img[y])]}) --Add data
	end if
    end for
    sprites = append(sprites,done) --Add the sprite data to the list
    return length(sprites) --Return the index number
end function

--Bitmap I/O operations
atom mem0, mem1, mem2, mem3
sequence memseq
mem0 = allocate(4)
mem1 = mem0 + 1
mem2 = mem0 + 2
mem3 = mem0 + 3
memseq = {mem0, 4}

----------------------------------------------------------
--These two functions are modifications on database.e's---
function get4bmp(integer where)                         --
    poke(mem0, getc(where))                             --  
    poke(mem1, getc(where))                             --
    poke(mem2, getc(where))                             --
    poke(mem3, getc(where))                             --
    return peek4u(mem0)                                 --
end function                                            --
							--
procedure puts4bmp(atom where,atom x)                   --
    poke4(mem0, x) -- faster than doing divides etc.    --
    puts(where, peek(memseq))                           --
end procedure                                           --
							--
----------------------------------------------------------

--Load an image
global function load_img(sequence name)
    sequence result
    atom char
    atom fn
    atom x5
    atom y5
    fn = open(name,"r")
    if fn = -1 then
	return fn
    end if
    char = getc(fn)
    if char = 'I' then --This part...
	char = getc(fn)
	if char = 'M' then --...checks to see...
	    char = getc(fn)
	    if char = 'G' then --...if its an img file.
		y5 = get4bmp(fn)
		x5 = get4bmp(fn)
		result = repeat(repeat(0,x5),y5)
		for y = 1 to y5 do
		    for x = 1 to x5 do
			result[y][x] = getc(fn)
		    end for
		end for
	    else return -1
	    end if
	else return -1
	end if
    else return -1
    end if
    close(fn)
    return result
end function

--Load a palette
global function load_pal(sequence name,integer num)
    sequence success
    atom char
    atom fn
    sequence current_rgb
    current_rgb = {}
    success = {}
    fn = open(name,"r")
    if fn = -1 then
	return fn
    end if
    char = getc(fn)
    if char = 'P' then
	char = getc(fn)
	if char = 'A' then
	    char = getc(fn)
	    if char = 'L' then
		for color = 3 to (256*3)+3 by 3 do
		    for rgb = 1 to 3 do
			char = seek(fn,color+rgb-num)
			if char = -1 then
			    return char
			end if
			char = getc(fn)
			current_rgb = append(current_rgb,char)
			if rgb = 3 then
			    success = append(success,current_rgb)
			    current_rgb = {}
			end if
		    end for
		end for
	    else return -1
	    end if
	else return -1
	end if
    else return -1
    end if
    close(fn)
    return success
end function

--This sets the palette specified.
global procedure set_palette(sequence pal)
    for c = 1 to 256 do
	Output(c-1,#3C8)
	Output(pal[c][1],#3C9)
	Output(pal[c][2],#3C9)
	Output(pal[c][3],#3C9)
    end for
end procedure

