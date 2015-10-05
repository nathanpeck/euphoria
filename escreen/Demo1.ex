include Escreen.e
include image.e

without type_check
without profile
without warning

clear_display(0) --You must first clear the screen buffer.

atom t,t2,fps,frames

frames = 0

t = time()
while get_key() != 13 do
    for counter = 1 to 1000 do
	set_pixel(rand(256)-1,{rand(x2),rand(y2)}) --Set a pixel
    end for
    draw_display() --Draw the display
    frames = frames + 1
end while
t2 = time()

fps = frames/(t2-t)

puts(1,"FPS: "&sprint(fps))
 

 
 
 
 





