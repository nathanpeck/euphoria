puts(1,"Loading\n")

without warning
without type_check

atom t1
atom t2

include elfin.e --The algorithm

SetPassword("12345678") --VERY insecure

integer fn

constant source = read_file("vbe20.txt")
constant size = 70987

sequence stuff

puts(1,"Encrypting\n")

t1 = time()

stuff = Encrypt(source)

t2 = time()

fn = open("cyber.txt","wb")

puts(fn,stuff)

close(fn)

puts(1,sprint(floor(size/(t2-t1))/1000)&" kb per second encoding.\n\n")

constant encrypted = read_file("cyber.txt")

puts(1,"Decrypting\n")

t1 = time()

stuff = Decrypt(encrypted)

t2 = time()

fn = open("plain.txt","wb")

puts(fn,stuff)

close(fn)

puts(1,sprint(floor(size/(t2-t1))/1000)&" kb per second decoding.\n\n")

puts(1,"Verifying\n\n")

constant plain_text = read_file("plain.txt")

if compare(plain_text,source) = 0 then --If equal
    puts(1,"Elfin correctly encoded and decoded.")  
else
    puts(1,"Elfin crashed!")
end if
