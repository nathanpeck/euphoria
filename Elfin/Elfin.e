-- ллл л   ллл ллл л   л
-- л   л   л    л  лл  л
-- лл  л   лл   л  л л л
-- л   л   л    л  л  лл
-- ллл ллл л   ллл л   л
--
-- This is an encryption algorithm that features 2048 bit keys.
-- For more details see elfin.txt
--
-- Copyright (C) 2004 by Nathan Peck
--
-- Project completed June 14,2004


include misc.e      --Miscellaneous operations
include machine.e   --Machine operations

--Make it as fast as possible!
without type_check
without warning
without trace

integer fn

sequence key_box
sequence key_table
sequence global_key

key_box = repeat(0,16)

--This reads a file and returns the result.
global function read_file(sequence name)
    integer fn   --fn = file number
    integer char --The current line being read

    sequence file

    fn = open(name,"rb") --Open the file for binary reading
    if fn = -1 then
	return -1
    end if

    file = {}

    --Read the file
    while 1 do
	char = getc(fn)  --Get either a char, or a -1
	if char = -1 then
	    exit
	else
	    file = append(file,char) --Add it to the list
	end if
    end while

    return file
end function


--This procedure loads the key_box table
procedure init()
    integer fn
    sequence check
    object row
    object row2

    fn = open("Elfin.dat","r")

    if fn = -1 then
	puts(1,"Error! Please generate Encrypt.dat again.")
    else
	check = gets(fn)
	if compare(check,"Elfin\n") = 0 then
	    for counter = 1 to 16 do
		row = gets(fn)
		if compare(row,-1) = 0 then
		    puts(1,"Error! Please generate Encrypt.dat again.")
		else
		    if length(row) < 16 then
			row2 = gets(fn)
			if compare(row2,-1) = 0 then
			    puts(1,"Error! Please generate Encrypt.dat again.")
			else
			    for x = 1 to length(row2) do
				row = append(row,row2[x])
			    end for
			end if
		    end if
		    row = row[1..16]
		    key_box[counter] = row
		end if
	    end for
	else
	    puts(1,"Error! Please generate Encrypt.dat again.")
	end if
    end if
end procedure

--This procedure does a modulus addition
function mod_add(integer source, integer num)
    integer x
    x = source + num
    if x > 255 then
	x = x - 255
    end if
    return x
end function

--This procedure does a modulus subtraction
function mod_sub(integer source, integer num)
    atom x
    x = source - num
    if x < 0 then
	x = (255+x)
    end if
    return x
end function

--This function shifts a bit sequence to the left
function shift_left(sequence bits, integer num)
    integer bit

    bit = bits[1]           --Get the first bit
    bits = bits[2..length(bits)]    --Cut it off
    bits = append(bits,bit) --Put it on the end

    num = num - 1

    if num > 0 then
	bits = shift_left(bits,num) --Repeat
    end if

    return bits
end function

--This procedure sets the key.
global procedure SetKey(sequence bits)
    integer pos
    sequence bit8_key
    sequence key_bits
    pos = 1

    key_table = key_box
    global_key = bits

    for y = 1 to length(key_table) do
	for x = 1 to length(key_table[y]) do
	    bit8_key = bits[pos..pos+7] --Get an 8 bit chunk
	    key_bits = int_to_bits(key_table[y][x],8)
	    key_bits = xor_bits(key_bits,bit8_key) --Xor the keybox
	    key_table[y][x] = bits_to_int(key_bits)
	    pos = pos + 1 --Move on
	    if pos + 8 > length(bits) then
		bits = shift_left(bits,2)
		pos = 1 --Start over
	    end if
	end for
    end for

end procedure

