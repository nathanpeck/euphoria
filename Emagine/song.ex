include Emagine.e

puts(1,"Press any key to end.")

set_minor_scale(49)
set_measure(.31*4)
set_play_time(.31)

constant tune = create_stream()
constant base = create_stream()

integer id

sequence play_times
sequence tune_n
sequence base_n

     tune_n = {-1,-2,-3, 5, 2,-7, 1, 2, 3,-3,-2,-1, 0}
     base_n = {-5,-4,-3,-5,-6,-7, 5, 4, 3,-3,-2,-1, 0}
 play_times = { Q, Q, H, Q, Q, H, Q, Q, H, Q, Q, H, H}

set_midi(tune,make_midi(tune_n))
set_midi(base,make_midi(base_n))

program_change(tune,16)
program_change(base,11)

while get_key() = -1 do
    id = play(tune)
    if id = -1 then
	restart(tune)
    end if
    id = play(base)
    if id = -1 then
	restart(base)
    end if
    set_play_time(play_times[get_pos(tune)])
end while
