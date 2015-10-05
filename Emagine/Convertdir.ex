include image.e
include Emagine.e
include get.e
include file.e

sequence pics
sequence names

pics = {}

names = dir("*.bmp")

object inter

for counter = 1 to length(names) do
    inter = read_bitmap(names[counter][1])
    if sequence(inter) then
	pics = append(pics,inter)
    end if
end for

for counter = 1 to length(pics) do
    save_img(pics[counter][2],names[counter][1][1..length(names[counter][1])-3]&"img")
end for

--save_pal(pics[1][2],"img.pal")


