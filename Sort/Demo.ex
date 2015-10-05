include slib.e
include misc.e

puts(1,"Sorting 5000 trials...\n\n")

sequence x

x = repeat(0,5000)

for counter = 1 to length(x) do
    x[counter] = rand(counter)
end for

atom t,t2

t = time()

x = sort(x)

t2 = time()

puts(1,"That took: "&sprint(t2-t)&" seconds!\n"&sprint((t2-t)/5000)&" seconds per trial!")
