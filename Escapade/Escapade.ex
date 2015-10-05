--------------------------------------------------------------------------------
-- Program : Escapade.ex
--
-- Author :
--
-- Description : A remarkably simple, nonviolent platform game.
--

--To make this game educational go to --QUESTIONS in main()
--and follow the instructions.

include Emagine.e

clear_display(0) --Clear the graphics display buffer

sequence startup_img
integer bar_pos                 bar_pos = 0

--This draws the title
procedure title()
    startup_img = {0,0}
    startup_img[2] = load_img("Escapade.img")
    startup_img[1] = load_pal("startup.pal",1)

    startup_img[1][26] = {0,255,0}         --pants

    display_bmp({floor(x2/2-(length(startup_img[2][1])/2)),floor(y2/2-floor(length(startup_img[2])/2))-25},startup_img[2]) --
    draw_display()

    set_palette(startup_img[1])
end procedure

title()

atom t

t = time()
while t + .5 > time() do
    --Wait for the monitor to clear.
end while

--This draws a progress bar
procedure bar()

    for counter = 10 to 15 do
	set_pixel(repeat(3,100),{(x2/2)-63,y2-counter})
    end for

    for counter = 10 to 15 do
	set_pixel(repeat(10,floor((bar_pos*100)/148)),{(x2/2)-63,y2-counter})
    end for

    bar_pos = bar_pos + 1
    draw_display()
end procedure

include keyread.e
bar()
include keyb.e
bar()
include font.e
bar()
include stuff.e
bar()
include file.e
bar()
include misc.e
bar()
include get.e
bar()
include database.e
bar()

--Make it a bit faster!
without type_check
without profile
without warning

integer level_num               level_num = 1
integer moving_up               moving_up = 0
integer moving_right            moving_right = 0
integer moving_down             moving_down = 0
integer moving_left             moving_left = 0
integer still_running           still_running = -1
integer extent_x                extent_x = 128*40+2 --The x extent of the buffer
integer extent_y                extent_y = 128*4+1 --The y extent of the buffer
integer frames                  frames = 0
integer offset_x                offset_x = 0
integer offset_y                offset_y = 0
integer key                     key = -1
integer jumping                 jumping = 0 --Can or can not the character jump?
integer lives                   lives = 5
integer b1                      b1 = 0
integer b2                      b2 = 0
integer b3                      b3 = 0
integer last_x                  last_x = 0
integer last_y                  last_y = 0
integer last_x2                 last_x2 = 0
integer last_y2                 last_y2 = 0

atom t2
atom fn
atom ani                        ani = 1
atom time2
atom x_pos                      x_pos = 1
atom y_pos                      y_pos = 1
atom x                          x = 1
atom y                          y = 1
atom scroll                     scroll = 5 --Distance to scroll with each key press
atom energy                     energy = 100
atom points                     points = 0

sequence levels
sequence pic_index
sequence current_animation
sequence actives                actives = {}
sequence keys
sequence pal
sequence new_pal
sequence nums
sequence global_objects         global_objects = repeat(repeat(0,floor((127*40)/32)),floor((127*4)/32)+1)
sequence lights                 lights = {0,0,0}
sequence scores                 scores = {}
sequence xsprite                xsprite = {}

object pic

fn = open("scores","r")

if fn = -1 then
    fn = open("scores","w")
    close(fn)
    fn = open("scores","r")
end if

scores = get(fn)

if scores[1] = GET_SUCCESS then
    scores = scores[2]
else
    scores = {}
end if

close(fn)

lights = {0,0,0}
keyboard_lights(lights) --Clear the keyboard lights.

constant gravity = .1

constant name = "Nathan K. Peck",  --Authors name
	 backdrop = create_backbuffer({extent_x,extent_y}), --Create the backdrop buffer.

	 --This is the set of colors used in the backdrop image (52on added later)
	 back_colors = {17,18,20,28,21,19,23,22,25,24,255,27,29,98,82,57},
	 bad_colors = {93,94,95,96,97},  --Colors you don't want to stand on!
	 guy_colors = {256,255,254,254,252,251,250,249,248,247,246,245,244,243,242}

clear_backbuffer(backdrop)

--This is the question database
constant questions =
{
"What is the capital of: ",
{
"Maine\n\n",
"New Hampshire\n\n",
"Massachusetts\n\n",
"New York\n\n",
"Rhode Island\n\n",
"Connecticut\n\n",
"New Jersy\n\n",
"Pennsylvania\n\n",
"Vermont\n\n",
"Texas\n\n",
"Louisiana\n\n",
"Arkansas\n\n",
"Missisippi\n\n",
"Alabama\n\n",
"Florida\n\n",
"Georgia\n\n",
"South Carolina\n\n",
"North Carolina\n\n",
"Tennessee\n\n",
"Kentucky\n\n",
"Virginia\n\n",
"West Virginia\n\n",
"Delaware\n\n",
"Maryland\n\n",
"North Dakota\n\n",
"South Dakota\n\n",
"Nebraska\n\n",
"Kansas\n\n",
"Missouri\n\n",
"Iowa\n\n",
"Minnesota\n\n",
"Wisconsin\n\n",
"Illinois\n\n",
"Indiana\n\n",
"Ohio\n\n",
"Michigan\n\n",
"New Mexico\n\n",
"Arizona\n\n",
"Colorado\n\n",
"Utah\n\n",
"Wyoming\n\n",
"Montana\n\n",
"Idaho\n\n",
"Washington\n\n",
"Oregon\n\n",
"Nevada\n\n",
"California\n\n",
"Hawaii\n\n",
"Alaska\n\n",
"Oklahoma\n\n"
},
{
"Augusta\n",
"Concord\n",
"Boston\n",
"Albany\n",
"Providence\n",
"Hartford\n",
"Trenton\n",
"Harrisburg\n",
"Montpelier\n",
"Austin\n",
"Baton Rouge\n",
"Little Rock\n",
"Jackson\n",
"Montgomery\n",
"Tallahassee\n",
"Atlanta\n",
"Columbia\n",
"Raleigh\n",
"Nashville\n",
"Frankfort\n",
"Richmond\n",
"Charleston\n",
"Dover\n",
"Annapolis\n",
"Bismark\n",
"Pierre\n",
"Lincoln\n",
"Topeka\n",
"Jefferson City\n",
"Des Moines\n",
"Saint Paul\n",
"Madison\n",
"Springfield\n",
"Indianapolis\n",
"Columbus\n",
"Lansing\n",
"Santa Fe\n",
"Phoenix\n",
"Denver\n",
"Salt Lake City\n",
"Cheyenne\n",
"Helana\n",
"Boise\n",
"Olympia\n",
"Salem\n",
"Carson City\n",
"Sacramento\n",
"Honolulu\n",
"Juneau\n",
"Oklahoma City\n"
}-- page 131 Geography
}

--MIDI Junk
set_scale(49)

program_change(1,123)

set_play_time(.31) --Set the time for the first note

set_measure(.31*4) --Set the time for each measure

sequence play_times

function create(integer l)
    sequence done
    done = repeat(0,l)
    play_times = repeat(Q,l)
    for counter = 1 to length(done) do
	if rand(15) = 7 then
	    done[counter] = rand(16)-8
	    play_times[counter] = W+((rand(300)-200)/100)
	end if
    end for
    return done
end function

constant birds = create_stream()

sequence bird_song

bird_song = create(100)

restart(birds)

set_midi(birds,make_midi(bird_song))

integer midir -- The return id    1 = still playing    -1 = done playing

midir = 0

integer highest

highest = 0

procedure progress(integer num)

    if num > highest then --This makes the progress bar solid, not jerky.
	highest = num
    else num = highest
    end if

    clear_display(0)

    sety(75)
    setx(113)

    write("Processing..")

    num = floor(num*100/160)+1 --Ratio

    for counter = 1 to 10 do
	set_pixel(repeat(5,num),{floor(x2/2-50),100+counter})
    end for

    draw_display()
