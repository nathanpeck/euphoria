include graphics.e
include image.e
include sort.e
include bitmap.e

-- << pointer.e >> - color mouse pointer (works in all graphics modes)
-- Colin Taylor - 71630,1776@compuserve.com
--    version 1.0  7/15/97

sequence mask, pointer, data, last_data
integer last_x, last_y, width, height

last_x = 0
last_y = 0
last_data = {}

-- default pointer image and mask
pointer = {{#00,#00},{#20,#00},{#30,#00},{#38,#00},{#3C,#00},{#3E,#00},
	{#3F,#00},{#3F,#80},{#3F,#C0},{#3E,#00},{#36,#00},{#23,#00},
	{#03,#00},{#01,#80},{#01,#80},{#00,#00}}
pointer = bm_expand(pointer, 16)*15

mask = {{#60,#00},{#70,#00},{#78,#00},{#7C,#00},{#7E,#00},{#7F,#00},
	{#7F,#80},{#7F,#C0},{#7F,#E0},{#7F,#F0},{#7F,#00},{#77,#80},
	{#67,#80},{#03,#C0},{#03,#C0},{#01,#C0}}
mask = not bm_expand(mask, 16)

width = 16
height = 16

function impact(sequence r1, sequence r2)
-- checks for overlap between 2 rectangles and returns TRUE or FALSE
-- r1, r2 in form {{x1, y1}, {x2, y2}}
    return not (r2[2][1] < r1[1][1] or r2[2][2] < r1[1][2]
	or r2[1][1] > r1[2][1] or r2[1][2] > r1[2][2])
end function  -- impact

function overlap(sequence r1, sequence r2)
-- Returns the screen coordinates of the overlap area betweeen rectangles r1 
-- and r2.  The existence of overlap must first be determined by using the
-- impact() function.
    sequence x_list, y_list
    x_list = {r1[1][1], r1[2][1], r2[1][1], r2[2][1]}
    y_list = {r1[1][2], r1[2][2], r2[1][2], r2[2][2]}
    x_list = sort(x_list)
    y_list = sort(y_list)
    return {{x_list[2], y_list[2]}, {x_list[3], y_list[3]}}  -- overlap area
end function  -- overlap

global procedure load_image(integer mask_color, sequence bitmap)
    height = length(bitmap)
    width = length(bitmap[1])
    mask = (bitmap = mask_color)  -- create negative mask
    pointer = bitmap*(not mask)  -- change mask_color in bitmap to 0
end procedure  -- load_image

global procedure show_mouse(sequence xy)
    data = save_image(xy, {xy[1]+width-1, xy[2]+height-1})
    display_image(xy, data*mask+pointer)
    last_x = xy[1]
    last_y = xy[2]
    last_data = data
end procedure  -- show_mouse

global procedure hide_mouse()
    display_image({last_x, last_y}, last_data)
end procedure  -- hide_mouse

global procedure move_mouse(sequence xy)
-- moves pointer to xy using the "dirty rectangle" method to avoid flicker
    sequence back, dirty
    -- save background (may include portion of last pointer image)
    data = save_image({xy[1], xy[2]}, {xy[1]+width-1, xy[2]+height-1})
    -- check for overlap with last pointer image
    if impact({{last_x, last_y}, {last_x+width-1, last_y+height-1}}, 
		{{xy[1], xy[2]}, {xy[1]+width-1, xy[2]+height-1}}) then
	-- get screen coords of overlap area
	dirty = overlap({{last_x, last_y}, {last_x+width-1, last_y+height-1}}, 
		{{xy[1], xy[2]}, {xy[1]+width-1, xy[2]+height-1}})
	-- replace dirty rectangle in data with clean rectangle from last_data
	-- (so that we won't leave an artifact next time we erase the pointer)
	data = bm_insert(data, bm_trim(last_data, 
		dirty[1]-{last_x, last_y}+1, 
		dirty[2]-{last_x, last_y}+1), 
		dirty[1]-{xy[1], xy[2]}+1)
	-- add pointer image to clean background
	back = data*mask+pointer
	-- replace clean rectangle in last_data with rectangle from back
	-- (we insert the new pointer image to eliminate flicker)
	last_data = bm_insert(last_data, bm_trim(back, 
		dirty[1]-{xy[1], xy[2]}+1, 
		dirty[2]-{xy[1], xy[2]}+1),
		dirty[1]-{last_x, last_y}+1)
    else
	-- no overlap, therefore no problem
	back = data*mask+pointer
    end if 
    -- erase old pointer image (and maybe show part of the new pointer image)
    display_image({last_x, last_y}, last_data)
    -- display new pointer image
    display_image({xy[1], xy[2]}, back)
    -- update hide-mouse data
    last_x = xy[1]
    last_y = xy[2]
    last_data = data
end procedure  -- move_mouse

