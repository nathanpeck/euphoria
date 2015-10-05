--This was a simple one day project!
--
--The routines:
--  s = add(s,a)  This adds a value to a presorted sequence
--  s = sort(s)   This sorts a sequences of values.

global function add(sequence s, atom a)
    integer n
    integer l
    integer m

    l = length(s)
    m = floor(l/2)

    if l = 0 then
	s = {a}
    else
	if a <= s[l] then           --Is it greater than greatest value?
	    s = append(s,a)
	elsif a >= s[1] then        --Is it less than smallest value?
	    s = prepend(s,a)
	elsif a < s[floor(m/2)] then        --Before 1/4?
	    n = floor(m/2)+1
	    while 1 do
		if s[n] > a then
		    n = n + 1
		else
		    s = append(s[1..n-1],a)&s[n..l]
		    exit
		end if
		if n > l then
		    s = append(s,a)
		    exit
		end if
	    end while
	elsif a < s[m-floor(m/2)] then      --Before halfway but greater than 1/4
	    n = m-floor(m/2)+1
	    while 1 do
		if s[n] > a then
		    n = n + 1
		else
		    s = append(s[1..n-1],a)&s[n..l]
		    exit
		end if
		if n > l then
		    s = append(s,a)
		    exit
		end if
	    end while
	elsif a < s[m] then         --Is it's position less than half way?
	    n = m+1
	    while 1 do
		if s[n] > a then
		    n = n + 1
		else
		    s = append(s[1..n-1],a)&s[n..l]
		    exit
		end if
		if n > l then
		    s = append(s,a)
		    exit
		end if
	    end while
	else                        --Oh well!
	    n = 1
	    while 1 do
		if s[n] > a then
		    n = n + 1
		else
		    s = append(s[1..n-1],a)&s[n..l]
		    exit
		end if
		if n > l then
		    s = append(s,a)
		    exit
		end if
	    end while
	end if
    end if
    return s
end function

global function sort(sequence stuff)
    sequence result
    result = {}
    for counter = 1 to length(stuff) do
	result = add(result,stuff[counter]) --Quite complicated, eh? :)
    end for
    return result
end function
