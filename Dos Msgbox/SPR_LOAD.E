include bitmap.e

--  << spr_load.e >> -- euphoria sprite file loader
--   Colin Taylor  71630.1776@compuserve.com
--   version 1.1  2/21/97, 8/14/97
--
--  user routines:
--  --------------
--  function load_sprite(file_name)     -- loads sprite file (returns file ID)
--  procedure unload_sprite()           -- unloads the last loaded sprite file
--  function make_image(colors, fn, sn) -- returns a 4-color sprite image

constant A = 1, B = 2  -- sprite image planes A and B

-- sprite file data
global sequence NS,        -- stack of sprite file lengths
		XS,        -- stack of sprite x-offset sequences
		YS,        -- stack of sprite y-offset sequences
		HS,        -- stack of sprite height sequences
		WS,        -- stack of sprite width sequences
		IS         -- stack of sprite file image sequences

sequence sprite_path

NS = {}
XS = {}
YS = {}
HS = {}
WS = {}
IS = {}
sprite_path = ""
	  
global function load_sprite(sequence file_name)
-- Loads a sprite file into memory and returns the file ID number or -1 if 
-- there is an error.  The file location is defined by the sprite_path 
-- variable.  Several sprite files can be held in memory at the same time.
    sequence comment, x, y, h, w, s, row, bm, sprite
    integer fn, n, w_bytes
    comment = repeat(0, 30)
    h = {}
    w = {}
    fn = open(sprite_path & file_name, "rb")
    if fn = -1 then
	return -1
    end if
    -- get file header
    row = getc(fn) & getc(fn)
    if not(row[1] = 's' and (row[2] = 0 or row[2] = 1)) then
	close(fn)
	return -1
    end if
    for a = 1 to 30 do
	comment[a] = getc(fn)
    end for
    n = getc(fn)
    if row[2] = 0 then  -- old file
	x = repeat(0, n)
	y = repeat(0, n)
    else
	x = {}
	for a = 1 to n do
	    x = x & getc(fn)
	end for
	y = {}
	for a = 1 to n do
	    y = y & getc(fn)
	end for
    end if
    for a = 1 to n do
	h = h & getc(fn)
    end for
    for a = 1 to n do
	w = w & getc(fn)
    end for
    -- get sprite bitmaps
    s = repeat(0, n)
    for a = 1 to n do
	sprite = repeat(0, 2)
	for image = A to B do
	    bm = repeat(0, h[a])
	    if h[a] and w[a] then
		for i = 1 to h[a] do
		    row = {}
		    w_bytes = -floor(-w[a]/8)
		    for j = 1 to w_bytes do
			row = row & getc(fn)
		    end for
		    bm[i] = row
		end for
		bm = bm_expand(bm, w[a])
	    end if
	    sprite[image] = bm
	end for
	s[a] = sprite
    end for
    close(fn)
    NS = NS & n
    XS = append(XS, x)
    YS = append(YS, y)
    HS = append(HS, h)
    WS = append(WS, w)
    IS = append(IS, s)
    return length(NS)  -- file ID number
end function  -- load_sprite

global procedure unload_sprite()
-- unloads the top (most recently loaded) sprite file from memory
    integer last_file
    last_file = length(NS)
    if last_file > 0 then
	NS = NS[1..last_file-1]
	XS = XS[1..last_file-1]
	YS = YS[1..last_file-1]
	HS = HS[1..last_file-1]
	WS = WS[1..last_file-1]
	IS = IS[1..last_file-1]
    end if
end procedure  -- unload_sprite

global function make_image(sequence colors, integer fn, integer sn)
-- generates a 4-color bitmap from sprite object
-- colors is {c0, c1, c2, c3} where c0 is mask color
-- fn is sprite file ID number, sn is sprite number
    sequence mask, bm1, bm2, bm3
    bm1 = IS[fn][sn][A] and not IS[fn][sn][B]
    bm2 = IS[fn][sn][B] and not IS[fn][sn][A]
    bm3 = IS[fn][sn][A] and IS[fn][sn][B]
    mask = not (bm1+bm2+bm3)
    return mask*colors[1]+bm1*colors[2]+bm2*colors[3]+bm3*colors[4]
end function  -- make_image

