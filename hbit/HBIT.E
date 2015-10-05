--This little library demonstrates how to to a hard conversion of
--numbers to bits and bits to numbers.

--hard_bits is useful in applications where you do not know what
--value the number to be converted has.  
--hard_bits returns the least possible number of bits needed to
--contain num.

--hard_num just converts a sequence of bits back into a number.

global function hard_bits(integer num)
    sequence bits
    
    bits = {}
    
    while num > 0 do
	num = num / 2  
	if integer(num) then
	    bits = append(bits,0)
	else
	    bits = append(bits,1)
	    num = floor(num)
	end if
    end while
    
    return bits
end function

global function hard_num(sequence bits)
    integer num
    integer val
    
    num = 0
    val = 1
    
    for counter = 1 to length(bits) do
	if bits[counter] = 1 then
	    num = num + val
	end if
	val = val * 2
    end for
    
    return num
end function
