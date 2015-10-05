include bitmap.e

--  << font2spr.ex >> -- converts font files to sprite files
--  Colin Taylor - 71630.1776@compuserve.com
--      version 1.0  1/13/97, 7/20/97
--
--  Converts font files in Jiri Babor's format (*.f) to sprite files.
--  In the resulting sprite file, the character image is color 1,
--  the paper image is color 2 and color 3 is not used in the 
--  conversion.

----------------< local variables >---------------------------------------------

sequence cl, f_path, load_name, save_name
integer f, first_char, last_char, max_width, height, byte
sequence width, font
sequence S, X, Y, W, H

----------------< initialize variables >----------------------------------------

f_path = "c:\\euphoria\\fonts\\"  -- location of font files

----------------< local routines >----------------------------------------------

procedure load_font(sequence file_name)
    integer fn
    sequence chfont, bytes
    fn = open(file_name, "rb")
    if fn = -1 then
	puts(1, "Error: " & file_name & " not found!\n")
	abort(1)
    end if
    puts(1, "loading " & file_name & " ...\n")
    first_char = getc(fn)       
    last_char = getc(fn)
    max_width = getc(fn)
    height = getc(fn)
    byte = getc(fn)         -- ignore byte
    byte = getc(fn)         -- ignore byte
    width = {}
    for i = first_char to last_char do
	width = width & getc(fn)
    end for
    font = {}
    for i = first_char to last_char do
	chfont = {}
	for j = 1 to height do
	    bytes = {}
	    for k = 1 to max_width do
		bytes = bytes & getc(fn)
	    end for
	    chfont = append(chfont, bytes)
	end for
	font = append(font, bm_expand(chfont, width[i-first_char+1]))
    end for
    close(fn)
    if first_char < 1 then
	width = width[2-first_char..last_char-first_char+1]
	font = font[2-first_char..last_char-first_char+1]
	first_char = 1
    end if
    if first_char > 254 then
	puts(1, "Error: invalid font file\n")
	abort(1)
    end if
    if last_char > 255 then  -- discard chars above 255
	last_char = 255
	width = width[1..first_char-last_char+1]
	font = font[1..first_char-last_char+1]
    end if
end procedure  -- load_font

function trim_image(bitmap bm, integer w)
-- returns the row and column containing the first and last non-zero pixel
    integer x1, y1, x2, y2
    if w > 32 then
	w = 32
    end if
    if height > 32 then
	height = 32
    end if
    x1 = w
    y1 = height
    x2 = 0
    y2 = 0
    for i = 1 to height do
	for j = 1 to w do
	    if bm[i][j] then
		if i < y1 then
		    y1 = i
		end if
		if j < x1 then
		    x1 = j
		end if
		if i > y2 then
		    y2 = i
		end if
		if j > x2 then
		    x2 = j
		end if
	    end if
	end for
    end for
    if y2 = 0 then  -- blank sprite
	x1 = 1
	y1 = 1
    end if
    return {x1, y1, x2, y2}
end function  -- trim_image

procedure convert()
-- converts the font to sprite images
    sequence tr
    integer xo, yo, h, w
    -- get sprite height and width 
    S = repeat({}, first_char-1)
    X = S  Y = S  W = S  H = S
    for i = 1 to last_char-first_char+1 do
	tr = trim_image(font[i], width[i])
	xo = tr[1]-1    -- x-offset (number of blank columns on left side of image)
	yo = tr[2]-1    -- y-offset (number of blank columns on left side of image)
	w = tr[3]-xo    -- width of trimmed image
	h = tr[4]-yo    -- height of trimmed image
	if w then
	    S = append(S, bm_trim(font[i], tr[1..2], tr[3..4]))
	else
	    S = append(S, {})
	end if
	X = X & xo
	Y = Y & yo
	W = W & w
	H = H & h
    end for
    Y[' '] = height-1
    W[' '] = floor(W['m']/2)
    H[' '] = 1
    S[' '] = {repeat(0, W[' '])}
end procedure  -- convert

procedure save_sprites(sequence file_name)
-- saves font file as sprite file
    sequence bma, bmb
    integer fn
    fn = open(file_name, "wb")
    if fn = -1 then
	puts(1, "Could not open file " & file_name)
	abort(1)
    end if
    puts(1, "saving " & file_name & " ...\n")
    puts(fn, {'s', 1} & "font" & repeat(0, 26))         -- header
    puts(fn, last_char)                                 -- number of spites
    puts(fn, X)                                         -- image heights
    puts(fn, Y)                                         -- image heights
    puts(fn, H)                                         -- image heights
    puts(fn, W)                                         -- image widths
    for x = 1 to last_char-first_char+1 do              -- save bitmaps
	if W[x] then
	    bma = bm_compress(S[x])
	    bmb = bm_compress(not S[x])
	    for i = 1 to H[x] do
		puts(fn, bma[i])
	    end for
	    for i = 1 to H[x] do
		puts(fn, bmb[i])
	    end for
	end if
    end for
    close(fn)
end procedure  -- save_sprites

----------------< end of routines >--------------------------------------------

cl = command_line()
if length(cl) < 3 then
    puts(1, "usage: ex font2spr file.f [file.sf]\n")
    abort(1)
end if
load_name = cl[3]
if not find('.', load_name) then
    load_name = load_name & ".f"
end if
load_font(f_path & load_name)
convert()
if length(cl) > 3 then
    save_name = cl[4]
    if not find(".", save_name) then
	save_name = save_name & ".sf"
    end if
else
    f = find('.', load_name)
    save_name = load_name[1..f] & "sf"
end if
save_sprites(save_name)

