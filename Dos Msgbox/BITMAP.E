--  << bitmap.e >> -- euphoria bitmap tools
--  Colin Taylor - 71630.1776@compuserve.com
--  version 1.11 - 1/5/97, 7/20/97
--
--  global types:
--      type bitmap(bm)
--
--  global routines:
--      function bm_size(bm)
--      function bm_colors(bm)
--      function bm_roll(bm, s)
--      function bm_shift(bm, s, c)
--      function bm_warp(bm, s, c)
--      function bm_resize(bm, s1, s2, c)
--      function bm_trim(bm, s1, s2)
--      function bm_insert(bm1, bm2, s)
--      function bm_tile(bm, a)
--      function bm_invert(bm)
--      function bm_rotate(bm)
--      function bm_compress(bm)
--      function bm_expand(bc, w)
--      function bm_save(bm, name)
--      function bm_load(name)
--
--  This program contains a series of routines for the manipulation
--  of euphoria color bitmaps, i.e. graphic images of up to 256 colors
--  in the same format used by the save_image() and display_image()
--  routines found in <image.e>.  See <bitmap.txt> for more information 
--  and <bm_demo.ex> for examples of usage.
--
--  Version 1.1
--  - type color() and type bitmap() modified
--  - make_bits() and bm_expand() are now faster
--  - bm_tile(), bm_save() and bm_load() added

without type_check

----------------< local constants >---------------------------------------------

constant FALSE = 0, TRUE = 1

----------------< local types >-------------------------------------------------

type color(object x)
    return integer(x) and x >= 0 and x < 256
end type  -- color

----------------< global types >------------------------------------------------

global type bitmap(object bm)
    integer x, y
    if not sequence(bm) then
	return FALSE
    end if
    y = length(bm)
    if y < 1 then
	return FALSE
    end if
    x = length(bm[1])
    if x < 1 then
	return FALSE
    end if
    for i = 1 to y do
	if length(bm[i]) != x then
	    return FALSE
	end if
	for j = 1 to x do
	    if not color(bm[i][j]) then
		return FALSE
	    end if
	end for
    end for
    return TRUE
end type  -- bitmap

----------------< local routines >----------------------------------------------

function make_bits(integer c)
-- Converts byte c to a sequence of 8 bits (0 or 1).
-- Returns bits in the order most significant to least significant.
    sequence bits
    bits = repeat(0, 8)
    if c then
	for i = 8 to 1 by -1 do
	    bits[i] = remainder(c, 2)
	    c = floor(c/2)
	end for
    end if
    return bits
end function  -- make_bits

function make_byte(sequence bits)
-- Converts sequence of 8 bits to one byte.
-- Bits must be in order from most significant to least significant.
-- * length(bits) must be 8 *
    integer byte
    byte = 0
    for i = 1 to 8 do
	if bits[i] then  -- assume that bits[i] is boolean
	    byte = byte + power(2, 8-i)
	end if
    end for
    return byte
end function  -- make_byte

----------------< global routines >---------------------------------------------

global function bm_size(bitmap bm)
-- Returns the matrix size of bitmap bm in the form {sx, sy}.
    sequence b
    b = bm
    return {length(b[1]), length(b)}
end function  -- bm_size

global function bm_colors(bitmap bm)
-- Returns the apparent number of colors used in bitmap bm,
-- based on the highest color number found.
    integer c
    sequence b, size
    b = bm
    c = 0
    size = bm_size(b)
    for i = 1 to size[2] do
	for j = 1 to size[1] do
	    if b[i][j] > c then
		c = b[i][j]
	    end if
	end for
    end for
    if c < 2 then 
	return 2
    elsif c < 4 then 
	return 4
    elsif c < 16 then 
	return 16
    else 
	return 256
    end if
end function  -- bm_colors

global function bm_roll(bitmap bm, sequence r)
--  Moves the image r[1] pixels to the right and r[2] pixels down.
--  Pixels which overflow are added to the opposite side of the matrix.
--  r = {x, y}.  r[1] and r[2] can be positive or negative.
    sequence b, size
    b = bm
    size = bm_size(b)
    if r[1] < 0 then
	for i = 1 to size[2] do
	    b[i] = b[i][-r[1]+1..size[1]] & b[i][1..-r[1]]
	end for
    elsif r[1] > 0 then
	for i = 1 to size[2] do
	    b[i] = b[i][size[1]-r[1]+1..size[1]] & b[i][1..size[1]-r[1]]
	end for
    end if
    if r[2] < 0 then
	b = b[-r[2]+1..size[2]] & b[1..-r[2]]
    elsif r[2] > 0 then
	b = b[size[2]-r[2]+1..size[2]] & b[1..size[2]-r[2]]
    end if
    return b
end function  -- bm_roll

