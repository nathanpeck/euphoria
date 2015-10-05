include objpos.e

puts(1,"This compares two different methods of checking\n"&
       "to see if one object is within a certain range of another.\n"&
       "The new method I made is not as accurate and is slower.\n\n")

integer range

range = 256

integer r1,r2,r3,r4

atom t1,t2

t1 = time()

for counter = 1 to 100000 do
    r1 = rand(range)
    r2 = rand(range)
    r3 = rand(range)
    r4 = rand(range)
    
    if i_region({r1,r2},{r3,r4},4,8) = 1 then
	--puts(1,sprint({{r1,r2},{r3,r4}})&"\n")
    end if
end for

t2 = time()

puts(1,"New procedure: "&sprint(t2-t1)&"\n")

t1 = time()

for counter = 1 to 100000 do
    r1 = rand(range)
    r2 = rand(range)
    r3 = rand(range)
    r4 = rand(range)
    
    if in_region({r1,r2},{r3,r4},4) = 1 then
    end if
end for

t2 = time()

puts(1,"Normal procedure: "&sprint(t2-t1))







