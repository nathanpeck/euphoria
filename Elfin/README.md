=======================================================================

What is Elfin?
--------------

Elfin is a simple encryption algorithm.

Its features include:

*  Any length key, but best at 2048 bits.
*  A *.dat file which can make Elfin even more secure.
*  File as well as internal sequence encryption.

-----------------------------------------------------------------------

How do I use it?
================

Elfin's routines are listed below.

->  SetKey(sequence bits)
    ---------------------
 
      This vital procedure sets the key that you want to use.
      You can only pass bit sequences that have a length divisible
      by 8.
      Although the key box processing uses only 2048 bits, you can use
      a bit sequence of greater length for more safety in your
      sequences.

->  Encrypt(sequence data)
    ----------------------

      This simply encrypts data and returns the resulting cyber text.

->  Decrypt(sequence data)
    ----------------------

      This decrypts a data sequence.

->  EncryptFile(sequence in, sequence out)
    --------------------------------------

      Encrypt the data in "in" and put it in "out".

->  DecryptFile(sequence in, sequence out)
    --------------------------------------

      Decrypt in to out.

->  SetPassword(sequence password)
    ------------------------------

      This simply created a key from password and then sets the key.
      WARNING!  Passing a long string will crash your program!

-----------------------------------------------------------------------

Questions? 
==========

  How does the "elfin.dat" file work?
  -----------------------------------

    It is used as a keybox that is personalized by the encryption key.
    Someone who wants to decrypt a message must have the original
    elfin.dat file as well as the key used to encrypt the message.

  Is Elfin very secure?
  ---------------------

    Who knows? This is my first try at an encryption algorithm.

  May I port it to other languages?
  ---------------------------------

    Sure, go ahead!  Just remember to distribute this file.

-----------------------------------------------------------------------

Disclaimer      
==========

Warning!

Elfin is NOT guaranteed to be totally if at all secure.
It should NOT be used for trademark secrets, government security files,
or anything else that could potentially cost you if the data is
revealed.

NO ONE will be held responsible for ANY damages resulting from ANY use
of the Elfin algorithm.

-----------------------------------------------------------------------

Speed
=====

If speed is an issue you can recreate Elfin.dat.  With different files
Elfin will speed up or slow down.

If you are going to recreate Elfin.dat, though, make sure you create
a backup of the current *.dat file.  It is the fastest I could make it.
Also you will need to use the same .dat file you used to encrypt a
file if you want to decrypt the file properly.

Elfin also seems to change speed depending on the length of the
encoding sequence.

I have a very old machine though with a slow processor, 32 mb memory
and demo.ex runs at 56 kbs encoding and 56 kbs decoding.

Open demo.ex to see how fast Elfin runs on you machine!

-----------------------------------------------------------------------

Bugs
====

Sometimes init() causes a slice length error when used with a certain
Elfin.dat file.
If this occurs simply recreate Elfin.dat and the problem will go
away.

-----------------------------------------------------------------------

Created by Nathan Peck
