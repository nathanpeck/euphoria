include Escreen.e
include font.e

clear_display(0)

constant ant = 
 {{0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,8},
  {0,4,4,0,0,4,1,0},
  {4,4,4,4,4,4,4,0},
  {0,4,7,7,7,0,0,0},
  {0,7,0,7,0,7,0,0}}


integer key,mag
key = get_key()
mag = 1

while key != 27 do
    key = get_key()
    if key = 328 then
	mag = mag + 1
	clear_display(0)
	if mag = 34 then
	    mag = 33
	end if
    elsif key = 336 then
	mag = mag - 1
	clear_display(0)
	if mag = 0 then
	    mag = 1
	end if
    end if
    setx(290)
    sety(1)
    write(sprint(mag))
    setx(1)
    sety(170)
    write("Use the arrow keys to magnify,\nESC to quit.")
    display_bmp({1,1},magnify(ant,mag))
    draw_display()
end while
