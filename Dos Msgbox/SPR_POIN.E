include machine.e
include bitmap.e
include ratbag.e
include spr_load.e

--  << spr_poin.e >> -- installs a sprite as mouse pointer
--   Colin Taylor - 71630.1776@compuserve.com
--   version 1.0  2/27/97, 7/20/97

constant A = 1, B = 2  -- sprite images A and B

integer pointer_mem  -- storage for mouse pointer bitmap
pointer_mem = allocate_low(64)

global procedure set_pointer(integer f_id, integer sn, sequence c, 
			    sequence offset)
-- Installs a SPRED sprite image as mouse pointer.  If the size of 
-- the sprite exceeds 16x16 pixels, it is trimmed to 16x16.
--      f_id  -  file ID number
--      sn    -  sprite number (sprite location in file)
--      c     -  {c1, c2, c3}   -  colors 1, 2 and 3
--                  set color:   1 for white (mask and color)
--                               0 for back_color (mask only)
--                              -1 for transparent (no mask or color)
--                              -2 for background contrast color (color only)
--      offset  -  {x, y}  -  display_offset in pixels
    sequence mask, color, image, reg_list, bytes
    image = {}
    image = append(image, IS[f_id][sn][A] and not IS[f_id][sn][B])
    image = append(image, IS[f_id][sn][B] and not IS[f_id][sn][A])
    image = append(image, IS[f_id][sn][A] and IS[f_id][sn][B])
    mask = repeat(repeat(0, 16), 16)
    color = mask
    for i = 1 to 3 do
	image[i] = bm_resize(image[i], {XS[f_id][sn], YS[f_id][sn]}, 
	    {16-XS[f_id][sn]-WS[f_id][sn], 16-YS[f_id][sn]-HS[f_id][sn]}, 0)
	if c[i] >= 0 then
	    mask = mask or image[i]
	end if
	if c[i] = 1 or c[i] = -2 then
	    color = color or image[i]
	end if
    end for
    mask = bm_compress(not mask)
    color = bm_compress(color)
    bytes = {}
    for i = 1 to 16 do
	bytes = bytes & mask[i][2] & mask[i][1]
    end for
    for i = 1 to 16 do
	bytes = bytes & color[i][2] & color[i][1]
    end for
    -- cursor change procedure by Viktor Milankovics
    poke(pointer_mem, bytes)
    reg_list = repeat(0, 10)
    reg_list[REG_AX] = 9
    reg_list[REG_BX] = offset[1]
    reg_list[REG_CX] = offset[2]
    reg_list[REG_ES] = floor(pointer_mem/16)
    reg_list[REG_DX] = remainder(pointer_mem, 16)
    mouse_pointer(0)
    reg_list = dos_interrupt(#33, reg_list)
    mouse_pointer(1)
end procedure  -- set_pointer

