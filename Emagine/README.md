=======================================================================
Emagine 1.2
=======================================================================

October 29,2004

What's new?
-----------

This release features copy_window(), a routine for copying smaller
windows of graphics from buffers to the screen.  This can be used
for multi-player games.

Another new routine is draw_window() which allows you to shave time
off your graphics loop, and further speed up Emagine!

New routine: get_buffer().  This gets a chunk of a buffer.  This can be
used so that you can draw sprites directly on your graphics buffer.

* Get a picture of the area the sprite will be in.
* Draw the sprite.
* Draw the buffer on the screen
* Erase the sprite using the picture get_buffer() returned.

More demos to show off the new features.

The routines for drawing sprites and images in seperate backbuffers
have been remodeled and made MUCH faster!

A bug in the image and palette loading routines was corrected.
Now there are not any weird errors such as cut off images.

I created a new application: convertdir.ex
This changes all the *.bmp files in convertdir's folder to *.img files
with the same base name.  This is handy when converting a bunch of bmps
for a serious game.

An object positioning library: Objpos.e with routines for determining
if an object is within a ceratain range of another.

What is Emagine?
----------------

Emagine is a complete game engine that offers graphics and sound
routines.  Although it uses all Euphoria code, no machine procedures,
it is still very fast.

It includes the following files:

Emagine.e - The main library
retrace.e - I don't know who made this!
font.e    - A modification on Jiri Babors font library to work
            with Emagine.  This looks good and is alot better than
            the regular screen font.
objpos.e  - A library I created for comparing the positions of objects.
mpu401.e  - Mpu401 midi
musicS.e  - Music through your computer speaker. (OLD)
midi.e    - Better midi music with timing, etc.
keyread.e - Fast keyboard reading.

cognac10.f  - A font for font.e, small.
modern28.f  - Yet another font, this one is large.
simple09.f  - Another small font.
small.f     - A really small all capital letter font.

Convert.ex      - An application for converting bmps to img files.
ConvertW.exw    - A windows version of the appliaction above,
		  my monitor is sometimes very unhappy about changing
                  from graphics mode to character mode, so I created
                  this.
Covertdir.ex    - I created this to make it easier to convert bmps.
                  It changes all the bmps in its folder to img files
                  with the same base name, but a .img extension.

It also has demos labeled from Demo1.ex to Demo11.ex

Demo1.ex  - A basic pixel plotting program
Demo2.ex  - Basic palette routines
Demo3.ex  - A simple screen saver
Demo4.ex  - Bouncing things
Demo5.ex  - 500 bouncing things using sprite routines
Demo6.ex  - 50 large bouncing sprites that are easier to see
Demo7.ex  - 50 bouncing sprites of varying complexities.
Demo8.ex  - Super fast scrolling. Use the arrow keys and enter to end
Demo9.ex  - The magnification feature.
Demo10.ex - A demo of how to use musicS.e - it's not very impressive!
Demo11.ex - A demo of in program midi music.  I wrote the song!
Demo12.ex - This is a demo of how to use copy_window.  It might
            be useful if you are planning to create a game with
            multiple players.
Demo13.ex - A demo of a multiple character game.  The goal is to
            collide with the other character.  This will cause a
            white flash between the two frames.  This uses objpos.e

And it also has:

weird1.ex and weird2.ex - Two of the weirdest fractal screensavers 
                          you'll ever see!
explode.ex              - Exploding fireworks complete with gravity
			  and sound.
song.ex			- A song in the minor key.
visual.ex		- A happier, funky tune with a visual to
			  compliment it!  The tune is by me.
fade.ex			- A basic demo of the fade routine.
keysfast.ex		- Use this to determine the code of key as
			  as returned by get_keys() in keyread.e

Why use Emagine?
----------------

* Emagine is fast enough for even serious games (provided you are an
  efficient programmer!)
* Emagine currently uses NO machine code in its graphics routines.
  Your program will be true Euphoria.
* Emagine has many demos to help you get started.

=======================================================================

Core Operation
--------------

Emagine uses double buffering to eliminate flickering.  It does not
draw everything directly in the graphics memory.  Instead it draws
things in a seperate virtual screen.  When you are done drawing the
screen, you simply call draw_display() to quickly copy the vscreen
to the graphics memory.
Emagine has several sprite routines.  It has a normal slow procedure
and a new fast one I created.  I am not sure that the idea is new,
in fact it better not, it is so simple, but it is REALLY fast.

=======================================================================

ROUTINES
========

ROUTINES FOR THE PRIMARY BUFFER
-------------------------------

-> draw_display()
   --------------

     Puts the virtual display onto your monitor

