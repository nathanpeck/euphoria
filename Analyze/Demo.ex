include analyze.e
include get.e

constant t = {"nathan"}

sequence h
sequence f

f = repeat(0,length(t))

sequence name

name = prompt_string("Please enter a filename:")

integer fn

fn = open(name,"r")

if fn = -1 then
    puts(1,"Unable to load file specified!")
    abort(1)
else
    close(fn)
end if

h = analyze(name,200,t)

for counter = 1 to length(h) do
    f[h[counter]] = f[h[counter]] + 1
end for

puts(1,"\n")

for counter = 1 to length(t) do
    puts(1,t[counter]&" was found "&sprint(f[counter])&" times!\n")
end for

