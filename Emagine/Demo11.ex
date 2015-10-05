include Emagine.e

set_minor_scale(48)

puts(1,"Press any key to begin.\n\n")

while get_key() = -1 do
    
end while

puts(1,"Press any key to end.")

constant main_song = create_stream() --Create a new stream for the song

program_change(1,11) --Set the music voice. program_change(2,18) for Piano  

set_play_time(.31) --Set the time for the first note

set_measure(.31*4) --Set the time for each measure

--Set the music loop for the stream main_song.
set_midi(main_song,make_midi({1,1,2,3,2,1,-7,-5,-5,0,1,1,2,3,5,4,2,-7,0}))


--Set the timing
--
--W = Whole note
--H = Half note
--Q = Quarter note
--E = Eight note
--S = Sixteenth note
--T = Thirtysecond note

sequence play_times
play_times = {Q,E,E,Q,E,E,Q,Q,Q,H,Q,E,E,Q,Q,Q,Q,Q,H}

integer x -- The return id    1 = still playing    -1 = done playing

while get_key() = -1 do
    x = play(main_song) --The main command.
    if x = -1 then
	restart(main_song) --Start over again at 1
    end if
    set_play_time(play_times[get_pos(main_song)]) --Set the timing for the current note
end while


