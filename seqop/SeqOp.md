-----------------------------------------------------------------------

This is a manual to explain how to use stuff.e

-----------------------------------------------------------------------

About stuff.e
================

Stuff.e contains some basic, but very handy routines that fall into
three categories:

Find procedures,
Sequence operations,
and file operations.

Routines
========

 Find procedures
 ---------------

  
-> function find_greater(object what, sequence source, integer where)	

   This function find the object what (if it is present) in source at
   a point greater than where.

-> function find_less(object what, sequence source, integer where)	
  
   This function find the object what (if it is present) in source at
   a point less than where.

 Sequence operations
 -------------------

-> function remove_less_than(sequence seq, integer index)

   This routine removes all subscripts less then index 

-> function remove_greater_than(sequence seq, integer index)

   This routine removes all subscripts greater than index.

-> function remove(sequence seq, integer index)

   This routine removes a subscript from a sequence using sequence
   slicing.
   Pass the input to seq and the subscript number to remove to index.

-> function remove_subscripts(sequence seq, object o)

   This routine removes all subscripts of a sequence that match
   object o.

-> function members(sequence seq)
   
   This function returns a sequence which is a list of all the 
   different members in sequence seq.

-> function replace_all(sequence seq, object o1, object o2)

   This function replaces all occurences of object o1 in sequence seq
   with object o2.

 File Operations
 ---------------

-> function read_file(sequence name)
   
   This function reads a file by its lines and returns either them or
   the number -1 if something goes wrong.


Disclaimer
==========

Use this library at your own risk.

Nobody will be held responsible for any damages resulting from any use
of this library.

-----------------------------------------------------------------------

Copyright (C) 2004