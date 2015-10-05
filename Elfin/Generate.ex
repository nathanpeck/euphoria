include get.e

sequence ensure

ensure = prompt_string("Are you sure you want to change the data set?\n"&
		       "If you have already made encrypted files with\n"&
		       "ENCRYPT, you will have to use the old data set\n"&
		       "to decode them.  If you don't have a backup of\n"&
		       "the old encrypt.dat you will no longer be able\n"&
		       "to decrypt the old files!\n\n"&
		       "If you are sure type, \"y\" (case must match)\n\n")

if compare(ensure,"y") = 0 then
    puts(1,"\n\n")
else
    abort(1) --Don't continue
end if

sequence table
sequence list
integer pos
sequence done

table = repeat(0,16)

done = {}

list = repeat(-1,256)

puts(1,"Step 1\n")

--Generate a random table of numbers
for counter = 0 to 255 do
    pos = rand(256)
    while 1 do
	if find(pos,done) = 0 then
	    done = append(done,pos)
	    exit
	else
	    pos = rand(256) --Recalculate
	end if
    end while
    list[pos] = counter
end for

puts(1,"Step 2\n")

for y = 1 to 16 do
    table[y] = list[(y-1)*16+1..y*16]
end for

puts(1,"Step 3\n")

integer fn

fn = open("Elfin.dat","w")

if fn = -1 then
    puts(1,"Critical disk I/O error!")
end if

puts(fn,"Elfin\n")

for y = 1 to length(table) do
    puts(fn,table[y]&"\n")
end for

puts(1,"Success!")