-> draw_window(sequence xy, sequence length_of_window)
   --------------------------------------------------	

     This draws only a portion of the graphics buffer onto the screen.
     It starts at xy and goes for length_of_window in the x and y
     directions. This can be used, for example if you game has a
     toolbar or display off to the side.  The main action is going on
     in a smaller window, and the toolbar hasn't changed.  You can use
     copy_window to copy just part of the game to that smaller window
     so you don't overdraw the toolbar.  After drawing the toolbar
     once, use draw_window() to just draw the area with the action
     going on.  This will make your game faster!

-> clear_display(integer color)
   ----------------------------

     Clears the virtual display

-> set_pixel(object pixel,sequence position)
   -----------------------------------------

     Sets a pixel in the virtual display

-> pixel = get_display_pixel(sequence pos)
   ---------------------------------------

     Returns the color of the pixel at pos in the virtual display

-> return_buffer_adress()
   ----------------------

     Returns the memory adress of the virtual display.

-> display_bmp(sequence pos, sequence pixels)
   ------------------------------------------

     Draws a 2-d image in the virtual display

|--This procedure is really slow------------------------------------|
|                                                                   |
| sprite_slow(graphic_point x_y, sequence img, integer clear_color) |
|    This does a sprite by not drawing pixels of clear_color.       |
|-------------------------------------------------------------------|
  
-> sprite_id = add_sprite(sequence img, integer clear_color)
   ---------------------------------------------------------

     This adds a sprite the the internal list.

-> draw_sprite(integer sprite_id, graphic_point x_y)
   -------------------------------------------------

     Draw the sprite pointed to by sprite id at position x_y.

ROUTINES FOR SEPERATE BACK BUFFERS
----------------------------------

-> id = create_backbuffer(sequence dimensions)
   -------------------------------------------

     Creates a backbuffer.

-> clear_backbuffer(integer buffer_id)
   -----------------------------------

     This clears the backbuffer specified using color 0.

-> buffer_display(integer buffer_id, graphic_point pos, sequence img)
   ------------------------------------------------------------------

     Displays an image in the specified buffer.

-> set_buffer_pixel(integer buffer_id, object pixel, graphic_point pos)
   --------------------------------------------------------------------

     This sets a buffer pixel or buffer pixels

-> get_buffer_pixel(integer buffer_id, graphic_point pos)
   --------------------------------------------------------------------

     This gets a buffer pixel from buffer id

-> get_buffer(integer id, sequence xy, sequence extents)
   -----------------------------------------------------

     This gets a chunk of the buffer specified.  Use it to get the
     area below a sprite so that you can erase the sprite after
     drawing it on the buffer.

-> copy_to_display(integer buffer_id, sequence x_y)
   ------------------------------------------------

     This copies part of a buffer to the main virtual display.

-> copy_window(integer buff_id, sequence pos, sequence extent, seqeuence dest_x_y)
   -------------------------------------------------------------------------------

     This copies a window from a part of buff_id from pos of extent
     size and puts it at dest_x_y in the main virtual buffer.

-> copy_to_buffer(integer source, sequence x_y, integer destination, sequence x_y)
   -------------------------------------------------------------------------------
     This copies from one buffer to another, or even from one buffer to itself!

|--Slow, use draw_sprite_buffer----------------------------------------------------------------|
|                                                                                              |
| buffer_sprite_slow(integer buffer_id, graphic_point x_y, sequence img, integer clear_color)  |
| -------------------------------------------------------------------------------------------  |
|                                                                                              | 
|   This is the same as sprite slow, except in a buffer.                                       | 
|----------------------------------------------------------------------------------------------|

-> draw_sprite_buffer(integer sprite_id, graphic_point x_y, integer buffer_id)
   ---------------------------------------------------------------------------

     Same as draw_sprite but in buffer buffer_id

IMG AND PAL I/O PROCEDURES
--------------------------

-> save_img(sequence name, sequence data)
   --------------------------------------

     This saves an img file using Emagine's special type.

-> img = load_img(sequence name)
   -----------------------------

     This loads an img file saved by save_img()

-> save_pal(sequence name, sequence data)
   --------------------------------------

     This saves a palette using Emagine's special type.

-> pal = load_pal(sequence name, integer variant)
   ----------------------------------------------

     This loads a palette saved by save_pal()
     variant should be 1 if you want the original palette
     Changing it can result is some spectacular results!

-> set_palette(sequence pal)
   -------------------------

     This sets a palette.

-> fade(sequence pal_from, sequence pal_to, integer steps)
   ------------------------------------------------------

     This does a good-looking palette fade.
     Steps is the number of steps to take in morphing pal_from to
     pal_to.  With most palette changes about 60 or 70 is good.

ROUTINES FOR PLAYING MIDI MUSIC
-------------------------------

-> create_stream()

     This creates a new stream and returns it's id.
     You can use it's id to change it's instument, which will
     default to piano.  See program_change()
     
