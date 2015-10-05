--This file contains misc, sequence, find, and file operations.

--May 3, 2004

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
	    lines = append(lines,line)  --Add the line to sequence lines
	end if
    end while

    return lines
end function

--This routine removes all subscripts less than index.
global function remove_less_than(sequence seq, integer index)
    if index <= 1 then
	--Nothing happens
    elsif index >= length(seq) then
	seq = {}
    else
	seq = seq[index..length(seq)]
    end if

    return seq
end function

--This routine removes all subscripts greater than index.
global function remove_greater_than(sequence seq, integer index)
    if index >= length(seq) then
	--Nothing happens
    elsif index <= 1 then
	seq = {}
    else
	seq = seq[index..length(seq)]
    end if

    return seq
end function

--Find an object in a sequence at a point greater than integer where
function find_greater(object what, sequence source, integer where)
    integer n
    source = remove_less_than(source,where)
    n = find(what,source)
    if n = 0 then

    else
	n = n + where
    end if

    return n
end function

--Find an object in a sequence at a point greater than integer where
function find_less(object what, sequence source, integer where)
    source = remove_greater_than(source,where)

    return find(what,source)
end function

--This routine removes a subscript from a sequence using sequence slicing.
--Pass the input to seq and the subscript number to remove to index
global function remove(sequence seq, integer index)
    if compare(seq,{}) = 0 then
	--This traps errors
    end if
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
    elsif index > length(seq) then
	--  These two statements...
    elsif index <= 0 then
	--  ...trap errors.
    else
	seq = seq[1..index-1]&seq[index+1..length(seq)] --Remove it!
    end if

    return seq --Return the value.
end function

--This routine removes all subscripts of a sequence that match object o.
global function remove_subscripts(sequence seq, object o)
    integer removing
    removing = 1

    while removing > 0 do
	if compare(seq[removing],o) = 0 then  --If they match...
	    seq = remove(seq,removing)        --...remove the subscript.
	    --Don't add onto removing because the position is still the same.
	else
	    removing = removing + 1 --Don't remove it, move on.
	end if
	if removing > length(seq) then
	    removing = 0 --End the loop, we are done.
	end if
    end while

    return seq
end function

--This routine returns a list of all different members of a sequence
global function members(sequence seq)
    sequence m --For members
    m = {}

    for counter = 1 to length(seq) do
	if find(seq[counter],m) = 0 then -- If it's new...
	    m = append(m,seq[counter])   -- ...add it to the list
	end if
    end for

    return m
end function

--This replaces all o1's in seq with o2's
global function replace_all(sequence seq, object o1, object o2)
    --o1 is what to find
    --o2 is what to replace all occurences of o1 with.

    for counter = 1 to length(seq) do
	if compare(seq[counter],o1) = 0 then  -- If it equals o1...
	    seq[counter] = o2                 -- ...replace it with o2
	end if
    end for

    return seq
end function