end procedure

procedure action()

end procedure

global constant GENERATE_PROGRESS = routine_id("progress"),
		ACTION = routine_id("action")

bar()

include g.e --Finally

bar()

function load_level(sequence name)
    integer level_x,level_y
    sequence level_objects
    if db_open(name,DB_LOCK_NO) != DB_OK then
	puts(1,"Error opening file!")
	while get_key() = -1 do
	    --Wait for key
	end while
	abort(-1)
    else
	if db_select_table("POSITION") = DB_OK then
	    level_x = db_record_data(1)
	    level_y = db_record_data(2)
	    if db_select_table("LEVEL_OBJECTS") = DB_OK then
		level_objects = db_record_data(1)
		db_close()
	    else
		puts(1,"Level error!")
		while get_key() = -1 do
		    --Wait for key
		end while
		abort(-1)
	    end if
	else
	    puts(1,"Level error!")
	    while get_key() = -1 do
		--Wait for key
	    end while
	    abort(-1)
	end if
    end if
    return {level_x,level_y,level_objects}
end function

--This is called to load the pictures
procedure start_up()

    --Load the palette
    pal = load_pal("Escapade.pal",1)
    if atom(pal) then
	if pal = -1 then
	    puts(1,"Unable to the load palette!\nPlease reinstall.")
	    abort(1)
	end if
    end if
    pal = pal/4  --Scale the palette
    pal[17] = {0,0,0}

    --Load the background images
    pic_index = {}
    pic_index = append(pic_index,load_img("backtile.img"))
    bar()
    pic_index = append(pic_index,load_img("p1.img"))
    bar()
    pic_index = append(pic_index,load_img("p2.img"))
    bar()
    pic_index = append(pic_index,load_img("p3.img"))
    bar()
    pic_index = append(pic_index,load_img("p4.img"))
    bar()
    pic_index = append(pic_index,load_img("pend1.img"))
    bar()
    pic_index = append(pic_index,load_img("pend2.img"))
    bar()
    pic_index = append(pic_index,load_img("end1.img"))
    bar()
    pic_index = append(pic_index,load_img("end2.img"))
    bar()
    pic_index = append(pic_index,load_img("b1.img"))
    bar()
    pic_index = append(pic_index,load_img("b2.img"))
    bar()
    pic_index = append(pic_index,load_img("wall_e1.img"))
    bar()
    pic_index = append(pic_index,load_img("wall_e2.img"))
    bar()
    pic_index = append(pic_index,load_img("wall1.img"))
    bar()
    pic_index = append(pic_index,load_img("wall2.img"))
    bar()
    pic_index = append(pic_index,load_img("we1.img"))
    bar()
    pic_index = append(pic_index,load_img("water.img"))
    bar()
    pic_index = append(pic_index,load_img("we2.img"))
    bar()
    pic_index = append(pic_index,load_img("edge1.img"))
    bar()
    pic_index = append(pic_index,load_img("edge2.img"))
    bar()
    pic_index = append(pic_index,load_img("web1.img"))
    bar()
    pic_index = append(pic_index,load_img("web2.img"))
    bar()
    pic_index = append(pic_index,load_img("w1.img"))
    bar()
    pic_index = append(pic_index,load_img("w2.img"))
    bar()
    pic_index = append(pic_index,load_img("b1a.img"))
    bar()
    pic_index = append(pic_index,load_img("b1b.img"))
    bar()
    pic_index = append(pic_index,load_img("b2a.img"))
    bar()
    pic_index = append(pic_index,load_img("b2b.img"))
    bar()
    pic_index = append(pic_index,load_img("b3a.img"))
    bar()
    pic_index = append(pic_index,load_img("b3b.img"))
    bar()
    pic_index = append(pic_index,load_img("50.img"))
    bar()
    pic_index = append(pic_index,load_img("25.img"))
    bar()
    pic_index = append(pic_index,load_img("stump.img"))
    bar()
    pic_index = append(pic_index,load_img("pplant.img"))
    bar()
    pic_index = append(pic_index,load_img("gplant.img"))
    bar()
    pic_index = append(pic_index,load_img("rock1.img"))
    bar()
    pic_index = append(pic_index,load_img("rock2.img"))
    bar()
    pic_index = append(pic_index,load_img("h1.img"))
    bar()
    pic_index = append(pic_index,load_img("h2.img"))
    bar()

    for y = 1 to length(pic_index[33]) do
	for x = 1 to length(pic_index[33][y]) do
	    if pic_index[33][y][x] = 4 then
		pic_index[33][y][x] = 5
	    end if
	end for
    end for

    bar()

    for counter = 2 to length(pic_index) do
	for y = 1 to length(pic_index[counter]) do
	    for x = 1 to length(pic_index[counter][y]) do
		if pic_index[counter][y][x] <= -1 then
		    pic_index[counter][y][x] = 0
		elsif pic_index[counter][y][x] >= 256 then
		    pic_index[counter][y][x] = 255
		end if
	    end for
	end for
    end for

    bar()

end procedure

--This function turns alphabet information into a colored picture.
function make_picture(sequence pic)
    object done
    bar()
    done = repeat(repeat(0,length(pic[1])),length(pic))
    for y9 = 1 to length(pic) do
	for x9 = 1 to length(pic[y9]) do
	    if pic[y9][x9] = 32 then
		done[y9][x9] = 0
	    else
		done[y9][x9] = 256-(pic[y9][x9]-(96)) --Convert the alahabet letter
						      --to a number.
	    end if
	end for
    end for
    bar()
    return done
end function

--This reverses every frame of an animation
function reverse_animation(sequence animation)
    for counter = 1 to length(animation) do
	for y = 1 to length(animation[counter]) do
	    animation[counter][y] = reverse(animation[counter][y])
	end for
	bar()
    end for
    return animation
end function

--The character animations
sequence guy_walking_right
sequence guy_stopped_right
sequence guy_walking_left
sequence guy_stopped_left
sequence guy_waving_right
sequence guy_waving_left

--The backdrop pictures (Processed)
sequence pics

start_up()

--PICTURES