-> make_midi(sequence numbers)
   ----------------------------

     This makes a midi data song from the numbers specified.
     If a one is C then -7 will be the B just below it.
     An 8 will be the C above.
     A 9 will be the D above that C.
 
     A scale might go {-1,-2,-3,-4,-5,-6,-7,1,2,3,4,5,6,7,8}
     or it might go from 1 to 16

     Adding .1 to a number causes it's note to be sharped.

     Anything less that -1 or greater that 16 will cause an error!

-> set_midi(integer stream, sequence data)
   ---------------------------------------

     This sets the midi song for the specified stream.
     Data should be a sequence returned by make_music.

-> play(integer stream)
   --------------------

     This function plays the current note in stream stream and
     returns 1 if there is still more to play,
     -1 if the song is over.

-> restart(integer stream)
   -----------------------

     This restarts the current stream at the begining. 

-> get_pos(integer stream)
   -----------------------

     This returns the current position in the stream.  It is useful for
     doing timing when combined with set_play_time()  See demo11.ex

-> set_measure(atom t)
   ----------------------

     This sets the time is takes to play a measure and changes
     W,H,Q,E,S,T.   See demo11.ex

-> set_play_time(atom t)
   ---------------------

     This sets the amount of time the current note will play.
     See demo11.ex

-> program_change(integer stream, integer instrument)
   --------------------------------------------------

     This changes the instrument being played on the stream specidied.
     The instrument integer should be between 1 and 127.

-> set_scale(integer number)
   -------------------------
      
     This sets where the 3 octave spread begins.
     You can quickly change this to adjust the pitch of your songs.
     You must set this BEFORE calling make_midi() otherwise the
     changes will never take place.

-> set_minor_scale(integer number)
   -------------------------------

     This is the same as set_scale() except it sets the 3 octave
     spread as a minor scale.
     For a demonstration of the result of this routine open demo11.ex
     or song.ex

ROUTINES FOR PLAYING MUSIC THROUGH YOUR PC SPEAKER
--------------------------------------------------

  |-----------------------------------------------------------------|
  | All these routines are kind of useless.  They are old           |
  | not as flexible or nice sounding as the midi music interface.   |
  |-----------------------------------------------------------------|

-> mscale()
   --------

     This simple function returns the frequencies used to generate
     the tones.

-> make_music(sequence numbers)

     This creates frequency tones from the numbers in sequence numbers.
     The numbers must be between 0 and 8.
     Their is no interface for timing.

-> set_music(sequence frequencies)

     This sets the result from make_music() as the music sequence.

-> play_music()

     This plays the music sequence and returns either 1 or -1.
     1 = still playing  -1 = done playing

-> loop_again()

     Start over and play the tune again.

OBJECT AI AND RANGE
-------------------

-> in_region(sequence firstxy, sequence secondxy, integer range)

     This determines if an object is within range distance of another
     object.  It returns 1 if true.

OTHER PROCEDURES AND WEIRD PROCEDURES
-------------------------------------

-> img = magnify(sequence img, integer times)
   ------------------------------------------

     This enlarges an img file times times.

-> sprite_fast(sequence sprite)
   buffer_sprite_fast(integer buffer_id, sequence sprite)
   ------------------------------------------------------

     These two procedures are very weird.
     They add the contents of the sprite to the contents of the buffer.
 
     So displaying: 
     {
      {0,0,1,1,1,0,0},
      {0,0,1,1,1,0,0},
      {0,0,1,1,1,0,0}
     }
 
     in a buffer with this at the destination: 
 
     {
      {1,1,1,1,1,1,1},
      {2,2,2,2,2,2,2},
      {3,3,3,3,3,3,3}
     }

     would create a result of:

     {
      {1,1,2,2,2,1,1},
      {2,2,3,3,3,2,2},
      {3,3,4,4,4,3,3}
     }

     Its hard to use but good for fractals!

=======================================================================

BUGS

* An image I try to load is warped, but I am not sure whether it is
  warped in image loading or saving.  I can not find anything wrong in
  either routine.

Please run your program using safe.e (Euphoria include file) first,
to make sure the bug is not caused by your overwriting unallocated
memory; many of my bugs have been traced back to such overwrites.

=======================================================================

Global constants
----------------

Yes, I know that not all of these are in capitals as proper
programming style encourages.
The names here are case sensitive.

P_BLACK       An all black palette that can be handy when doing fades.
cols	      The number of columns on the screen.
rows	      The number of rows on the screen.
vc	      The video configuration as returned by video_config().
RIGHT	      The right arrow key code.
LEFT          The left arrow key code.
UP            The up arrow key code.
DOWN          The down arrow key code.

=======================================================================

WARNING!

This library does almost NO error trapping.
Therefore it is up to you to prevent mistakes.

If you get errors from Causeway that means that you overwrote the
end of one of Emagine's buffers.
I encourage you to use safe.e to trap such errors.  I use it.

NO ONE will be responsible for ANY damages resulting from ANY use
of the library.