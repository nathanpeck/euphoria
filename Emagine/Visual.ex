include Emagine.e
include image.e

without type_check
without profile
without warning

sequence pal

pal = repeat({0,0,0},256)

for counter = 1 to floor(256/3) do
    if counter = 1 then
	
    else
	pal[counter][3] = counter-1+30
    end if
end for

for counter = floor(256/3)+1 to floor(256/3)*2 do
    if counter = 1 then
	
    else
	pal[counter][2] = counter-1-55
    end if
end for

for counter = floor(255/3)*2+1 to 256 do
    if counter = 1 then
	
    else
	pal[counter][1] = counter-1-140
    end if
end for

clear_display(0)
draw_display()

set_palette(floor(pal))

constant tune = create_stream()
constant base_line = create_stream()
constant main_song = create_stream()

set_scale(49)

set_play_time(.31) --Set the time for the first note

set_measure(.31*4) --Set the time for each measure

sequence main_s
sequence base_s
sequence tune_s
sequence play_times

    main_s = { 0, 1,-7,-6,-5,-6,-5,-6,-7, 1, 0, 5, 4, 3, 2,-1, 1, 3, 2, 1, 2,-1, 1}
    base_s = {-1,-5,-1,-5,-1,-4,-1,-4,-1, 0,-1,-5,-1,-5,-1,-5, 0,-5,-1,-5,-1,-5, 0}
play_times = { H, Q, E, E, E, Q, E, E, E, Q, E, E, E, E, E, E, Q, E, E, E, E, E, Q}

    tune_s = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}&
	     { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}&
	     { 0, 5, 0, 8, 0, 6, 0, 8, 9, 0, 5, 6, 7, 8, 9, 0, 8, 7, 6, 5, 4, 8, 0}&
	     { 0, 5, 0, 8, 0, 6, 0, 8, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}&
	     { 0, 5, 5, 8, 7, 6, 7, 8, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}&
	     { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 7, 6, 5, 4, 2, 3, 0, 0, 0, 0, 0, 0}&
	     { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 7, 6, 5, 4, 2, 3, 0, 0, 0, 0, 0, 0}&
	     { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}&
	     { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 0, 6, 0, 4, 0, 3, 0, 0, 0, 0, 0, 0}&
	     { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}&
	     { 0, 5, 0, 8, 0, 6, 7, 8, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}&
	     { 0, 5, 5, 8, 7, 6, 7, 8, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}&
	     { 0, 5, 0, 8, 0, 6, 0, 8, 9, 0, 5, 6, 7, 8, 9, 0, 8, 7, 6, 5, 4, 8, 0}&
	     { 0, 5, 5, 8, 7, 6, 7, 8, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}&
	     { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}&
	     { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 6, 7, 8, 9, 0, 8, 7, 6, 5, 4, 8, 0}&
	     { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 7, 6, 5, 4, 2, 3, 0, 0, 0, 0, 0, 0}&
	     { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}&
	     { 0, 5, 5, 8, 7, 6, 7, 8, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
			 
	     

atom tl

tl = 0

for counter = 1 to length(play_times) do
    tl = tl + play_times[counter]
end for          

tl = tl * (length(tune_s)/23)

set_midi(main_song,make_midi(main_s))
set_midi(base_line,make_midi(base_s))
set_midi(tune,make_midi(tune_s))

--Set the timing
--
--W = Whole note
--H = Half note
--Q = Quarter note
--E = Eight note
--S = Sixteenth note
--T = Thirtysecond note


integer x -- The return id    1 = still playing    -1 = done playing

x = 0

--22
--104
--78


--program_change(tune,104) --Set the music voice. program_change(2,18) for Piano  
--program_change(main_song,22) --Set the music voice. program_change(2,18) for Piano  
--program_change(base_line,16) --Set the music voice. program_change(2,18) for Piano  

program_change(tune,17) --Set the music voice. program_change(2,18) for Piano  
program_change(main_song,18) --Set the music voice. program_change(2,18) for Piano  
program_change(base_line,16) --Set the music voice. program_change(2,18) for Piano  

integer pos1,pos2,pos3

pos1 = 1
pos2 = 1
pos3 = 1

sequence bar

while get_key() = -1 do

    pos1 = main_s[pos1]
    pos2 = base_s[pos2]
    pos3 = tune_s[pos3]

    bar = repeat(pos1+10,(pos1+10)*10)

    for y = 1 to floor(y2/12) do
	set_pixel(bar,{(x2/2)-(length(bar)/2),y})
    end for

    bar = repeat(pos2+100,(pos2+10)*10)

    for y = floor(y2/12)+1 to floor(y2/12)*2 do
	set_pixel(bar,{(x2/2)-(length(bar)/2),y})
    end for

    bar = repeat(pos3+170,(pos3+10)*10)

    for y = floor(y2/12)*2+1 to floor(y2/12)*3 do
	set_pixel(bar,{(x2/2)-(length(bar)/2),y})
    end for

    bar = repeat(pos1+10,(pos1+10)*10)

    for y = floor(y2/12)*3+1 to floor(y2/12)*4 do
	set_pixel(bar,{(x2/2)-(length(bar)/2),y})
    end for

    bar = repeat(pos2+100,(pos2+10)*10)

    for y = floor(y2/12)*4+1 to floor(y2/12)*5 do
	set_pixel(bar,{(x2/2)-(length(bar)/2),y})
    end for

    bar = repeat(pos3+170,(pos3+10)*10)

    for y = floor(y2/12)*5+1 to floor(y2/12)*6 do
	set_pixel(bar,{(x2/2)-(length(bar)/2),y})
    end for
    bar = repeat(pos1+10,(pos1+10)*10)
    
    for y = floor(y2/12)*6+1 to floor(y2/12)*7 do
	set_pixel(bar,{(x2/2)-(length(bar)/2),y})
    end for

    bar = repeat(pos2+100,(pos2+10)*10)

    for y = floor(y2/12)*7+1 to floor(y2/12)*8 do
	set_pixel(bar,{(x2/2)-(length(bar)/2),y})
    end for

    bar = repeat(pos3+170,(pos3+10)*10)

    for y = floor(y2/12)*8+1 to floor(y2/12)*9 do
	set_pixel(bar,{(x2/2)-(length(bar)/2),y})
    end for

    bar = repeat(pos1+10,(pos1+10)*10)

    for y = floor(y2/12)*9+1 to floor(y2/12)*10 do
	set_pixel(bar,{(x2/2)-(length(bar)/2),y})
    end for

    bar = repeat(pos2+100,(pos2+10)*10)

    for y = floor(y2/12)*10+1 to floor(y2/12)*11 do
	set_pixel(bar,{(x2/2)-(length(bar)/2),y})
    end for

    bar = repeat(pos3+170,(pos3+10)*10)

    for y = floor(y2/12)*11+1 to floor(y2/12)*12 do
	set_pixel(bar,{(x2/2)-(length(bar)/2),y})
    end for

    draw_display()

    --clear_display(pos3)
    clear_display(0)

    x = play(main_song) --The main command.
    if x = -1 then
	restart(main_song) --Start over again
    end if

    x = play(tune) --The main command.
    if x = -1 then
	restart(tune) --Start over again
    end if

    x = play(base_line)
    if x = -1 then
	restart(base_line) --at the begining.
    end if
    
    pos1 = get_pos(main_song)
    pos2 = get_pos(base_line)
    pos3 = get_pos(tune)
    
    set_play_time(play_times[pos1]) --Set the timing for the current not
    
end while
 

 
 
 
 





