include Emagine.e

constant tune = create_stream()
constant base_line = create_stream()
constant main_song = create_stream()

set_scale(49)

puts(1,"A funky song created by Nathan K. Peck\n")
puts(1,"using his Emagine game engine!\n\n")
puts(1,"Unlimited streams of MIDI music and\n")
puts(1,"real timing through an easy interface.\n\n")

puts(1,"Press any key to begin.\n")

while get_key() = -1 do
    
end while

puts(1,"Press any key to end.\n\n")


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
			 
set_midi(main_song,make_midi(main_s))
set_midi(base_line,make_midi(base_s))
set_midi(tune,make_midi(tune_s))

program_change(1,50)
program_change(2,4)
program_change(3,11)

integer midir
integer p
integer o

p = get_pos(main_song)
o = p

while get_key() = -1 do
    midir = play(main_song) --The main command.
    if midir = -1 then
	restart(main_song) --Start over again
    end if

    midir = play(tune) --The main command.
    if midir = -1 then
	restart(tune) --Start over again
    end if

    midir = play(base_line)
    if midir = -1 then
	restart(base_line) --at the begining.
    end if

    p = get_pos(main_song)
    
    if o != p then
	o = p
	set_play_time(play_times[p]) --Set the timing for the current not
    end if
end while