global function bm_shift(bitmap bm, sequence v, color c)
--  Moves the image v[1] pixels to the right and v[2] pixels down.
--  Pixels which overflow are discarded and pixels of color c are 
--  added to the opposite side of the matrix to maintain matrix size.
--  v = {x, y}.  v[1] and v[2] can be positive or negative.
    sequence b, size
    b = bm
    size = bm_size(b)
    if v[1] < 0 then
	for i = 1 to size[2] do
	    b[i] = b[i][-v[1]+1..size[1]] & repeat(c, -v[1])
	end for
    elsif v[1] > 0 then
	for i = 1 to size[2] do
	    b[i] = repeat(c, v[1]) & b[i][1..size[1]-v[1]]
	end for
    end if
    if v[2] < 0 then
	for i = -1 to v[2] by -1 do
	    b = append(b[2..size[2]], repeat(c, size[1]))
	end for
    elsif v[2] > 0 then
	for i = 1 to v[2] do
	    b = prepend(b[1..size[2]-1], repeat(c, size[1]))
	end for
    end if
    return b
end function  -- bm_shift

global function bm_warp(bitmap bm, sequence s, color c)
-- Shifts each line of the bitmap bm by the corresponding value
-- in pixels found in s.  Adds pixels of color c to the ends of 
-- each line to maintain the rectangular shape of bm.
-- * the length of s must be greater or equal to the length of bm *
    atom ws
    sequence b, size
    b = bm
    size = bm_size(b)
    ws = 0
    for i = 1 to size[2] do
	if s[i] > ws then
	    ws = s[i]
	end if
    end for
    for i = 1 to size[2] do
	b[i] = repeat(c, s[i]) & b[i] & repeat(c, ws-s[i])
    end for
    return b
end function  -- bm_warp

global function bm_resize(bitmap bm, sequence r1, sequence r2, color c)
-- Adjusts the size of a bitmap by adding or subtracting rows or
-- columns to (or from) any side of the bitmap.  Pixels removed
-- are discarded.  Pixels added are color c.
-- r1 = {x, y}  -- resize amount for top and left of bitmap.
-- r2 = {x, y}  -- resize amount for bottom and right of bitmap.
-- Resize amounts can be positive or negative.
    sequence b, size, temp
    b = bm
    size = bm_size(b)
    if r1[1] < 0 then
	temp = {}
	for i = 1 to size[2] do
	    temp = append(temp, b[i][-r1[1]+1..size[1]])
	end for
	b = temp
	size[1] = size[1]+r1[1]
    elsif r1[1] > 0 then
	temp = {}
	for i = 1 to size[2] do
	    temp = append(temp, repeat(c, r1[1]) & b[i])
	end for
	b = temp
	size[1] = size[1]+r1[1]
    end if
    if r1[2] < 0 then
	b = b[-r1[2]+1..size[2]]
	size[2] = size[2]+r1[2]
    elsif r1[2] > 0 then
	b = repeat(repeat(c, size[1]), r1[2]) & b
	size[2] = size[2]+r1[2]
    end if
    if r2[1] < 0 then
	temp = {}
	for i = 1 to size[2] do
	    temp = append(temp, b[i][1..size[1]+r2[1]])
	end for
	b = temp
	size[1] = size [1]+r2[1]
    elsif r2[1] > 0 then
	temp = {}
	for i = 1 to size[2] do
	    temp = append(temp, b[i] & repeat(c, r2[1]))
	end for
	b = temp
	size[1] = size [1]+r2[1]
    end if
    if r2[2] < 0 then
	b = b[1..size[2]+r2[2]]
    elsif r2[2] > 0 then
	b = b & repeat(repeat(c, size[1]), r2[2])
    end if
    return b
end function  -- bm_resize

global function bm_trim(bitmap bm, sequence s1, sequence s2)
-- Extracts a rectangular bitmap section {s1, s2} from a larger bitmap bm.
-- s1 = {x,y} - position within bm of the upper left corner of section.
-- s2 = {x,y} - position within bm of the lower right corner of section.
-- * both s1 and s2 must fall within the area of bm *
    sequence b, temp
    b = bm
    temp = {}
    for i = s1[2] to s2[2] do
	temp = append(temp, b[i][s1[1]..s2[1]])        
    end for
    return temp
end function  -- bm_trim

global function bm_insert(bitmap bm1, bitmap bm2, sequence s)
-- Inserts a rectangular bitmap section bm2 into a larger bitmap bm1.
-- s = {x,y} - position of the upper left corner of bm2 within bm1.
-- * all of bm2 must fall within the area of bm1 *
    sequence b1, b2, size
    b1 = bm1
    b2 = bm2
    size = bm_size(b2)
    for i = s[2] to s[2]+size[2]-1 do
	b1[i][s[1]..s[1]+size[1]-1] = b2[i-s[2]+1]
    end for
    return b1
end function  -- bm_insert

