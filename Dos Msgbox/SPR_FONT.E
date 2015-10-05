include image.e
include spr_load.e

--  << spr_font.e >>  -- graphic text using spred fonts
--   Colin Taylor  71630.1776@compuserve.com
--   version 1.1  3/24/97, 8/14/97

integer font   -- selected font
integer bold, italic, hlight, shadow, underline  -- char attribute flags
integer paper  -- print attribute flags
integer bx, kx, sx, sy  -- char offsets
sequence ix  -- italic offsets
integer te_color, hl_color, sh_color, pa_color  -- print colors
integer x_pos, y_pos, l_margin, height  -- print position
sequence params  -- char attribute parameters

-- default attributes
bold = 0
italic = 0
hlight = 0
shadow = 0
underline = 0
paper = 0
-- default colors
te_color = 0
hl_color = 15
sh_color = 8
pa_color = 7
-- default print position
x_pos = 0
y_pos = 0
l_margin = 0
-- default print parameters
params = {1,    -- bold strike offset
      1,    -- shadow offset: right
      1,    -- shadow offset: down
      0,    -- reserved
      1,    -- kerning space width
      1,    -- vertical space between lines
      0,    -- extra underline drop
      1}    -- underline thickness
-- char offsets
bx = params[1]*bold
kx = params[5]
sx = params[2]*shadow
sy = params[3]*shadow
ix = {0}
	  
procedure sf_char(integer char)
-- displays a single text character
    integer xo, yo, h, w, x, y
    sequence bma, bmb, bmh, bms, back, front
    w = WS[font][char]
    if char <= NS[font] then
	if w > 0 then
	    h = HS[font][char]
	    xo = XS[font][char]
	    yo = YS[font][char]
	    bma = IS[font][char][1]
	    bmb = IS[font][char][2]
	    if bold or shadow then
		bma = bm_resize(bma, {0, 0}, {bx+sx, sy}, 0)
		bmb = bm_resize(bmb, {0, 0}, {bx+sx, sy}, 1)
	    end if
	    if bold then
		bma = bma or bm_shift(bma, {bx, 0}, 0)
		bmb = not bma
	    end if
	    if italic then
		bma = bm_warp(bma, ix, 0)
		bmb = not bma
	    end if
	    front = bma*te_color
	    if hlight then
		bmh = bma and not bm_shift(bma, {1, 1}, 0)
		front = front*bma*not bmh+bmh*hl_color
	    end if
	    if shadow then
		bms = bm_shift(bma, {params[2], params[3]}, 0) and not bma
		bmb = bmb and not bms
		front = front+bms*sh_color
	    end if
	    if paper then
		back = bmb*pa_color
	    else
		back = save_image({x_pos+xo, y_pos+yo}, 
			    {x_pos+xo, y_pos+yo}+{w+bx+sx+ix[1]-1, h+sy-1})
		back = back*bmb
	    end if
	    display_image({x_pos+xo, y_pos+yo}, front+back) 
	    -- draw underline
	    if underline and params[8]then 
		for j = 0 to params[8]-1 do
		    x = x_pos                   -- start of underline: x
		    y = y_pos+height+params[7]+j-1              --  y
		    if sx or sy then
			-- shadow
			draw_line(sh_color, {{x+sx, y+sy}, 
				{x+bx+sx+w+kx-1, y+sy}})
		    end if
		    -- underline
		    if hlight and j = 0 then
			draw_line(hl_color, {{x, y}, {x+w+bx+kx-1, y}})
		    else
			draw_line(te_color, {{x, y}, {x+w+bx+kx-1, y}})
		    end if
		end for
	    end if
	    x_pos = x_pos+xo+w+bx+kx
	end if
    end if
end procedure  -- sf_char

procedure set_attributes(integer char)
    if char = 0 then  -- clear char attribute flags
	bold = 0
	italic = 0
	hlight = 0
	shadow = 0
	underline = 0
    -- toggle char attribute flags
    elsif char = -1 then
	bold = not bold
    elsif char = -2 then
	italic = not italic
    elsif char = -3 then
	hlight = not hlight
    elsif char = -4 then
	shadow = not shadow
    elsif char = -5 then
	underline = not underline
    end if
    bx = params[1]*bold
    ix = {}
    if italic then
	for i = 1 to height+sy do
	    ix = prepend(ix, floor(i/4))
	end for
    else
	ix = {0}
    end if
    sx = params[2]*shadow
    sy = params[3]*shadow
end procedure  -- set_attributes

global procedure sf_select(integer f_id)
-- selects font file for f_print() routine
    if f_id > 0 and f_id <= length(NS) then
	font = f_id
	height = YS[font][' ']+HS[font][' ']
    end if
end procedure  -- sf_select

global procedure sf_colors(sequence c)
-- sets font colors for f_print()
    te_color = c[1]
    hl_color = c[2]
    sh_color = c[3]
    pa_color = c[4]
