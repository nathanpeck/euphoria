# euphoria

A bunch of code I wrote back in 2004 (at 14 years old) in the [EUPHORIA](http://www.rapideuphoria.com/) language.

Contents include:

* A low level mode 19 (13h) [graphics engine](/Emagine). It has some nice things like a 256 color palette fade algorithm,
and a cute implementation of [RLE sprites](https://www.allegro.cc/manual/4/api/rle-sprites/) (which I thought I had invented at the time).
A blast of [320x200 goodness](https://en.wikipedia.org/wiki/Mode_13h) from the past.

* A platformer [game](/Escapade), written using the graphics engine. It ran in mode 19. The code for this game
is horrific, but the most interesting thing about it is an [algorithm](/Escapade/g.e) that can analyze user generated platformer
maps and then generate new platformer maps based on the samples.

* A Windows program [installer](/Installer) that can wrap up a compressed archive inside an executable that
can extract itself.

* A really [weird sorting algorithm](/Sort)

* An attempt at creating an [encryption algorithm](/Elfin) after reading Bruce Schneier's book Applied Cryptography.
14 year old me was very impressed and thought it would be quite glamorous to roll my own algorithm.

* A very naive [compression algorithm](/Compression) that frankly is pretty embarassing.

* Some amazing quotes like this one: `I have a very old machine though with a slow processor, 32 mb memory and demo.ex runs at 56 kbs encoding and 56 kbs decoding.`

* Some incredible ASM code:

   ```
    global constant retrace_vertical = allocate(20)
    poke(retrace_vertical, {
      #50,          --    PUSH EAX
      #52,          --    PUSH EDX
      #BA,#DA,3,0,0,--    MOV EDX, 0x03DA
      #EC,          -- 1: IN AL, DX
      #A8,#08,      --    TEST AL, 0x08
      #75,#FB,      --    JNZ 1:
      #EC,          -- 2: IN AL, DX
      #A8,#08,      --    TEST AL, 0x08
      #74,#FB,      --    JZ 2:
      #5A,          --    POP EDX
      #58,          --    POP EAX
      #C3 } )       --    RET
   ```
   
* A severe lack of well named variables, but an abundance of scary looking one liners:

   ```
   --A weird sprite routine that I doubt many will use.
   --It is fast though!
   global procedure buffer_sprite_fast(atom where,graphic_point xy,sequence img)
     atom a,x3,y3
     a = buffers[where][1]
     x3 = buffers[where][2]
     y3 = buffers[where][3]
     for counter = 1 to length(img) do
	     poke(a+(xy[2]*x3)+xy[1]+((counter-1)*x3),img[counter]+peek({a+(xy[2]*x3)+xy[1]+((counter-1)*x3),length(img[1])}))
     end for
   end procedure
   ```
   
* Many, many [8.3](https://en.wikipedia.org/wiki/8.3_filename) filenames.
