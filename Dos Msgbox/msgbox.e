without warning

include ui.e  --The User Interface for dos.  It draws 3d boxes for me.

global constant GRAPHICS_MODE = 18

include sprite.e --This library is for drawing and creating sprites.

global sequence mouse_event
mouse_event = poll_mouse()
sequence vc            vc = video_config()
atom x_extent          x_extent = vc[VC_XPIXELS]
atom y_extent          y_extent = vc[VC_YPIXELS]
atom x
atom y

x = 1
y = 1

--Load the fonts
atom sa
atom sb
atom font

ui_colors[2] = BLACK

background(save_image({0,0},{640,480}))

--Open a centered window with a message.
global procedure alert(sequence text)
    sequence len,x,y
    sequence  mouse_events
    atom longest
    
    sequence b_x,b_y
    
    sf_select(font) --Select a font
    sf_colors({GREEN,BLUE,GREEN,GREEN}) --Set the font colors.
    mouse_events = poll_mouse()
    text = append(text,'\n')
    text = prepend(text,'\n')
    text = append(text,'\n')
    text = prepend(text,'\n')
    len = sf_length(text)
    longest = len[1]
    for counter =  1 to length(len) do
	if len[counter] > longest then
	    longest = len[counter]
	end if
    end for
    x = floor({(x_extent/2)-(longest*.5)-25,y_extent/2-length(len)*8/2})
    open_window(x, {x[1]+longest+50, x[2]+length(len)*8+90})
    mouse_pointer(0)
    shadow_box({ui_colors[3], ui_colors[1]}, 0, x+{10, 10}, {x[1]+longest+50, x[2]+length(len)*8+50}-10)
    sf_position(x+{20,5})
    sf_print(text)
    b_x = floor({x[1]+(longest/2)+5,x[2]+length(len)*8-10+60})
    b_y = floor({x[1]+(longest/2)+40+5,x[2]+length(len)*8-10+85})
    add_button(b_x,b_y,"Ok") 
    while 1 do
	if get_key() = 13 then
	    exit
	end if
	if mouse_events[1] = 0 then
	else
	    if mouse_events[2] > b_x[1] and mouse_events[2] < b_y[1] then
		if mouse_events[3] > b_x[2] and mouse_events[3] < b_y[2] then
		    exit
		end if
	    end if
	end if
	mouse_events = poll_mouse()
	mouse_pointer(1)
    end while
    button_down(length(buttons))
    while mouse_events[1] = 1 do
	mouse_events = poll_mouse()
    end while
    close_window()
end procedure

--load the fonts
sa = load_sprite("systema.sf")
sb = load_sprite("systemb.sf")
font = sb --The default font
