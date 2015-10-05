include graphics.e
include image.e
include mouse.e
include ratbag.e
include bitmap.e
include spr_font.e

--  << ui.e >> -- graphical user interface parts
--  Colin Taylor - 71630.1776@compuserve.com
--      version 1.2  1/3/97, 9/13/97

global sequence ui_colors  -- {ul_border, face, lr_border, outline}
global sequence buttons, bullets  -- button list, bullet list

sequence image, winstack  -- saved images, saved button and bullet lists
sequence shade  -- shade bitmap

ui_colors = {BRIGHT_WHITE, WHITE, GRAY, BLACK}  -- defaults
buttons = {}
bullets = {}
image = {}
winstack = {}
shade = bm_expand({{85},{170},{85},{170}}, 8)

global procedure get_mbutton_release()
-- wait for mouse button release
    while mouse_event[1] do
	mouse_event = poll_mouse()
    end while
end procedure  -- get_mbutton_release

global procedure box(integer c, integer f, integer os, sequence p1, sequence p2)
-- draw rectangle of color c using coordinates p1 and p2, enlarged by os
--    (flag f indicates outline (0) or filled (1))
    polygon(c, f, {p1-os, {p2[1]+os, p1[2]-os}, p2+os, {p1[1]-os, p2[2]+os}})
end procedure  -- box

global procedure shadow_box(sequence c, integer os, sequence p1, sequence p2)
-- draw shadow box using coordinates p1, p2
-- os gives offset from corner coordinates
    draw_line(c[1], {{p1[1]-os, p2[2]+os-1}, p1-os, {p2[1]+os-1, p1[2]-os}})
    draw_line(c[2], {{p1[1]-os+1, p2[2]+os}, p2+os, {p2[1]+os, p1[2]-os+1}})
end procedure  -- shadow_box

global procedure panel(sequence p1, sequence p2)
-- draw colored area with outline shadow
    box(0, 0, 0, p1, p2)
    box(ui_colors[2], 1, -1, p1, p2)
    shadow_box({ui_colors[1], ui_colors[3]}, -1, p1, p2)
end procedure  -- panel

global procedure button(integer but_num)
-- draw button with label (up position)
    mouse_pointer(0)
    panel(buttons[but_num][1], buttons[but_num][2])
    sf_cprint(buttons[but_num][1..2], 257 & buttons[but_num][3] & 256)
    mouse_pointer(1)
end procedure  -- button

global procedure button_down(integer but_num)
-- draw button with label (down position)
    sequence bm
    bm = bm_tile(shade, buttons[but_num][2]-buttons[but_num][1]+1)
    mouse_pointer(0)
    display_image(buttons[but_num][1], bm*8+(not bm)*7)
    box(ui_colors[3], 0, 0, buttons[but_num][1], buttons[but_num][2])
    shadow_box({ui_colors[4], ui_colors[1]}, -1, buttons[but_num][1], 
		    buttons[but_num][2])
    sf_cprint({buttons[but_num][1], buttons[but_num][2]}, 
		{271,-4} & buttons[but_num][3] & {0,256})
    mouse_pointer(1)
end procedure  -- button_down

global procedure button_press(integer but_num)
-- button press and release (using mouse-button)
    button_down(but_num)
    get_mbutton_release()
    button(but_num)
end procedure  -- button_press

global procedure add_button(sequence s1, sequence s2, sequence label)
-- add a new button to the button list and draw button
    buttons = append(buttons, {s1, s2, label})
    button(length(buttons))
end procedure  -- add_button

global procedure bullet(integer bul_num, integer set)
--  draws square button which can be set or not set
    mouse_pointer(0)
    if set then
	shadow_box({ui_colors[3], ui_colors[1]}, 5, 
		    bullets[bul_num][3], bullets[bul_num][3])
	ellipse(ui_colors[4], 1, bullets[bul_num][3]-2, bullets[bul_num][3]+2)
    else
	shadow_box({ui_colors[1], ui_colors[3]}, 5, 
		    bullets[bul_num][3], bullets[bul_num][3])
	box(ui_colors[2], 1, 3, bullets[bul_num][3], bullets[bul_num][3])
    end if
    mouse_pointer(1)
end procedure  -- bullet

global procedure add_bullet(integer set, sequence p0, sequence comment)
    integer ht
    sequence len, p1
    len = sf_length(comment)
    ht = sf_height()
    p1 = {p0[1]+len[1]+7, p0[2]}
    bullets = append(bullets, {p0-5, p1+5, p0, comment})
    bullet(length(bullets), set)
    sf_position(p0+{12, -floor(ht/2-1)})
    mouse_pointer(0)
    sf_print(comment)
    mouse_pointer(1)
end procedure  -- add_bullet

global procedure open_window(sequence p1, sequence p2)
-- draw panel after saving underlying screen image and window coords
-- windows can be stacked to any depth (memory permitting)
    winstack = prepend(winstack, buttons)
    buttons = {}
    winstack = prepend(winstack, bullets)
    bullets = {}
    mouse_pointer(0)
    image = prepend(image, {p1, save_image(p1, p2)})
    panel(p1, p2)
    mouse_pointer(1)
end procedure  -- open_window

global procedure close_window()
-- closes the last window opened and restores the screen image
    if length(image) > 0 then
	mouse_pointer(0)
	display_image(image[1][1], image[1][2])
	mouse_pointer(1)
	image = image[2..length(image)]
	bullets = winstack[1]
	buttons = winstack[2]
	winstack = winstack[3..length(winstack)]
    end if
end procedure  -- close_window
