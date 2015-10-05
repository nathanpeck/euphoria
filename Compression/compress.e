include misc.e
include machine.e

without warning

sequence text

text = {}

atom mem0, mem1, mem2, mem3
sequence memseq
mem0 = allocate(4)
mem1 = mem0 + 1
mem2 = mem0 + 2
mem3 = mem0 + 3
memseq = {mem0, 4}

integer fn

function crunch_bits(sequence bits)
    sequence done
    integer current_bit_val
    integer rep
    done = {}
    rep = 0
    current_bit_val = bits[1]
    for counter = 1 to length(bits) do
	if bits[counter] = current_bit_val then
	    rep = rep + 1
	else --Log it in the data
	    done = append(done,{current_bit_val,rep})
	    if counter = length(bits) then
		--Ending so there is no need to set a value.
	    else
		rep = 1
		current_bit_val = bits[counter]
	    end if
	end if
    end for
    return done
end function

function make_table(sequence data)
    sequence table
    sequence done
    integer num
    table = {}
    done = {}
    for counter = 1 to length(data) do
	num = find(data[counter],table)
	if num = 0 then
	    table = append(table,data[counter])
	    done = append(done,length(table))
	else
	    done = append(done,num)
	end if
    end for
    return {table,done}
end function

function make_bits(sequence table)
    sequence data,key,info
    data = {}
    key = table[1]
    info = table[2]
    for counter = 1 to length(info) do
	data = append(data,key[info[counter]])
    end for
    return data
end function

function decrunch_bits(sequence data)
    sequence done
    done = {}
    for counter = 1 to length(data) do
	--for loop = 1 to data[counter][2] do
	    --done = append(done,data[counter][1])
	--end for
	done = done & repeat(data[counter][1],data[counter][2])
    end for
    return done
end function

--This procedure loads an elf source codes file.
function read_file(sequence name)
    sequence text
    integer loop,n
    object line
    text = {}
    loop = 1
    n = open(name,"r") --Open the file
    if n = -1 then
	return -1
    end if
    --Read the file
    while loop = 1 do
	line = gets(n)
	if atom(line) then
	    loop = -1
	else
	    text = text & line
	end if
    end while
    return text
end function

function get4(integer where)
    poke(mem0, getc(where))
    poke(mem1, getc(where))
    poke(mem2, getc(where))
    poke(mem3, getc(where))
    return peek4u(mem0)
end function

procedure puts4(atom where,atom x)
    poke4(mem0, x) -- faster than doing divides etc.
    puts(where, peek(memseq))
end procedure

procedure save_x(sequence name,sequence table)
    integer fn
    fn = open(name,"wb")
    
    puts(fn,"XFILE ")
    puts4(fn,length(table[1]))
    for counter = 1 to length(table[1]) do
	puts(fn,table[1][counter])      
    end for
    puts(fn,table[2])
    
    close(fn)
end procedure


function load_x(sequence name)
    object data
    sequence table
    integer extent,reading
    object c
    c = 0
    table = {{},{}}
    reading = 1
    fn = open(name,"rb")
    if fn = -1 then
	return -1
    else
	if compare(getc(fn)&getc(fn)&getc(fn)&getc(fn)&getc(fn)&getc(fn),"XFILE ") = 0 then
	    extent = get4(fn)
	    for counter = 1 to extent do
		table[1] = append(table[1],{getc(fn),getc(fn)})
	    end for
	    while reading = 1 do
		c = gets(fn)
		if atom(c) then
		    reading = -1
		else
		    table[2] = table[2] & c
		end if
	    end while
	else
	    return -2
	end if
    end if
    return table
end function

global procedure crunch(sequence name, sequence name2)
    sequence table
    text = read_file(name)
    
    puts(1,"\n")
    puts(1,"Processing.....")
    table = make_table(crunch_bits(text))
    puts(1,"Done\n")
    
    puts(1,"Saving file....")
    save_x(name2,table)
    puts(1,"Done\n")
end procedure

global procedure decrunch(sequence name, sequence name2)
    sequence table
    puts(1,"Loading file...")
    table = load_x(name)
    puts(1,"Done\n")
    
    fn = open(name2,"w")
    
    puts(1,"Decoding and saving.....")
    puts(fn,decrunch_bits(make_bits(table)))
    puts(1,"Done\n")
    
    close(fn)
end procedure
