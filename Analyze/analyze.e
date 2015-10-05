without type_check
without warning
without trace
without profile

include misc.e
include graphics.e

sequence possibles
sequence checks
sequence hits

integer x

hits = {}

x = 0

--This reads a file by its lines and return the result.
global function read_file(sequence name)
    integer loop --The while loop
    integer fn   --fn = file number
    object line --The current line being read
    sequence lines
    
    loop = 1
    lines = {}
    fn = open(name,"r") --Open the file
    if fn = -1 then
	return -1
    end if

    --Read the file
    while loop = 1 do
	line = gets(fn)  --Get either a line, or a -1
	if atom(line) then --Finished?
	    loop = -1
	else
	    lines = lines & line
	end if
    end while
    
    return lines
end function

--This routine removes a subscript from a sequence using sequence slicing.
--Pass the input to seq and the subscript number to remove to index
global function remove(sequence seq, integer index)
    if index = length(seq) then
	seq = seq[1..length(seq)-1]  --Remove it!
    elsif index = 1 then
	if length(seq) = 1 then
	    return {} --Remove it!
	elsif length(seq) = 2 then
	    return {seq[2]} --Remove it!
	else
	    seq = seq[2..length(seq)]
	end if
    else
	seq = seq[1..index-1]&seq[index+1..length(seq)] --Remove it!
    end if
    return seq --Return the value.
end function

function process(sequence data)
    integer pos
    integer fn
    atom per
    atom old_per
    integer c
    integer l
    l = length(data)
    
    per = 0
    
    pos = 1
    
    x = 0
    
    while 1 do
	old_per = per
	per = ((pos*100)/l)
	if per = old_per then
	else
	    position(2,1)
	    puts(1,sprint(floor(per*10)/10)&"%  ")
	end if
	if get_key() != -1 then
	    x = 1
	    exit
	end if
	c = data[pos]
	if c >= 65 and c <= 90 then
	    data[pos] = c + 32
	    pos = pos + 1
	elsif c >= 97 and c <= 122 then
	    pos = pos + 1
	else
	    data = remove(data,pos)
	    l = l - 1
	end if
	if pos > l then
	    exit
	end if
    end while
    
    fn = open("out.txt","w")
    puts(fn,data)
    close(fn)
    
    return data
end function

procedure check(integer c)
    for counter = 1 to length(checks) do
	if checks[counter][possibles[counter]] = c then
	    possibles[counter] = possibles[counter] + 1
	    if possibles[counter] = length(checks[counter]) then
		hits = append(hits,counter)
		possibles[counter] = 1
	    end if
	else
	    possibles[counter] = 1
	end if
    end for
end procedure

cursor(NO_CURSOR)

global function analyze(sequence name,integer greatest,sequence keys)
    object data
    integer jump
    integer len
    jump = 1
    
    data = read_file(name)
    
    if atom(data) then
	return -1
    else
	data = process(data)
	
	if x = 1 then
	    abort(1)
	end if
	
	checks = keys
	possibles = repeat(1,length(keys))
	
	puts(1,"\nWorking")
	
	while jump < greatest do
	    jump = jump + 1
	    for offset = 1 to jump-1 do
		len = floor((length(data)+offset)/jump)
		while (len*jump)+offset > length(data) do
		    len = len - 1
		end while
		for pos = 0 to len do
		    check(data[(pos*jump)+offset])
		end for
	    end for
	end while
	return hits
    end if
end function
