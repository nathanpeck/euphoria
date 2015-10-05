--A basic midi library for Escreen

include mpu401.e

object junk
junk=detect_mpu401(1,-1)

if junk=-1 then
    puts(1,"Error: No MPU-401 compatible devices detected!\n")
    puts(1,"That means no nice midi music!\n\n")
end if

sequence scale

sequence musics
sequence poss
sequence onces
sequence ts

musics = {}
poss = {}
onces = {}
ts = {}

atom measure_time
atom play_time

global atom Q
global atom H
global atom W
global atom E
global atom S
global atom T

--I used the 0-2-2-1-2-2-2-1 pattern to generate this sequence of
--three scales in a row.
global procedure set_scale(integer num)
    scale = {1,3,5,6,8,10,12,13,15,17,18,20,22,24,25,27,29,30,32,34,36,37}+num
end procedure

global procedure set_minor_scale(integer num)
    scale = {1,3,4,6,8,9,11,13,15,16,18,20,21,23,25,27,28,30,32,33,35,37,39,40}+num
end procedure

global procedure sync_midi()
    atom t
    t = time()
    for counter = 1 to length(ts) do
	ts[counter] = t
    end for
--  poss[stream] = poss[stream] - remainder(poss[stream],length(musics[stream2]))-1
end procedure

global function make_midi(sequence numbers)
    sequence done
    done = {}
    for counter = 1 to length(numbers) do
	if numbers[counter] < 0 then
	    if numbers[counter] = floor(numbers[counter]) then
		done = append(done,scale[numbers[counter] * -1]) -- Hard to understand
	    else
		done = append(done,scale[floor(numbers[counter]) * -1]+1) -- Hard to understand
	end if
	elsif numbers[counter] = 0 then
	    --Do nothing
	    done = append(done,0) -- Hard to understand
	else
	if numbers[counter] = floor(numbers[counter]) then
		done = append(done,scale[7+numbers[counter]])
	    else
		done = append(done,scale[7+floor(numbers[counter])]+1)
	    end if
	end if
    end for
    return done
end function

global procedure set_play_time(atom number)
    play_time = number
end procedure

global function create_stream()
    musics = append(musics,{})
    ts = append(ts,0)
    poss = append(poss,0)
    onces = append(onces,0)
    return length(musics)
end function

global procedure set_midi(integer stream, sequence seq)
    musics[stream] = seq
    poss[stream] = 1
    onces[stream] = 0
    ts[stream] = time()
end procedure

global function get_pos(integer stream)
    return poss[stream]
end function

global procedure restart(integer stream)
    poss[stream] = 1
    onces[stream] = 0
end procedure

global procedure set_measure(atom t)
    measure_time = t
    W = t
    H = t / 2
    Q = t / 4
    E = t / 8
    S = t / 16
    T = t / 32
end procedure

global function play(integer stream)
    integer p
    atom t2
    
    p = poss[stream]
    t2 = ts[stream]
    if p > length(musics[stream]) then
	restart(stream)
    end if
    if p = 1 and onces[stream] = 0 then
	write_mpu401_data({#90+(stream-1),musics[stream][p],100})
	onces[stream] = 1
    end if
    if time()-t2 >= play_time then
	t2 = time()
	ts[stream] = t2     
	
	write_mpu401_data({#80+(stream-1),musics[stream][p],0})
	
	p = p + 1
	
	poss[stream] = p
	
	if p > length(musics[stream]) then
	    return -1
	else
	    if musics[stream][p] = 0 then
	    else
		write_mpu401_data({#90+(stream-1),musics[stream][p],100})
	    end if
	    return 1
	end if
    else
	return 1
    end if
end function

set_scale(49) --Best
