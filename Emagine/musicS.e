include graphics.e

sequence music

atom time_played
atom length_music
atom scale

integer pos

scale = 100000

--Set the music piece
global procedure set_music(sequence sounds)
    music = sounds
    length_music = length(music)
    time_played = 0
    pos = 1
end procedure

--Start over
global procedure loop_again()
    pos = 1
end procedure

--Play the current music piece
global function play_music()
    if pos = length_music+1 then
	pos = 1
	return -1
    else
	sound((music[pos][1]))
	time_played = time_played + 1
	if time_played > music[pos][2]*scale then
	    sound(0)
	    time_played = 0
	    pos = pos + 1
	end if
	return 1
    end if
end function

--Return the scale
global function mscale()
    return {
	    {523,1},
	    {587,1},
	    {659,1},
	    {698,1},
	    {784,1},
	    {880,1},
	    {987,1},
	    {1046,1}
	    }
end function

sequence music_scale

music_scale = mscale()

global function make_music(sequence numbers)
    sequence x
    
    x = {}
    
    for counter = 1 to length(numbers) do
	if numbers[counter] > 8 then
	    x = append(x,{10000,2})
	elsif numbers[counter] = 0 then
	    x = append(x,{0,1})
	else
	    x = append(x,music_scale[numbers[counter]])
	end if
    end for
    
    return x
end function