--Make the guy animations
guy_waving_right = {
make_picture(
{
"     aaaaaaaaa      ",
"    aaaaaaaaaaa     ",
"   aaaaaaaaaaaaaa   ",
"    bbbbbbbbccc     ",
"   bbbbcccccccc     ",
"   bbbcccccdccd     ",
"    bbccccccccc     ",
"     bcccceeee      ",
"      bccccee       ",
"       ccccc        ",
"     ffffffff       ",
"    ffffffffff      ",
"   fffggggffff      ",
"   ffggggggfff    h ",
"   fffgggggggggggghh",
"   ffffggggggggggghh",
"    ffffffffff      ",
"   lllllllllll      ",
"    lllllllll       ",
"    llllllll        ",
"    llllllll        ",
"     lllllll        ",
"     lllllll        ",
"      lllll         ",
"       lll          ",
"      kkkkkkk       ",
"      kkkkkkk       ",
"      kkkkkkk       "
}
),
make_picture(
{
"     aaaaaaaaa      ",
"    aaaaaaaaaaa     ",
"   aaaaaaaaaaaaa    ",
"    bbbbbbbbccc     ",
"   bbbccccccccc     ",
"   bbcccccdccdc     ",
"    bbccccccccc     ",
"     bccceeeec      ",
"      bccceec       ",
"       ccccc        ",
"     ffffffff       ",
"    ffffffffff      ",
"   fffggggffff      ",
"   ffggggggfff    h ",
"   fffgggggggggggghh",
"   ffffggggggggggghh",
"    ffffffffff      ",
"   lllllllllll      ",
"    lllllllll       ",
"    llllllll        ",
"    llllllll        ",
"     lllllll        ",
"     lllllll        ",
"      lllll         ",
"       lll          ",
"      kkkkkkk       ",
"      kkkkkkk       ",
"      kkkkkkk       "
}
),
make_picture(
{
"     aaaaaaaaa      ",
"    aaaaaaaaaaa     ",
"   aaaaaaaaaaaaa    ",
"    bbbbbcccccb     ",
"   bbcccccccccc     ",
"   bccccdccdccc     ",
"    bcccccccccc     ",
"     bcceeeeec      ",
"      bcceeec       ",
"       ccccc        ",
"     ffffffff       ",
"    ffffffffff      ",
"   fffggggffff      ",
"   ffggggggfff    h ",
"   fffgggggggggggghh",
"   ffffggggggggggghh",
"    ffffffffff      ",
"   lllllllllll      ",
"    lllllllll       ",
"    llllllll        ",
"    llllllll        ",
"     lllllll        ",
"     lllllll        ",
"      lllll         ",
"       lll          ",
"      kkkkkkk       ",
"      kkkkkkk       ",
"      kkkkkkk       "
}
),
make_picture(
{
"     aaaaaaaaa      ",
"    aaaaaaaaaaa     ",
"   aaaaaaaaaaaaa    ",
"    bcccccccccb     ",
"   bccccccccccb     ",
"   bcccdccdcccb     ",
"    bcccccccccc     ",
"     cceeeeecc      ",
"      cceeecc       ",
"       ccccc        ",
"     ffffffff       ",
"    ffffffffff      ",
"   fffggggffff      ",
"   ffggggggfff    h ",
"   fffgggggggggggghh",
"   ffffggggggggggghh",
"    ffffffffff      ",
"   lllllllllll      ",
"    lllllllll       ",
"    llllllll        ",
"    llllllll        ",
"     lllllll        ",
"     lllllll        ",
"      lllll         ",
"       lll          ",
"      kkkkkkk       ",
"      kkkkkkk       ",
"      kkkkkkk       "
}
),
make_picture(
{
"     aaaaaaaaa      ",
"    aaaaaaaaaaa     ",
"   aaaaaaaaaaaaa    ",
"    bcccccccccb     ",
"   bccccccccccb     ",
"   bcccdccdcccb     ",
"    bcccccccccc     ",
"     cceeeeecc      ",
"      cceeecc       ",
"       ccccc        ",
"     ffffffff       ",
"    ffffffffff      ",
"   fffggggffff      ",
"   ffggggggfff    h ",
"   fffgggggggggggghh",
"   ffffggggggggggghh",
"    ffffffffff      ",
"   lllllllllll      ",
"    lllllllll       ",
"    llllllll        ",
"    llllllll        ",
"     lllllll        ",
"     lllllll        ",
"      lllll         ",
"       lll          ",
"      kkkkkkk       ",
"      kkkkkkk       ",
"      kkkkkkk       "
}
),
make_picture(
{
"     aaaaaaaaa      ",
"    aaaaaaaaaaa     ",
"   aaaaaaaaaaaaa    ",
"    bbbbbbccccb     ",
"   bbcccccccccc     ",
"   bcccccdccdcc     ",
"    bcccccccccc     ",
"     bcceeeeec      ",
"      bcceeec       ",
"       ccccc        ",
"     ffffffff       ",
"    ffffffffff      ",
"   fffggggffff      ",
"   ffggggggfff    h ",
"   fffgggggggggggghh",
"   ffffggggggggggghh",
"    ffffffffff      ",
"   lllllllllll      ",
"    lllllllll       ",
"    llllllll        ",
"    llllllll        ",
"     lllllll        ",
"     lllllll        ",
"      lllll         ",
"       lll          ",
"      kkkkkkk       ",
"      kkkkkkk       ",
"      kkkkkkk       "
}
),
make_picture(
{
"     aaaaaaaaa      ",
"    aaaaaaaaaaa     ",
"   aaaaaaaaaaaaaa   ",
"    bbbbbbbbccc     ",
"   bbbbcccccccc     ",
"   bbbcccccdccd     ",
"    bbccccccccc     ",
"     bcccceeee      ",
"      bccccee       ",
"       ccccc        ",
"     ffffffff       ",
"    ffffffffff      ",
"   fffggggffff      ",
"   ffggggggfff    h ",
"   fffgggggggggggghh",
"   ffffggggggggggghh",
"    ffffffffff      ",
"   lllllllllll      ",
"    lllllllll       ",
"    llllllll        ",
"    llllllll        ",
"     lllllll        ",
"     lllllll        ",
"      lllll         ",
"       lll          ",
"      kkkkkkk       ",
"      kkkkkkk       ",
"      kkkkkkk       "
}
)
}

guy_stopped_right = {

make_picture(
{
"     aaaaaaaaa      ",
"    aaaaaaaaaaa     ",
"   aaaaaaaaaaaaaaa  ",
"    bbbbbbbbbbb     ",
"   bbbbbccccccc     ",
"   bbbbcccccdcc     ",
"    bbbccccccccc    ",
"     bbcccceee      ",
"      bccccce       ",
"       ccccc        ",
"     ffffffff       ",
"    ffffffffff      ",
"   fffggggffff      ",
"   ffggggggfff    h ",
"   fffgggggggggggghh",
"   ffffggggggggggghh",
"    ffffffffff      ",
"   lllllllllll      ",
"    lllllllll       ",
"    llllllll        ",
"    llllllll        ",
"     lllllll        ",
"     lllllll        ",
"      lllll         ",
"       lll          ",
"      kkkkkkk       ",
"      kkkkkkk       ",
"      kkkkkkk       "
}
),
make_picture(
{
"     aaaaaaaaa      ",
"    aaaaaaaaaaa     ",
"   aaaaaaaaaaaaaaa  ",
"    bbbbbbbbbbb     ",
"   bbbbbccccccc     ",
"   bbbbcccccdcc     ",
"    bbbccccccccc    ",
"     bbcccceee      ",
"      bccccce       ",
"       ccccc        ",
"     ffffffff       ",
"    ffffffffff      ",
"   fffggggffff      ",
"   ffggggggfff    h ",
"   fffgggggggggggghh",
"   ffffggggggggggghh",
"    ffffffffff      ",
"   lllllllllll      ",
"    lllllllll       ",
"    llllllll        ",
"    llllllll        ",
"     lllllll        ",
"     lllllll        ",
"      lllll         ",
"       lll          ",
"      kkkkkkk       ",
"      kkkkkkk       ",
"      kkkkkkk       "
}
)
}

