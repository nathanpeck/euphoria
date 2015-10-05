=======================================================================
Escreen Version 2.0

This is release two.  In release one I accidently forgot a file.
Sorry.  This release adds two more features:

copy_to_buffer() and
draw_sprite_buffer()

It also adds a new demo: demo8.ex
and improves on Version 1.0

=======================================================================

This is a complete graphics library that offers high speed graphics
buffering and displaying.

=======================================================================

It includes the following files:

Escreen.e - The main library
retrace.e - I don't know who made this!
font.e    - A modification on Jiri Babors library.

Convert.ex - An application for converting bmps to img files.

It also has demos labeled from Demo1.ex to Demo7.ex

Demo1.ex - A basic pixel plotting program
Demo2.ex - Basic palette routines
Demo3.ex - A simple screen saver
Demo4.ex - Bouncing things
Demo5.ex - 500 bouncing things using sprite routines
Demo6.ex - 50 large bouncing sprites that are easier to see
Demo7.ex - Super fast scrolling. Use the arrow keys and enter to end

And it also has:

weird1.ex and weird2.ex - Two of the weirdest fractal screensavers 
                          you'll ever see!
explode.ex              - Exploding fireworks complete with gravity
			  and sound.

=======================================================================

ROUTINES
--------

  ROUTINES FOR THE PRIMARY BUFFER--

  draw_display()
    Puts the virtual display onto your monitor

  clear_display(integer color)
    Clears the virtual display

  set_pixel(object pixel,sequence position)
    Sets a pixel in the virtual display

  pixel = get_display_pixel(sequence pos)
    Returns the color of the pixel at pos in the virtual display

  return_buffer_adress()
    Returns the memory adress of the virtual display.

  display_bmp(sequence pos, sequence pixels)
    Draws a 2-d image in the virtual display

  THE BELOW PROCEDURE IS SLOW....
  sprite_slow(graphic_point x_y, sequence img, integer clear_color)
    This does a sprite by not drawing pixels of clear_color.

  ...RATHER USE THESE TWO.
  sprite_id = add_sprite(sequence img, integer clear_color)
    This adds a sprite the the internal list.

  draw_sprite(integer sprite_id, graphic_point x_y)

ROUTINES FOR SEPERATE BACK BUFFERS
----------------------------------

  id = create_backbuffer(sequence dimensions)
    Creates a backbuffer.

  clear_backbuffer(integer buffer_id)
    This clears the backbuffer specified using color 0.

  buffer_display(integer buffer_id, graphic_point pos, sequence img)
    Displays an img in the specified buffer.

  set_buffer_pixel(integer buffer_id, object pixel, graphic_point pos)
    This sets a buffer pixel or buffer pixels

  copy_to_display(integer buffer_id, sequence x_y)
    This copies part of a buffer to the main virtual display.

  copy_to_buffer(integer source, sequence x_y, integer destination, sequence x_y)
    This copies from one buffer to another, or even from one buffer to itself!

  buffer_sprite_slow(integer buffer_id, graphic_point x_y, sequence img, integer clear_color)
    This is the same as sprite slow, except in a buffer.

  draw_sprite_buffer(integer sprite_id, graphic_point x_y, integer buffer_id)

IMG AND PAL I/O PROCEDURES
--------------------------

  save_img(sequence name, sequence data)
    This saves an img file using Escreen's special type.

  img = load_img(sequence name)
    This loads an img file saved by save_img()

  save_pal(sequence name, sequence data)
    This saves a palette using Escreen's special type.

  pal = load_pal(sequence name, integer variant)
    This loads a palette saved by save_pal()
    variant should be 1 if you want the original palette
    Changing it can result is some spectacular results!

  set_palette(sequence pal)
    This sets a palette.

  fade(sequence pal_from, sequence pal_to, integer step)
    This does a screen fade.
    Currently step must be 1

OTHER PROCEDURES AND WEIRD PROCEDURES
-------------------------------------

  img = magnify(sequence img, integer times)
    This enlarges an img file times times.


  sprite_fast(sequence sprite)
  buffer_sprite_fast(integer buffer_id, sequence sprite)
    These two procedures are very weird.
    They add the contents of the sprite to the contents of the buffer.

    So drawing: 
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

WARNING:

This library does almost NO error trapping.
Therefore it is up to you to prevent mistakes.

NO ONE will be responsible for ANY damages resulting from ANY use
of the library.
