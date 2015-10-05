--Two routines for determining if a game object is within a certain range of
--another game object.
--
-- i_region()  --Slow but an interesting idea.
-- in_region() --Best and most accurate
--
-- in_region(sequence objects_xy1, sequence objects_xy2, integer range)
--
-- It returns 1 if true, -1 if false
--

include machine.e
include misc.e

sequence xa
sequence ya

global function i_region(sequence xy1, sequence xy2, integer range, integer bits)
    xa = int_to_bits(xy1[1],bits)
    ya = int_to_bits(xy1[2],bits)

    xa = xa[range..bits]
    ya = ya[range..bits]

    if match(xa,int_to_bits(xy2[1],bits)) = range then
	if match(ya,int_to_bits(xy2[2],bits)) = range then
	    return 1
	end if
    end if

    return -1
end function

global function in_region(sequence xy1, sequence xy2, integer range)
    integer xa,xb,ya,yb,r

    xa = xy1[1]
    xb = xy2[1]
    ya = xy1[2]
    yb = xy2[2]

    r = floor(range/2)

    if xa <= xb + r and xa >= xb - r then
	if ya <= yb + r and ya >= yb - r then
	    return 1
	end if
    end if
    return -1
end function