end procedure  -- sf_colors

global procedure sf_paper(integer f)
-- sets or clears paper mode
    paper = f
end procedure  -- sf_paper

global procedure sf_params(sequence fp)
-- sets font parameters
    params = fp
    bx = params[1]*bold
    kx = params[5]
    sx = params[2]*shadow
    sy = params[3]*shadow
end procedure  -- sf_params

global function sf_length(sequence text)
-- returns the length in pixels of a text string
-- if the text string contains newline chars, a sequence of
-- lengths is returned, one for each segment of the string
    sequence len
    integer l, b, bb
    len = {}
    l = 0
    b = bold
    bb = b*params[1]
    for i = 1 to length(text) do
	if text[i] >= -1 and text[i] <= NS[font] then
	    if text[i] = -1 then  -- toggle bold
		b = not b
		bb = b*params[1]
	    elsif text[i] = 0 then  -- clear bold
		b = 0
		bb = 0
	    elsif text[i] = 10 then
		len = len & l
		l = 0
	    else
		l = l+XS[font][text[i]]+WS[font][text[i]]+bb+kx
	    end if
	end if
    end for
    len = len & l
    return len
end function  -- sf_length

global function sf_height()
    return height
end function  -- sf_height

global procedure sf_position(sequence xy)
-- sets print position for f_print()
    x_pos = xy[1]
    y_pos = xy[2]
    l_margin = xy[1]
end procedure  -- sf_position

global procedure sf_print(sequence text)
-- displays sprites as text characters
    if length(text) then
	for i = 1 to length(text) do
	    if text[i] < 1 then
		set_attributes(text[i])
	    elsif text[i] > 255 then  -- set text color
		te_color = text[i]-256
	    elsif text[i] = 10 then  -- newline
		x_pos = l_margin
		y_pos = y_pos+height+params[6]
	    elsif text[i] <= NS[font] then
		sf_char(text[i])
	    end if
	end for
    end if
end procedure  -- sf_print

global procedure sf_cprint(sequence box, sequence text)
-- prints centered in box {{x1, y1}, {x2, y2}}
    sequence len
    integer line
    if length(text) then
	len = sf_length(text)
	line = 1
	x_pos = floor((box[1][1]+box[2][1]-len[line]+1)/2)
	y_pos = floor((box[1][2]+box[2][2]-(height+params[6]+1)*
			    length(len))/2)+2
	for i = 1 to length(text) do
	    if text[i] < 1 then
		set_attributes(text[i])
	    elsif text[i] > 255 then  -- set text color
		te_color = text[i]-256
	    elsif text[i] = 10 then
		line = line+1
		x_pos = floor((box[1][1]+box[2][1]-len[line]+1)/2)
		y_pos = y_pos+height+params[6]
	    elsif text[i] <= NS[font] then
		sf_char(text[i])
	    end if
	end for
    end if
end procedure  -- sf_cprint

global function sf_gets(sequence text, integer w)
-- gets user input: text = default text; w = width of field in pixels
    sequence cb, len
    integer key, dx, dy, cu
    atom t
    w = x_pos+w-1
    len = sf_length(text)
    if length(len) > 1 or len[1] >= w then 
	return {-1, text}
    end if
    sf_print(text)
    t = time()
    cu = 0
    while 1 do
	-- blinking cursor
	cb = save_image({x_pos, y_pos}, {x_pos, y_pos+height-2})
	while 1 do
	    if time()-t > 0.3 then
		t = time()
		if cu then
		    display_image({x_pos, y_pos}, cb)
		    cu = 0
		else
		    draw_line(te_color, {{x_pos, y_pos}, 
			    {x_pos, y_pos+height-2}})
		    cu = 1
		end if
	    end if
	    key = get_key()
	    if key != -1 then
		-- erase current cursor
		if cu then
		    display_image({x_pos, y_pos}, cb)
		    cu = 0
		    t = time()
		end if
		exit
	    end if
	end while
	if key = 13 then    -- enter
	    exit
	elsif key = 27 then  -- escape
	    text = {}
	    exit
	end if
	if key >= 32 and key < 127 then
	    if x_pos+XS[font][key]+WS[font][key]+bx+kx < w then
		sf_char(key)
		text = text & key
	    end if
	elsif key = 8 and length(text) then   -- backspace
	    -- shift back one char
	    dx = XS[font][key]+WS[font][text[length(text)]]+bx+kx
	    x_pos = x_pos-dx
	    -- and erase the last char
	    dx = dx-1
	    dy = height+sy-1
	    if underline and params[8] then
		dy = dy+params[7]+params[8]
	    end if
	    polygon(pa_color, 1, {{x_pos, y_pos}, {x_pos+dx, y_pos}, 
			{x_pos+dx, y_pos+dy}, {x_pos, y_pos+dy}})
	    text = text[1..length(text)-1]
	end if
    end while
    return text
end function  -- sf_gets

