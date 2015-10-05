include keyread.e
include misc.e

puts(1,"Press Escape to end\n\n")

sequence k
integer last

last = -1

while 1 do
    k = get_keys()
    if compare(k,{}) = 0 then
	
    else
	if k[1] = last then
	    
	else
	    puts(1,"Key has a code of:"&sprint(k[1])&"\n")
	    if k[1] = 1 then
		exit
	    end if
	    last = k[1]
	end if
    end if
end while
