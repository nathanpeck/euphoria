include image.e
include Escreen.e
include get.e

if graphics_mode(18) then
    
end if

sequence name1,name2
integer fn1

name1 = prompt_string("Please enter the name of the file to convert: ")

fn1 = open(name1,"r")
if fn1 = -1 then
    close(fn1)
    puts(1,"\nFile is non-existant!")
    abort(-1)
end if

name2 = prompt_string("Please enter the name of the result: ")

object data

data = read_bitmap(name1)

if atom(data) then
    puts(1,"\nCritical error opening bmp!\n")
    if data = BMP_UNSUPPORTED_FORMAT then
	puts(1,"You are out of luck!")
    end if
    abort(-1)
end if

save_pal(data[1],"img.pal")
save_img(data[2],name2)