guy_walking_right = {

make_picture(
{
"     aaaaaaaaa      ",
"    aaaaaaaaaaa     ",
"   aaaaaaaaaaaaaaa  ",
"    bbbbbbbbbbb     ",
"   bbbbbccccccc     ",
"   bbbbcccccdcc     ",
"    bbbccccccccc    ",
"     bbcccceee      ",
"      bccccce       ",
"       ccccc        ",
"     ffffffff       ",
"    ffffffffff      ",
"   fffggggffff      ",
"   ffggggggfff    h ",
"   fffgggggggggggghh",
"   ffffggggggggggghh",
"    ffffffffff      ",
"   lllllllllll      ",
"    lllllllll       ",
"    llllllll        ",
"    llllllll        ",
"     lllllll        ",
"     lllllll        ",
"      lllll         ",
"       lll          ",
"      kkkkkkk       ",
"      kkkkkkk       ",
"      kkkkkkk       "
}
),
make_picture(
{
"     aaaaaaaaa      ",
"    aaaaaaaaaaa     ",
"   aaaaaaaaaaaaaaa  ",
"    bbbbbbbbbbb     ",
"   bbbbbccccccc     ",
"   bbbbcccccdcc     ",
"    bbbccccccccc    ",
"     bbcccceee      ",
"      bccccce       ",
"       ccccc        ",
"     ffffffff       ",
"    ffffffffff      ",
"   fffggggffff      ",
"   ffggggggfff    h ",
"   fffgggggggggggghh",
"   ffffggggggggggghh",
"    ffffffffff      ",
"   lllllllllll      ",
"    lllllllll       ",
"    lllllllll       ",
"    lllllllll       ",
"    lllllllll       ",
"    lllllllll       ",
"    llllllllll      ",
"   llllll lllll     ",
"   kkkkk  kkkkkk    ",
"   kkkkkk kkkkkk    ",
"   kkkkkk kkkkkk    "
}
),
make_picture(
{
"     aaaaaaaaa      ",
"    aaaaaaaaaaa     ",
"   aaaaaaaaaaaaaaa  ",
"    bbbbbbbbbbb     ",
"   bbbbbccccccc     ",
"   bbbbcccccdcc     ",
"    bbbccccccccc    ",
"     bbcccceee      ",
"      bccccce       ",
"       ccccc        ",
"     ffffffff       ",
"    ffffffffff      ",
"   fffggggffff      ",
"   ffggggggfff    h ",
"   fffgggggggggggghh",
"   ffffggggggggggghh",
"    ffffffffff      ",
"   lllllllllll      ",
"    lllllllll       ",
"    lllllllll       ",
"    lllllllll       ",
"    llllllllll      ",
"    lllll llll      ",
"    lllll lllll     ",
"   llllll  lllll    ",
"   kkkkk   kkkkkk   ",
"   kkkkkk  kkkkkk   ",
"   kkkkkk  kkkkkk   "
}
),
make_picture(
{
"     aaaaaaaaa      ",
"    aaaaaaaaaaa     ",
"   aaaaaaaaaaaaaaa  ",
"    bbbbbbbbbbb     ",
"   bbbbbccccccc     ",
"   bbbbcccccdcc     ",
"    bbbccccccccc    ",
"     bbcccceee      ",
"      bccccce       ",
"       ccccc        ",
"     ffffffff       ",
"    ffffffffff      ",
"   fffggggffff      ",
"   ffggggggfff    h ",
"   fffgggggggggggghh",
"   ffffggggggggggghh",
"    ffffffffff      ",
"   lllllllllll      ",
"    lllllllll       ",
"    lllllllll       ",
"    lllllllll       ",
"    llllllllll      ",
"   lllll  llll      ",
"   lllll  lllll     ",
"  llllll   lllll    ",
"  kkkkk    kkkkkk   ",
"  kkkkkk   kkkkkk   ",
"  kkkkkk   kkkkkk   "
}
),
make_picture(
{
"     aaaaaaaaa      ",
"    aaaaaaaaaaa     ",
"   aaaaaaaaaaaaaaa  ",
"    bbbbbbbbbbb     ",
"   bbbbbccccccc     ",
"   bbbbcccccdcc     ",
"    bbbccccccccc    ",
"     bbcccceee      ",
"      bccccce       ",
"       ccccc        ",
"     ffffffff       ",
"    ffffffffff      ",
"   fffggggffff      ",
"   ffggggggfff    h ",
"   fffgggggggggggghh",
"   ffffggggggggggghh",
"    ffffffffff      ",
"   lllllllllll      ",
"    lllllllll       ",
"    lllllllll       ",
"    lllllllll       ",
"    llllllllll      ",
"    lllll llll      ",
"    lllll lllll     ",
"   llllll  lllll    ",
"   kkkkk   kkkkkk   ",
"   kkkkkk  kkkkkk   ",
"   kkkkkk  kkkkkk   "
}
),
make_picture(
{
"     aaaaaaaaa      ",
"    aaaaaaaaaaa     ",
"   aaaaaaaaaaaaaaa  ",
"    bbbbbbbbbbb     ",
"   bbbbbccccccc     ",
"   bbbbcccccdcc     ",
"    bbbccccccccc    ",
"     bbcccceee      ",
"      bccccce       ",
"       ccccc        ",
"     ffffffff       ",
"    ffffffffff      ",
"   fffggggffff      ",
"   ffggggggfff    h ",
"   fffgggggggggggghh",
"   ffffggggggggggghh",
"    ffffffffff      ",
"   lllllllllll      ",
"    lllllllll       ",
"    lllllllll       ",
"    lllllllll       ",
"    lllllllll       ",
"    lllllllll       ",
"    llllllllll      ",
"   llllll lllll     ",
"   kkkkk  kkkkkk    ",
"   kkkkkk kkkkkk    ",
"   kkkkkk kkkkkk    "
}
),
make_picture(
{
"     aaaaaaaaa      ",
"    aaaaaaaaaaa     ",
"   aaaaaaaaaaaaaaa  ",
"    bbbbbbbbbbb     ",
"   bbbbbccccccc     ",
"   bbbbcccccdcc     ",
"    bbbccccccccc    ",
"     bbcccceee      ",
"      bccccce       ",
"       ccccc        ",
"     ffffffff       ",
"    ffffffffff      ",
"   fffggggffff      ",
"   ffggggggfff    h ",
"   fffgggggggggggghh",
"   ffffggggggggggghh",
"    ffffffffff      ",
"   lllllllllll      ",
"    lllllllll       ",
"    llllllll        ",
"    llllllll        ",
"     lllllll        ",
"     lllllll        ",
"      lllll         ",
"       lll          ",
"      kkkkkkk       ",
"      kkkkkkk       ",
"      kkkkkkk       "
}
)
}

--Make the backdrop pictures
integer clear

clear = pic_index[2][1][1]

pics = {}

pics = append(pics,add_sprite(pic_index[2],clear)) --Platform 1
bar()
pics = append(pics,add_sprite(pic_index[3],clear)) --Platform 2
bar()
pics = append(pics,add_sprite(pic_index[4],clear)) --Platform 3
bar()
pics = append(pics,add_sprite(pic_index[5],clear)) --Platform 4
bar()
pics = append(pics,add_sprite(pic_index[6],clear)) --Platform end left
bar()
pics = append(pics,add_sprite(pic_index[7],clear)) --Platform end right
bar()
pics = append(pics,add_sprite(pic_index[8],pic_index[8][32][32])) --Bottom end left
bar()
pics = append(pics,add_sprite(pic_index[9],pic_index[9][32][32])) --Bottom end right
bar()
pics = append(pics,add_sprite(pic_index[10],pic_index[10][32][32])) --Bottom 1
bar()
pics = append(pics,add_sprite(pic_index[11],pic_index[11][32][32])) --Bottom 2
bar()
pics = append(pics,add_sprite(pic_index[16],pic_index[16][1][32])) --Water edge left
bar()
pics = append(pics,add_sprite(pic_index[17],pic_index[17][1][1])) --Water
bar()
pics = append(pics,add_sprite(pic_index[18],pic_index[18][1][1])) --Water edge right
bar()
pics = append(pics,add_sprite(pic_index[12],pic_index[12][32][1]))  --Wall end 1
bar()
pics = append(pics,add_sprite(pic_index[13],pic_index[13][32][32]))    --Wall end 2
bar()
pics = append(pics,add_sprite(pic_index[14],0)) --Wall 1
bar()
pics = append(pics,add_sprite(pic_index[15],0)) --Wall 2
bar()
pics = append(pics,add_sprite(pic_index[19],pic_index[19][1][32])) --Wall edge right
bar()
pics = append(pics,add_sprite(pic_index[20],pic_index[20][1][1])) --Wall edge left
bar()
pics = append(pics,add_sprite(pic_index[21],pic_index[21][1][32])) --Wall edge bottom right
bar()
pics = append(pics,add_sprite(pic_index[22],pic_index[22][1][1])) --Wall edge bottom left
bar()
pics = append(pics,add_sprite(pic_index[23],pic_index[23][1][1])) --Fly 1
bar()
pics = append(pics,add_sprite(pic_index[24],pic_index[24][1][1])) --Fly 2
bar()
pics = append(pics,add_sprite(pic_index[25],pic_index[25][1][1])) --butterfly 1
bar()
pics = append(pics,add_sprite(pic_index[26],pic_index[26][1][1])) --butterfly 1
bar()
pics = append(pics,add_sprite(pic_index[27],pic_index[27][1][1])) --butterfly 2
bar()
pics = append(pics,add_sprite(pic_index[28],pic_index[28][1][1])) --butterfly 2
bar()
pics = append(pics,add_sprite(pic_index[29],pic_index[29][1][1])) --butterfly 3
bar()
pics = append(pics,add_sprite(pic_index[30],pic_index[30][1][1])) --butterfly 3
bar()
pics = append(pics,add_sprite(pic_index[31],pic_index[31][1][1])) --The 50 points image
bar()
pics = append(pics,add_sprite(pic_index[32],pic_index[32][1][1])) --The 25 points image
bar()
pics = append(pics,add_sprite(pic_index[33],5)) --The stump image
bar()
pics = append(pics,add_sprite(pic_index[34],pic_index[34][1][1])) --The purple plant image
bar()
pics = append(pics,add_sprite(pic_index[35],pic_index[35][1][1])) --The green plant image
bar()
pics = append(pics,add_sprite(pic_index[36],pic_index[36][1][1])) --rock1
bar()
pics = append(pics,add_sprite(pic_index[37],pic_index[37][1][1])) --rock2
bar()
pics = append(pics,add_sprite(pic_index[38],pic_index[38][1][1])) --h1
bar()
pics = append(pics,add_sprite(pic_index[39],pic_index[39][2][1])) --h2
bar()

