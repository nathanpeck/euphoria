--This is a generator for random, unique levels for platfrom games!
--genlev

include database.e
include get.e

sequence bl  --Below list
sequence ll  --Left list
sequence lb  --Left below list
sequence pl  --Place list

bl = {}     ll = {}     pl = {}     lb = {}

function load_level(sequence name)
    integer level_x,level_y
    sequence level_objects
    if db_open(name,DB_LOCK_NO) != DB_OK then
	puts(1,"Error opening file!")
	while get_key() = -1 do
	    --Wait for key
	end while
	abort(-1)
    else
	if db_select_table("POSITION") = DB_OK then
	    level_x = db_record_data(1)
	    level_y = db_record_data(2)
	    if db_select_table("LEVEL_OBJECTS") = DB_OK then
		level_objects = db_record_data(1)
		db_close()
	    else
		puts(1,"Level error!")
		while get_key() = -1 do
		    --Wait for key
		end while
		abort(-1)
	    end if
	else
	    puts(1,"Level error!")
	    while get_key() = -1 do
		--Wait for key
	    end while
	    abort(-1)
	end if
    end if
    return {level_x,level_y,level_objects}
end function

sequence data

data = load_level("rules.dat") --Seed level

data = data[3]

data = data[1..length(data)-1]

integer b1,l1

integer pos,i

for y = 1 to length(data) do
    for x = 1 to length(data[1]) do
	--What's to the left?
	if x = 1 then
	    l1 = -1
	else
	    l1 = data[y][x-1]
	end if
	--What's below?
	if y = length(data) then
	    b1 = -1
	else
	    b1 = data[y+1][x]
	end if
	--What is in that position / add it to the tables
	pos = find(b1,bl)
	if pos = 0 then
	    bl = append(bl,b1)
	    ll = append(ll,{l1})
	    pl = append(pl,{{data[y][x]}})
	else
	    i = find(l1,ll[pos])
	    if i = 0 then
		ll[pos] = append(ll[pos],l1)
		pl[pos] = append(pl[pos],{data[y][x]})
	    else
		if find(data[y][x],pl[pos][i]) then
		    --Skip it
		else
		    pl[pos][i] = append(pl[pos][i],data[y][x])
		end if
	    end if
	end if
    end for
end for

sequence level
integer l

integer loop
integer error
integer id

procedure erase(integer x)
    for y = 1 to length(level) do
	level[y][x] = 99
    end for
end procedure

integer n

integer col


integer x


global function generate_level()

    col = 1
    level = repeat(repeat(0,length(data[1])),length(data))
    x = 0
    error = 0
    
    while col = 1 do
	x = x + 1
	call_proc(GENERATE_PROGRESS,{x})
	if x = 161 then
	    exit
	end if
	loop = 1
	n = 0
	while loop = 1 do
	    call_proc(ACTION,{})
	    n = n + 1
	    error = 0
	    id = 0
	    if get_key() = 27 or n = 1000 then
		if x >= 5 then
		    x = x - 4
		else x = 1
		end if
		exit
	    end if
	    for y = length(level) to 1 by -1 do
		if x = 1 then
		    l1 = -1
		else
		    l1 = level[y][x-1]
		end if
		if y = length(level) then
		    b1 = -1
		else
		    b1 = level[y+1][x]
		end if
		pos = find(b1,bl)
		if pos = 0 then
		    --Error!
		    loop = 1
		    error = 1
		else
		    i = find(l1,ll[pos])
		    if i = 0 then
			--Error!
			loop = 1
			error = 1
		    else
			l = length(pl[pos][i])
			id = pl[pos][i][rand(l)]
			level[y][x] = id
			if id = -1 then
			    error = 1
			end if
			if error = 0 then
			    loop = -1
			end if
		    end if
		end if
	    end for
	end while
    end while
    return level
end function

procedure save_level(sequence name,sequence data)
    if db_create(name,DB_LOCK_NO) = DB_OK then
	if db_create_table("POSITION") = DB_OK then
	    if db_select_table("POSITION") = DB_OK then
		if db_insert("X_START_POS",data[1]) = DB_OK then
		    if db_insert("Y_START_POS",data[2]) = DB_OK then
			if db_create_table("LEVEL_OBJECTS") = DB_OK then
			    if db_select_table("LEVEL_OBJECTS") = DB_OK then
				if db_insert("PLAY_FIELD",data[3]) = DB_OK then
				    --puts(1,"Success!")
				    db_close()
				end if
			    end if
			end if
		    end if
		end if
	    end if
	end if
    else
	puts(1,"Couldn't create the database!")
	while get_key() = -1 do
	    --Wait for key
	end while
	abort(-1)
    end if
end procedure












