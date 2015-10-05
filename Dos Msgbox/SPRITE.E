include graphics.e
include image.e

--  << sprite.e >> -- simple euphoria sprite engine
--  Colin Taylor - 71630.1776@compuserve.com
--     version 1.0  7/24/97
--
--  global routines:
--      procedure background()            -- provides background image to be 
--                                              used by virtual screen
--      procedure refresh_screen()        -- displays sprites and background
--      function make_sprite(m_c, bm, xy) -- adds an image to sprite list 
--      procedure show_sprite(sn)         -- displays a sprite 
--      procedure hide_sprite(sn)         -- hides a sprite 
--      procedure move_sprite(sn, xy)     -- moves a sprite to xy
--
--  Sprites are graphic images which can be displayed and moved about 
--  on the computer screen without affecting the underlying background 
--  image.  Sprite.e contains the basic routines needed to display and 
--  move sprite images without flicker or artifacts. 

sequence MS  -- stack of data for each sprite
	     -- {{visible, size, image, mask, location, last_locn}, ...}
global integer x_max, y_max  -- screen size in pixels
atom bg, vs  -- background, virtual screen memory addresses

sequence vc

-- initialize display
if graphics_mode(GRAPHICS_MODE) then
    puts(2, "This program requires VGA graphics.\n")
    abort(1)
end if

vc = video_config()
x_max = vc[VC_XPIXELS]
y_max = vc[VC_YPIXELS]

MS = {}
bg = allocate(x_max*y_max)
vs = allocate(x_max*y_max)

procedure vs_display(sequence s1, sequence s2)
-- displays an area of the virtual screen
    integer peek_len, s
    atom r, t
    
    peek_len = s2[1]-s1[1]+1
    s = (s1[2]-1)*x_max
    t = vs+s1[1]+s
    r = x_max+t
    for i = 1 to s2[2]-s1[2]+1 do
	pixel(peek({r, peek_len}), s1)
	s1[2] = s1[2]+1
	r = r + x_max
    end for
end procedure  -- vs_display

procedure vs_put(integer sn)
-- adds a sprite to the virtual screen
    integer r, m4, mj
    atom t
    sequence m
    
    m4 = MS[sn][4]
    for i = 1 to MS[sn][2][2] do
	r = (i+MS[sn][5][2]-1) * x_max
	t = MS[sn][5][1]-1 + r + vs
	m = MS[sn][3][i]
	for j = 1 to MS[sn][2][1] do
	    mj = m[j]
	    if mj != m4 then
		poke(j+t, mj)
	    end if
	end for
    end for
end procedure  -- vs_put

procedure refresh_vs()
-- updates the virtual screen
    mem_copy(vs, bg, x_max*y_max)
    for i = 1 to length(MS) do
	if MS[i][1] then
	    vs_put(i)
	end if
    end for
end procedure  -- refresh_vs

global procedure background(bitmap bm)
-- installs or changes background image
    sequence size
    size = {length(bm[1]), length(bm)}
    for i = 1 to size[2] do
	poke(bg+(i-1)*x_max, bm[i])
    end for 
end procedure  -- background

global procedure refresh_screen()
-- updates the display after one or more of the sprites have been moved
-- *note* do not move a sprite more than once without updating the display
    refresh_vs()
    for i = 1 to length(MS) do
	-- erase old image
	vs_display(MS[i][6], MS[i][6]+MS[i][2]-1)
	if MS[i][1] then
	    -- display new image
	    vs_display(MS[i][5], MS[i][5]+MS[i][2]-1)
	end if
    end for
end procedure  -- refresh_screen

global function make_sprite(integer mask_color, bitmap bm, sequence xy)
-- converts an image to a sprite and returns a sprite number.
    sequence size
    size = {length(bm[1]), length(bm)}
    MS = append(MS, {0, size, bm, mask_color, xy, xy})
    return length(MS)  -- sprite number
end function  -- make_sprite

global procedure show_sprite(integer sn)
-- displays a hidden sprite 
    MS[sn][1] = 1
end procedure  -- show_sprite

global procedure hide_sprite(integer sn)
-- hides a sprite 
    MS[sn][1] = 0
end procedure  -- hide_sprite

global procedure move_sprite(integer sn, sequence xy)
-- relocates a sprite, retaining the same sprite number
    MS[sn][6] = MS[sn][5]
    MS[sn][5] = xy
end procedure  -- move_sprite