--Reverse the animations
guy_walking_left = reverse_animation(guy_walking_right)
guy_waving_left = reverse_animation(guy_waving_right)
guy_waving_right = reverse_animation(guy_waving_left) --I have to do this for some weird reason!
guy_stopped_left = reverse_animation(guy_stopped_right)

function translate(sequence data)
    sequence done
    done = {}
    for counter = 1 to length(data) do
	done = append(done,add_sprite(data[counter],data[counter][1][1]))
    end for
    return done
end function

constant guy_wl = translate(guy_walking_left),
	 guy_wr = translate(guy_walking_right),
	 guy_xr = translate(guy_waving_right),
	 guy_xl = translate(guy_waving_left),
	 guy_sr = translate(guy_stopped_right),
	 guy_sl = translate(guy_stopped_left)

xsprite = guy_sr

current_animation = guy_stopped_right

--These are the centered character positions
constant guy_pos_x = floor(x2/2)-floor(length(guy_walking_right[1][1])/2),
	 guy_pos_y = floor(y2/2)-floor(length(guy_walking_left[1])/2)

--MAIN CODE

procedure play_music()
    midir = play(birds)
    if midir = -1 then
	set_midi(birds,make_midi(create(100)))
	restart(birds)
    end if
    set_play_time(play_times[get_pos(birds)])
end procedure

--This procedure draws a frame from a guy animation.
--It centers it as close as possible to the center of the screen.
procedure animate_char()
    ani = remainder(frames,length(current_animation)*10)/10+1
    if ani > length(current_animation) then
	ani = length(current_animation)
    elsif ani = 0 then
	ani = 1
    end if
    draw_sprite({guy_pos_x+offset_x,guy_pos_y+offset_y},xsprite[ani])
end procedure

atom r,r2,r3,r4,pos

function good_rand(integer top)
    integer running,num
    running = 1

    while running = 1 do
	num = rand(top)
	if num = r then
	elsif num = r2 then
	elsif num = r3 then
	elsif num = r4 then
	else
	    running = -1
	end if
    end while

    return num
end function

procedure wait()
    atom t
    t = time()
    while t+.25 > time() do

    end while
end procedure

procedure question_geo()
    integer getting
    copy_to_display(backdrop,{x,y})

    r = 0
    r2 = 0
    r3 = 0
    r4 = 0

    setx(10)
    sety(10)
    r = rand(50)

    write(questions[1]&questions[2][r])

    setx(10)
    sety(30)

    r2 = good_rand(50)
    r3 = good_rand(50)
    r4 = good_rand(50)

    pos = rand(4)

    if pos = 1 then
	write("1 "&questions[3][r])
	write("2 "&questions[3][r2])
	write("3 "&questions[3][r3])
	write("4 "&questions[3][r4])
    elsif pos = 2 then
	write("1 "&questions[3][r2])
	write("2 "&questions[3][r])
	write("3 "&questions[3][r3])
	write("4 "&questions[3][r4])
    elsif pos = 3 then
	write("1 "&questions[3][r2])
	write("2 "&questions[3][r3])
	write("3 "&questions[3][r])
	write("4 "&questions[3][r4])
    elsif pos = 4 then
	write("1 "&questions[3][r2])
	write("2 "&questions[3][r3])
	write("3 "&questions[3][r4])
	write("4 "&questions[3][r])
    end if

    draw_display()

    getting = 1

    while getting = 1 do
	key = get_key()
	if key <= 52 and key >= 49 then
	    getting = -1
	end if
    end while

    if key = 49 then
	if key-48 = pos then
	    energy = energy + 100
	    setx(10)
	    sety(y2 - 20)
	    write("Fantastic!")
	    draw_display()
	    r = time()
	    while r + 1 > time() do
	    end while
	    points = points + 100
	else
	    setx(10)
	    sety(y2 - 20)
	    write("Sorry!")
	    draw_display()
	    r = time()
	    while r + 1 > time() do
	    end while
	end if
    elsif key = 50 then
	if key-48 = pos then
	    energy = energy + 100
	    setx(10)
	    sety(y2 - 20)
	    write("Correct!")
	    draw_display()
	    r = time()
	    while r + 1 > time() do
	    end while
	    points = points + 100
	else
	    setx(10)
	    sety(y2 - 20)
	    write("Wrong!")
	    draw_display()
	    r = time()
	    while r + 1 > time() do
	    end while
	end if
    elsif key = 51 then
	if key-48 = pos then
	    energy = energy + 100
	    setx(10)
	    sety(y2 - 20)
	    write("Yes!")
	    draw_display()
	    r = time()
	    while r + 1 > time() do
	    end while
	    points = points + 100
	else
	    setx(10)
	    sety(y2 - 20)
	    write("Too bad!")
	    draw_display()
	    r = time()
	    while r + 1 > time() do
	    end while
	end if
    elsif key = 52 then
	if key-48 = pos then
	    energy = energy + 100
	    setx(10)
	    sety(y2 - 20)
	    write("Right!")
	    draw_display()
	    r = time()
	    while r + 1 > time() do
	    end while
	    points = points + 100
	else
	    setx(10)
	    sety(y2 - 20)
	    write("Sorry!")
	    draw_display()
	    r = time()
	    while r + 1 > time() do
	    end while
	end if
    else
    end if

end procedure

--This procedure redraws the buffer and all objects in it.
procedure draw()
    integer id

    buffer_display(backdrop,{1,1},pic_index[1])

    for counter = 1 to 39 do
	buffer_display(backdrop,{128*counter,1},pic_index[1])
    end for

    for y = 1 to length(global_objects)  do
	for x = 1 to length(global_objects[y]) do
	    id = global_objects[y][x]
	    if id = 0 then

	    else
		draw_sprite_buffer(backdrop,{(x-1)*32,(y-1)*32},pics[id])
	    end if
	end for
    end for
end procedure

procedure do_scores()
    integer k

    clear_display(0)

    if length(scores) = 8 then
	scores = scores[1..7]
    end if

    setx(10)
    sety(10)

    write("Edgar's Escapade\nPress Escape to clear scores\n\n")

    for counter = 1 to length(scores) do
	setx(10)
	write(scores[counter][1])
	setx(200)
	write(sprint(scores[counter][2])&"\n")
    end for
    draw_display()
    while 1 do
	k = get_key()
	if k = 27 then
	    scores = {}
	    exit
	elsif k = -1 then
	else
	    exit
	end if
    end while