global function bm_tile(bitmap bm, sequence a)
-- Replicates bitmap bm over area a, where
-- a = {width, length} in pixels.
    sequence b, size, t1, t2
    b = bm
    size = bm_size(b)
    if a[1] > size[1] then
	t1 = repeat(repeat(0, -floor(-a[1]/size[1])*size[1]), size[2])
	for j = 1 to a[1] by size[1] do
	    t1 = bm_insert(t1, b, {j, 1})
	end for
    else
	t1 = b
    end if
    t1 = bm_trim(t1, {1, 1}, {a[1], size[2]})
    if a[2] > size[2] then
	t2 = bm_resize(t1, {0, 0}, {0, -floor(-a[2]/size[2])*size[2]}, 0)
	for i = 1+size[2] to a[2] by size[2] do
	    t2 = bm_insert(t2, t1, {1, i})
	end for
    else
	t2 = t1
    end if
    return bm_trim(t2, {1, 1}, a)
end function  -- bm_tile

global function bm_invert(bitmap bm)
-- Inverts bitmap bm top to bottom, producing a mirror image.
    sequence b, size, temp
    b = bm
    size = bm_size(b)
    temp = {}
    for i = 1 to size[2] do
	temp = prepend(temp, b[i])
    end for
    return temp
end function  -- bm_invert

global function bm_rotate(bitmap bm)
-- Rotates bitmap bm 90 degrees counterclockwise.
    sequence b, size, temp
    b = bm
    size = bm_size(b)
    temp = repeat(repeat(0, size[2]), size[1])
    for i = 1 to size[2] do
	for j = 1 to size[1] do
	    temp[size[1]-j+1][i] = b[i][j]
	end for
    end for
    return temp
end function  -- bm_rotate

global function bm_compress(bitmap bm)
-- Converts boolean bitmap bm to a compressed bitmap.
    integer r
    sequence b, size, bc, bytes
    b = bm
    size = bm_size(b)
    r = remainder(size[1], 8)
    if r then
	r = 8-r
    end if
    bc = {}
    for i = 1 to size[2] do
	b[i] = b[i] & repeat(0, r)  -- fill bm out to byte boundary
	bytes = {}
	for j = 1 to size[1] by 8 do
	    bytes = bytes & make_byte(b[i][j..j+7])
	end for
    bc = append(bc, bytes)
    end for
    return bc
end function  -- bm_compress

global function bm_expand(bitmap bc, integer w)
-- Converts compressed bitmap bc to a boolean bitmap.
-- w = bitmap width in pixels.
-- * w must not exceed 8 times the bitmap width in bytes *
    sequence b, size, bm, bits
    b = bc
    size = bm_size(b)
    bm = repeat(0, size[2])
    for i = 1 to size[2] do
	bits = repeat(0, size[1]*8)
	for j = 1 to size[1] do
	    bits[(j-1)*8+1..(j-1)*8+8] = make_bits(b[i][j])
	end for
	bm[i] = bits[1..w]
    end for
    return bm
end function  -- bm_expand

global function bm_save(bitmap bm, sequence name)
-- saves a euphoria bitmap in binary file format:
--      bytes 1,2:  "bm"
--      bytes 3,4:  length of bitmap as 16-bit integer (i)
--      bytes 5,6:  width of bitmap as 16-bit integer (j)
--      bytes 7-32: (reserved)
--      next i*j bytes: bitmap (left to right, top to bottom)
-- returns 0 if file is successfully save, otherwise returns 1
    integer fn
    sequence b, size
    if length(name) then
	b = bm
	size = bm_size(b)
	fn = open(name, "wb")
	if fn = -1 then
	    return 1
	end if
	puts(fn, "bm")
	puts(fn, {remainder(size[2], 256), floor(size[2]/256)})
	puts(fn, {remainder(size[1], 256), floor(size[1]/256)})
	puts(fn, repeat(0, 26))
	for i = 1 to size[2] do
	    puts(fn, b[i])
	end for
	close(fn)
    end if
    return 0
end function  --  bm_save

global function bm_load(sequence name)
-- loads a binary bitmap file and returns a euphoria bitmap
    integer fn, len, wid, byte
    sequence bm, row
    if length(name) then
	fn = open(name, "rb")
	if fn = -1 then
	    return 1
	end if
	if not(getc(fn) = 'b' and getc(fn) = 'm') then
	    close(fn)
	    return 1
	end if
	len = getc(fn)+getc(fn)*256
	wid = getc(fn)+getc(fn)*256
	for x = 1 to 26 do
	    byte = getc(fn)
	end for
	bm = {}
	for i = 1 to len do
	    row = {}
	    for j = 1 to wid do
		row = row & getc(fn)
	    end for
	    bm = append(bm, row)
	end for
    end if
    return bm
end function  -- bm_load

----------------< end of routines >---------------------------------------------