--This procedure Encrypts a sequence.
--It is the heart of the algorithm.
global function Encrypt(sequence data)
    sequence done
    sequence char_bits
    sequence key_bitx
    sequence key_bity
    sequence key_bits
    sequence result
    sequence key_chunk
    sequence private_key

    integer key
    integer x
    integer y
    integer char
    integer pos
    integer mod
    integer last

    private_key = global_key
    done = data
    pos = 1

    last = 11

    --The stream cipher loop
    for counter = 1 to length(data) do

	--Get the current char.
	char = data[counter]

	--Get part of the key
	key_chunk = private_key[pos..pos+7]

	--Calculate a keybox position
	key_bitx = key_chunk[1..4]
	key_bity = key_chunk[5..8]
	x = bits_to_int(key_bitx)
	y = bits_to_int(key_bity)

	--Get and translate a keybox value
	key = key_table[y+1][x+1]
	key_bits = int_to_bits(key,8)

	--Calculate and add a modulus.
	mod = bits_to_int(key_bits)
	char = mod_add(char,mod)
	char = mod_add(char,last)

	if key_chunk[1] = 1 then
	    key_chunk = xor_bits(key_chunk,int_to_bits(mod_add(last,11),8))
	    private_key[pos..pos+7] = key_chunk
	    --Get the current unencrypted char.
	    last = done[counter]
	else
	    key_chunk = or_bits(key_chunk,int_to_bits(last,8))
	    private_key[pos..pos+7] = key_chunk
	    --Get the current unencrypted char.
	    last = done[counter]+11
	end if

	--Save the result
	done[counter] = char

	--Move on
	pos = pos + 1
	if pos+7 > length(private_key) then
	    private_key = shift_left(private_key,bits_to_int(key_chunk[1..2]))
	    pos = 1
	end if
    end for

    return done
end function

--This procedure Decrypts a sequence.
global function Decrypt(sequence data)
    sequence done
    sequence char_bits
    sequence key_bitx
    sequence key_bity
    sequence key_bits
    sequence result
    sequence key_chunk
    sequence private_key

    integer key
    integer x
    integer y
    integer char
    integer pos
    integer mod
    integer last

    private_key = global_key
    done = repeat(0,length(data))
    pos = 1
    last = 11

    --The stream cipher loop
    for counter = 1 to length(data) do

	--Get the current char.
	char = data[counter]

	char = mod_sub(char,last)

	--Get part of the key
	key_chunk = private_key[pos..pos+7]

	--Calculate a keybox position
	key_bitx = key_chunk[1..4]
	key_bity = key_chunk[5..8]
	x = bits_to_int(key_bitx)
	y = bits_to_int(key_bity)

	--Get and translate a keybox value
	key = key_table[y+1][x+1]
	key_bits = int_to_bits(key,8)

	--Calculate and add a modulus.
	mod = bits_to_int(key_bits)
	char = mod_sub(char,mod)

	--Save the result
	done[counter] = char

	if key_chunk[1] = 1 then
	    key_chunk = xor_bits(key_chunk,int_to_bits(mod_add(last,11),8))
	    private_key[pos..pos+7] = key_chunk
	    last = done[counter]
	else
	    key_chunk = or_bits(key_chunk,int_to_bits(last,8))
	    private_key[pos..pos+7] = key_chunk
	    last = done[counter]+11
	end if

	--Move on
	pos = pos + 1
	if pos+7 > length(private_key) then
	    private_key = shift_left(private_key,bits_to_int(key_chunk[1..2]))
	    pos = 1
	end if

    end for

    return done
end function

--Encrypt a file using the current key.
global function EncryptFile(sequence in, sequence out)
    sequence data

    data = read_file(in) --Read the file

    fn = open(out,"wb") --Must be in binary mode for reading, maybe not for writing

    if fn = -1 then
	return -1 --Error
    else
	puts(fn,Encrypt(data)) --Write the cyber text
	close(fn)
	return 1  --Success
    end if
end function

--Encrypt a file using the current key.
global function DecryptFile(sequence in, sequence out)
    sequence data

    data = read_file(in) --Read the file

    fn = open(out,"wb") --Must be in binary mode for reading, maybe not for writing

    if fn = -1 then
	return -1 --Error
    else
	puts(fn,Encrypt(data)) --Write the cyber text
	close(fn)
	return 1  --Success
    end if
end function

function rand_key(integer seed)
    sequence result

    set_rand(seed)

    result = repeat(0,4096)

    for counter = 1 to length(result) do
	result[counter] = rand(2)-1 --Set bit to one or zero.
    end for

    return result
end function

--This function is reportedly from crypto10.e
function makeseed(sequence d)
--given a 'string', generate a unique number based upon that
--string, ranging from 1 to over 1,000,000,000.
atom s s = 0
   for i = 1 to length(d) do
       s = s + ( d[i] * power(2,i+1) )
   end for
   return s
end function

global procedure SetPassword(sequence password)
    SetKey(rand_key(makeseed(password)))
end procedure

init() --Load the data set

SetPassword("Elfin password")