end procedure

function printable(integer char)
    sequence special
    special = {'-',',','.','!',':',')',' '}
    if char >= 'a' and char <= 'z' then
	return 1
    elsif char >= 'A' and char <= 'Z' then
	return 1
    elsif find(char,special) != 0 then
	return 1
    elsif key = -1 then
	return -1
    end if
    return -1
end function

function get_name()
    sequence name
    integer k
    integer a,b,c

    a = 10
    b = y2/2-10
    c = 195

    name = {}

    fade(new_pal,repeat({0,0,0},256),60)

    clear_display(0)

    setx(a)
    sety(b)

    write("Please enter your name")

    draw_display()

    fade(repeat({0,0,0},256),new_pal,60)

    k = -1
    while k != 13 do
	k = get_key()
	if printable(k) = 1 then
	    name = append(name,k)
	    if length(name) > 15 then
		name = name [1..15]
	    end if
	    clear_display(0)
	    setx(a)
	    sety(b)
	    write("Please enter your name")
	    sety(y2/2-10)
	    setx(c)
	    write(name)
	    draw_display()
	elsif k = 8 then
	    if length(name) = 1 then
		name = {}
	    elsif length(name) = 0 then
		--Nothing
	    else
		name = name[1..length(name)-1]
	    end if
	    clear_display(0)
	    setx(a)
	    sety(b)
	    write("Please enter your name")
	    sety(y2/2-10)
	    setx(c)
	    write(name)
	    draw_display()
	end if
    end while

    return name
end function

procedure done()
    integer a,b,c,d,v,n
    sequence name

    points = floor(points)

    clear_display(0)
    setx(10)
    sety(20)
    write("Congratulations!\n\n")
    a = points*10
    write("Points X 10 :"&sprint(a)&"\n")
    b = (b1*10000)
    write("Butterfly 1 X 10000 :"&sprint(b)&"\n")
    c = (b2*5000)
    write("Butterfly 2 X 5000 :"&sprint(c)&"\n")
    d = (b3*1000)
    write("Butterfly 3 X 1000 :"&sprint(d)&"\n\n")
    write("You saved "&sprint(a+b+c+d)&" acres of rainforest!\n\n")
    draw_display()
    while get_key() != 13 do

    end while

    name = get_name()

    v = a+b+c+d

    if length(scores) = 0 then
	scores = append(scores,{name,v})
    else
	n = 1
	while 1 do
	    if scores[n][2] > v then
		n = n + 1
	    else
		scores = append(scores[1..n-1],{name,v})&scores[n..length(scores)]
		exit
	    end if
	    if n > length(scores) then
		scores = append(scores,{name,v})
		exit
	    end if
	end while
    end if

    do_scores()
end procedure

--This procedure goes to the next level.
procedure next_level()
    integer rx,ry,r,test,px,py,col

    copy_to_display(backdrop,{x,y})
    draw_display()
    fade(new_pal,repeat({0,0,0},256),60)
    clear_display(0)
    draw_display()
    set_palette(new_pal)

    col = 10

    level_num = level_num + 1
    points = points + floor(points/10)
    if level_num >= length(levels) then
	still_running = -1
	points = points * 2
	done()
	return --Avoid a refade back to the level
    else
	highest = 0

	global_objects = generate_level()
	draw()
	offset_x = 0
	offset_y = 0
	test = 1
	px = 10
	py = 5

	while test = 1 do
	    if global_objects[py][px] = 9 then
		test = 0

		x = ((px-1) * 32) - guy_pos_x
		y = ((py-1) * 32) - guy_pos_y

	    else
		test = 1

		px = px + 1
	    end if

	    if px = 161 then
		px = 10
		py = py + 1
	    end if

	end while
    end if
    if lives = 3 then
	lights = {1,1,1}
    elsif lives = 2 then
	lights = {1,1,0}
    elsif lives = 1 then
	lights = {1,0,0}
    end if
    keyboard_lights(lights)
    actives = repeat({22,0,0,1,0},100)
    for counter = 1 to length(actives) do
	if rand(8) = 4 then
	    r = rand(3)
	    if r = 1 then
		actives[counter][1] = 24
		actives[counter][5] = 1000
	    elsif r = 2 then
		actives[counter][5] = 500
		actives[counter][1] = 26
	    elsif r = 3 then
		actives[counter][5] = 250
		actives[counter][1] = 28
	    end if
	else
	    actives[counter][5] = 10
	end if
	rx = rand(extent_x)
	ry = rand(extent_y)
	test = 1
	while test = 1 do
	    if find(get_buffer_pixel(backdrop,{rx,ry}),back_colors) = 0 and
	       find(get_buffer_pixel(backdrop,{rx+4,ry+4}),back_colors) = 0 and
	       find(get_buffer_pixel(backdrop,{rx - 4,ry - 4}),back_colors) = 0 then
		test = 1
		rx = rand(extent_x)
		ry = rand(extent_y)
	    else
		test = -1
	    end if
	end while
	actives[counter][2] = rx
	actives[counter][3] = ry
    end for

    for y = 2 to length(global_objects) do
	for x = 1 to length(global_objects[y])-1 do
	    if global_objects[y][x] >= 1 and global_objects[y][x] <= 4 then
		if rand(10) = 6 then
		    r = rand(2)
		    if r = 2 then
			actives = append(actives,{30,(x-1)*32,(y-2)*32,0,50})
		    elsif r = 1 then
			actives = append(actives,{31,(x-1)*32,(y-2)*32,0,25})
		    end if
		else
		    if rand(9) = 4 and global_objects[y][x+1] >= 1 and global_objects[y][x+1] <= 4 and col+10 <= x then
			global_objects[y-1][x] = 32+(rand(3)-1)
			col = x
		    end if
		end if
	    end if
	end for
    end for

    last_x = x
    last_y = y
    last_x2 = 0
    last_y2 = 0

    draw()

    set_palette(repeat({0,0,0},256))
    copy_to_display(backdrop,{x,y})
    draw_display()
    fade(repeat({0,0,0},256),new_pal,60)
    end procedure

procedure start_over()
    --Fade out at death location
    copy_to_display(backdrop,{x,y})
    draw_display()
    fade(new_pal,repeat({0,0,0},256),60)
    for counter = 1 to 3 do
	wait()
    end for

    if lives = 0 then
	still_running = -1
    else
	draw()
	if lives = 3 then
	    lights = {1,1,1}
	elsif lives = 2 then
	    lights = {1,1,0}
	elsif lives = 1 then
	    lights = {1,0,0}
	end if

	keyboard_lights(lights)

	x = last_x
	y = last_y
	offset_x = last_x2
	offset_y = last_y2

	moving_right = 0
	moving_left = 0
	moving_up = 0

	--Fade in at last safe position
	copy_to_display(backdrop,{x,y})
	draw_display()
	fade(repeat({0,0,0},256),new_pal,60)
    end if
end procedure

procedure draw_actives()
    integer ax,ay,dir,id,p
    sequence remove_list
    remove_list = {}
    for counter = 1 to length(actives) do
	id = actives[counter][1]
	ax = actives[counter][2]
	ay = actives[counter][3]
	dir = actives[counter][4]
	p = actives[counter][5]
	if ax > x+20 and ax < x+x2-20 then
	    if ay > y+20 and ay < y+y2-20 then
		ax = ax + dir
		if find(get_display_pixel({ax-x,ay-y+4}),back_colors) = 0 or ax = 21 or ax-x = 21 then
		    if dir = -1 then
			dir = 1
		    else
			dir = -1
		    end if
		    if find(get_display_pixel({ax-x,ay-y+4}),guy_colors) = 0 then
		    else
			remove_list = append(remove_list,counter)
			points = points + p
			if id = 25 or id = 26 then
			    b1 = b1 + 1
			elsif id = 27 or id = 28 then
			    b2 = b2 + 1
			elsif id = 29 or id = 30 then
			    b3 = b3 + 1
			end if
		    end if
		else
		    if rand(200) = 23 then
			if rand(2) = 2 then
			    dir = 1
			else
			    dir = -1
			end if
		    end if
		    --Nothing
		end if
		draw_sprite({ax-x,ay-y},id)
		if id = 30 or id = 31 then
		    dir = 0
		else
		    if remainder(id,2) = 1 then
			id = id - 1
		    else
			id = id + 1
		    end if
		end if
	    end if
	end if
	actives[counter][1] = id
	actives[counter][2] = ax
	actives[counter][3] = ay
	actives[counter][4] = dir
    end for
    for counter = 1 to length(remove_list) do
	actives = remove(actives,remove_list[counter])
    end for
