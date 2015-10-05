include musicS.e  --Escreen doesn't include this old file.

set_music(make_music({1,2,3,4,5,6,7,8,0}))

integer x

while get_key() = -1 do
    x = play_music()
    if x = -1 then
	loop_again()
    end if
end while
