include Emagine.e

constant img = load_img("backtile.img"),

	 x_dim = length(img[1])*3,
	 y_dim = length(img)
	 
constant backdrop = create_backbuffer({x_dim,y_dim})


sequence pal     pal = load_pal("backtile.pal",1)
integer y        y = 1
integer a        a = 1

clear_backbuffer(backdrop)

pal = floor(pal/4)

pal[17] = {0,0,0} --17 is the border color.  Comment this out for a yellow
		  --border

pal[256] = {24,24,40}
pal[1] = {0,0,0}

set_palette(P_BLACK)

--Draw the view in the buffer
for counter = 0 to 2 do
    buffer_display(backdrop,{counter*length(img[1])+0,0},img)
end for

copy_to_display(backdrop,{1,1})
draw_display()

fade(P_BLACK,pal,60)

while get_key() = -1 do
    y = y + a
    if y = y_dim-y2-1 then
	a = -1
    end if
    if y = 0 then
	a = 1
    end if
    copy_to_display(backdrop,{1,y})
    draw_display()
end while

fade(pal,P_BLACK,60)