end procedure

procedure light_show()
    for counter = 1 to 2 do
	lights = {0,0,0}
	keyboard_lights(lights)
	wait()
	lights = {0,0,1}
	keyboard_lights(lights)
	wait()
	lights = {0,1,1}
	keyboard_lights(lights)
	wait()
	lights = {1,1,1}
	keyboard_lights(lights)
	wait()
	lights = {1,1,0}
	keyboard_lights(lights)
	wait()
	lights = {1,0,0}
	keyboard_lights(lights)
	wait()
	lights = {0,0,0}
	keyboard_lights(lights)
	wait()
	lights = {1,0,0}
	keyboard_lights(lights)
	wait()
	lights = {1,1,0}
	keyboard_lights(lights)
	wait()
	lights = {1,1,1}
	keyboard_lights(lights)
	wait()
	lights = {0,1,1}
	keyboard_lights(lights)
	wait()
	lights = {0,0,1}
	keyboard_lights(lights)
	wait()
    end for

end procedure

--MAIN LOOP

--This is the main loop.
procedure main()
    atom c,time_1,x4,y4
    integer on_ground
    object keys

    on_ground = -1
    frames = 0

    t = time()
    x4 = 1
    y4 = 1
    if lives = 3 then
	lights = {1,1,1}
    elsif lives = 2 then
	lights = {1,1,0}
    elsif lives = 1 then
	lights = {1,0,0}
    end if
    keyboard_lights(lights)

    last_x = x
    last_y = y

    --The main loop
    while still_running = 1 do
	time_1 = time()
	copy_to_display(backdrop,{x,y})
	keys = get_keys()
	if sequence(keys) then
	    if compare(keys,{}) = 0 then
		key = -1
	    else
		key = keys[length(keys)]
	    end if
	    if key = 333 then
		moving_right = scroll
		current_animation = guy_walking_right
		xsprite = guy_wr
	    elsif key = 331 then
		moving_left = scroll
		current_animation = guy_walking_left
		xsprite = guy_wl
	    elsif key = 328 then
		if on_ground = 1 then
		    jumping = 1
		    moving_up = scroll*4

		    moving_down = moving_up
		    if moving_right then
			moving_right = scroll*8
			xsprite = guy_wr
			current_animation = guy_walking_right
			ani = 1
		    elsif moving_left then
			moving_left = scroll*8
			xsprite = guy_wl
			current_animation = guy_walking_left
			ani = 1
		    end if
		end if
	    elsif key = 2 then
		next_level()
	    elsif key = 1 then
		still_running = -1
	    end if
	else
	    key = 1
	end if
	c = get_display_pixel({(guy_pos_x+offset_x)+length(current_animation[1][1])-5,(guy_pos_y+offset_y)+10})
	if find(c,back_colors) = 0 then
	    moving_up = 0
	    if compare(current_animation,guy_walking_right) = 0 then
		xsprite = guy_sr
		current_animation = guy_stopped_right
	    elsif compare(current_animation,guy_walking_left) = 0 then
		xsprite = guy_sl
		current_animation = guy_stopped_left
	    end if
	    on_ground = -1
	end if
	c = get_display_pixel({(guy_pos_x+offset_x)+4,(guy_pos_y+offset_y)+10})
	if find(c,back_colors) = 0 then
	    moving_up = 0
	    if compare(current_animation,guy_walking_right) = 0 then
		xsprite = guy_sr
		current_animation = guy_stopped_right
	    elsif compare(current_animation,guy_walking_left) = 0 then
		current_animation = guy_stopped_left
		xsprite = guy_sl
	    end if
	    on_ground = -1
	end if
	c = get_display_pixel({(guy_pos_x+offset_x)+length(current_animation[1][1])-1,(guy_pos_y+offset_y)+length(current_animation[1])-4})
	if find(c,back_colors) = 0 then
	    moving_right = 0
	end if
	c = get_display_pixel({(guy_pos_x+offset_x),(guy_pos_y+offset_y)+length(current_animation[1])-4})
	if find(c,back_colors) = 0 then
	    moving_left = 0
	end if
	c = get_display_pixel({(guy_pos_x+offset_x)+length(current_animation[1][1])-1,(guy_pos_y+offset_y)+length(current_animation[1])})
	if find(c,back_colors) = 0 then
	    if find(c,bad_colors) = 0 then
		moving_down = 0
		on_ground = 1
	    else
		lives = lives - 1
		start_over()
	    end if
	    on_ground = 1
	    last_x = x
	    last_y = y
	    last_x2 = offset_x
	    last_y2 = offset_y
	else
	    c = get_display_pixel({(guy_pos_x+offset_x),(guy_pos_y+offset_y)+length(current_animation[1])})
	    if find(c,back_colors) = 0 then
		if find(c,bad_colors) = 0 then
		    moving_down = 0
		    on_ground = 1
		else
		    lives = lives - 1
		    start_over()
		end if
		on_ground = 1
		last_x = x
		last_y = y
		last_x2 = offset_x
		last_y2 = offset_y
	    else
		if jumping = 0 then
		    on_ground = -1
		    if offset_y < 0 then
			offset_y = offset_y + 1
		    else
			y = y + 1
		    end if
		end if
	    end if
	end if
	if moving_right then
	    moving_right = moving_right - 1
	    if moving_right = 1 then
		current_animation = guy_stopped_right
		xsprite = guy_sr
		ani = 1
	    end if
	    if offset_x < 0 then
		offset_x = offset_x + 1
		energy = energy - .01
	    else
		x = x + 1
		energy = energy - .01
	    end if
	end if
	if moving_left then
	    moving_left = moving_left - 1
	    if moving_left = 1 then
		current_animation = guy_stopped_left
		xsprite = guy_sl
		ani = 1
	    end if
	    if offset_x > 0 then
		offset_x = offset_x - 1
		energy = energy - .01
	    else
		x = x - 1
		energy = energy - .01
	    end if
	end if
	if moving_up then
	    moving_up = moving_up - 1
	    if offset_y > 0 then
		offset_y = offset_y - 1
		energy = energy - .02
	    else
		y = y - 1
		energy = energy - .02
	    end if
	else
	    if moving_down and moving_up = 0 then
		moving_down = moving_down - 1
		if offset_y < 0 then
		    offset_y = offset_y + 1
		else
		    y = y + 1
		end if
	    elsif moving_down = 0 and moving_up = 0 then
		if moving_right = 0 and moving_left = 0 then
		    if rand(1000) = 500 then
			if compare(current_animation,guy_walking_right) = 0 then
			    current_animation = guy_waving_right
			    xsprite = guy_xr
			elsif compare(current_animation,guy_walking_left) = 0 then
			    current_animation = guy_waving_left
			    xsprite = guy_xl
			elsif compare(current_animation,guy_stopped_left) = 0 then
			    current_animation = guy_waving_left
			    xsprite = guy_xl
			elsif compare(current_animation,guy_stopped_right) = 0 then
			    current_animation = guy_waving_right
			    xsprite = guy_xr
			end if
		    end if
		end if
		if jumping = 1 then
		    jumping = 0
		end if
	    end if
	end if

	if x <= 0 then
	    if offset_x > -149 then
		offset_x = offset_x - 1
	    end if
	    x = 1
	end if
	if y <= 0 then
	    if offset_y > -85 then
		offset_y = offset_y - 1
	    end if
	    y = 1
	end if
	if x >= extent_x-y2-145 then
	    x = extent_x-y2-146
	    if offset_x < 149 then
		offset_x = offset_x + 1
	    else
		light_show()
		lives = 3
		next_level()
		if still_running = -1 then
		    exit
		end if
	    end if
	end if
	if y >= extent_y-y2 then
	    if offset_y < 85 then
		offset_y = offset_y + 1
	    end if
	    y = extent_y-y2-1
	end if
	setx(10)
	sety(10)
	write(sprint(floor(points)))
	animate_char()  --Draw the character
	draw_actives()
	frames = frames + 1
	key = 0

	play_music()

	--QUESTIONS

	--Uncomment the following lines for geography questions
	--accompanying the game.

	--Start here

	--energy = energy - .001
	--setx(x2-20)
	--sety(10)
	--write(sprint(floor(energy)))
	--points = points + .0037
	--if energy <= 0 then
	    --while energy < 300 do
		--question_geo()
		--points = points + 100
	    --end while
	    --energy = 100
	--end if

	--End here


	draw_display()  --Display the game on the monitor

	while time()-time_1 < 1/205 do
	    --This limits it to a max of 200 fps.  In pure dos it runs at up to 300 fps!
	    --At 300 fps it is almost impossible to play.

	    play_music() --Limit the graphics but not the sound!
	end while

    end while
    --t2 = time()
    --time2 = t2 - t
    --copy_to_display(backdrop,{x,y})

    --setx(10)
    --sety(10)

    --write(sprint(floor(frames/time2))&" frames per second!\n\nPress any key")
    --draw_display()
    --while get_key() = -1 do
	--
    --end while

    lights = {0,0,0}
    keyboard_lights(lights)

    clear_display(0) --Avoid an off-color
    draw_display()   --bad looking flash

    set_palette(startup_img[1])
end procedure

bar()

--Remove any error causing -1 in the pictures, (if there are any!)
for y_counter = 1 to length(pic_index[1]) do
    for x_counter = 1 to length(pic_index[1][y_counter]) do
	if pic_index[1][y_counter][x_counter] = -1 then
	    pic_index[1][y_counter][x_counter] = 24
	end if
    end for
end for

new_pal = pal

--Set the guy's palette
new_pal[256]  = {0,150,0}         --hat
new_pal[255] = {150,200,0}       --hair
new_pal[254] = {50,50,0}         --skin
new_pal[253] = {0,20,0}          --eyes
new_pal[252] = {50,0,0}          --mouth
new_pal[251] = {0,0,100}       --shirt
new_pal[250] = {0,0,95}       --shirt2
new_pal[249] = {50,50,0}         --skin also
new_pal[247] = {0,0,0}        --shoes
new_pal[246] = {150,200,0}         --pants
new_pal[245] = {0,0,0}
new_pal[244] = {20,10,0}
new_pal[243] = {40,40,40}
new_pal[242] = {5,5,5}         --black
new_pal[241] = {0,250,0}       --bright green
new_pal[240] = {5,5,5}         --black
new_pal[239] = {0,0,0}         --black
new_pal[238] = {255,0,255}     --black

new_pal[1] = {0,0,0}
new_pal = floor(new_pal)

procedure help()
    clear_display(0)
    setx(10)
    sety(10)
    write("The beautiful jungles of South \n")
    write("America are destined for destruction.\n")
    write("The jungle's only help lies in an\n")
    write("eccentric rich man who has agreed\n")
    write("to buy some of the jungle land for\n")
    write("each butterfly Edgar can find.\n\n")
    write("Press any key....\n")
    draw_display()
    while get_key() = -1 do

    end while
    clear_display(0)
    setx(10)
    sety(10)
    write("The more points and butterlies Edgar\n")
    write("can accumulate, the more jungle land\n")
    write("will be saved!\n\n\n\n\n")
    write("Press any key....\n")
    draw_display()
    while get_key() = -1 do

    end while
end procedure

bar()

procedure about()
    clear_display(0)
    setx(10)
    sety(10)
    write("Credits\n\n")
    write("This game is a demo if the\n")
    write("Emagine graphics library.\n")
    write("Press any key....\n")
    draw_display()

    while get_key() = -1 do

    end while

    clear_display(0)
    setx(10)
    sety(10)
    write("Credits\n\n")
    write("This production of this game was\n")
    write("knowingly and unknowingly aided by\n")
    write("following people:\n\n\n\n")
    write("Press any key....\n")

    draw_display()
    while get_key() = -1 do

    end while

    clear_display(0)
    setx(10)
    sety(10)
    write("Credits\n\n")
    write("Nolan Worthington - Artist\n") -- game by\n\n"&name&".\n\n\n\n")
    write("Jiri Babor        - Font routines\n") -- game by\n\n"&name&".\n\n\n\n")
    write("Andrew Greenwood  - Midi sounds\n") -- game by\n\n"&name&".\n\n\n\n")
    write("The Illich family - Playtesters\n") -- game by\n\n"&name&".\n\n\n\n")
    write("\n\n")
    write("Press any key....")

    draw_display()
    while get_key() = -1 do

    end while

    clear_display(0)
    setx(10)
    sety(10)
    write("Programmed in Euphoria.\n")
    write("\n\n")
    write("www.rapideuphoria.com\n\n\n")
    write("Rapid Deployment Software\n\n")
    write("Press any key....\n")

    draw_display()
    while get_key() = -1 do

    end while
end procedure

bar()

--MENU

procedure menu()
    integer running,getting
    integer selected
    sequence a

    set_shadow_color(91) --91

    selected = 1

    a = repeat(NONE,5)

    running = 1

    --46
    set_paper_color(46)

    while running = 1 do

	a = repeat(NONE,5)

	a[selected] = SHADOW

	clear_display(0)

	setx(105)
	sety(50)

	set_attributes(a[1])
	write("  Play game\n")
	set_attributes(a[2])
	write("  The Story\n")
	set_attributes(a[3])
	write("  About\n")
	set_attributes(a[4])
	write("  High scores\n")
	set_attributes(a[5])
	write("  Exit\n")
	draw_display()

	getting = 1

	while getting = 1 do
	    key = get_key()
	    if key = 328 or key = 336 or key = 27 or key = 13 then
		getting = -1
	    end if
	end while

	if key = 13 then
	    if selected = 1 then

		clear_backbuffer(backdrop) --Avoid bad startup flash of
					   --last level played

		clear_display(0)
		draw_display()

		set_palette(floor(new_pal))

		x_pos = 1
		y_pos = 1
		x = 1
		y = 1
		moving_up = 0
		moving_down = 0
		moving_right = 0
		moving_left = 0

		still_running = 1 --Reset the while loop

		level_num = 0 --Start over

		lives = 3
		b1 = 0
		b2 = 0
		b3 = 0
		points = 0
		energy = 100

		next_level()

		main() --Start!

	    elsif selected = 2 then
		help()
	    elsif selected = 3 then
		about()
	    elsif selected = 4 then
		clear_display(0)
		do_scores()
	    elsif selected = 5 then
		fn = open("scores","w")

		puts(fn,sprint(scores))

		close(fn)

		if graphics_mode(-1) then --Restore previous mode.
		    --Ignore result
		end if

		abort(1)
	    end if
	elsif key = 328 then
	    selected = selected - 1
	else selected = selected + 1
	end if

	if selected = 6 then
	    selected = 1
	elsif selected = 0 then
	    selected = 5
	end if

    end while

end procedure
bar()

levels = repeat(0,5) --4 levels to complete game, first is skipped!

clear_display(0)

menu() --Begin!


