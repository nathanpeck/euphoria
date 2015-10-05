-- An implementation of the Lempel-Ziev-Someone-Someone_else algorithm.
-- (I forgot the names of those two last guys, they both started with S's though..)
--
-- Based on the program LZSS.C by Haruhiko Okumura, 1989
-- Ported to Euphoria by Mic, 2000
--
-- Big speed improvements by Matt Lewis, 030521
-- Minor speed improvements and clean-ups by Mic, 030527
--
-- Please, DO NOT try to compress any enormous files (anything >150kB would probably take
-- forever) as these routines are very, very slow.



include file.e
include get.e


without warning
--with profile_time
sequence T
atom t, t1, t2, t3, T1, T2, T3
T = repeat( 0, 10 )


constant N=4096,
	 Np1 = N + 1,
	 F=18,
	 -- Matt Lewis 5/21/03:
	 -- Used in InsertNode to avoid subtraction in an inner loop
	 NM1 = N - 1,
	 FM1 = F-1,
	 THRESHOLD=2,
	 NIL=N


atom textsize,
     codesize,
     printcount


global atom bytes_in,
	    bytes_out

sequence text_buf,
	 dad, lson, rson

integer match_position,
	match_length

atom infile, outfile



textsize = 0
codesize = 0
printcount = 0
text_buf = repeat(0, N+F-1)
dad = repeat(0, N+1)
lson = dad
rson = repeat(0, N+257)



constant rson_init = repeat(NIL,256),
	 dad_init = repeat(NIL,N+1)
	 
-- Matt Lewis 5/21/03:
-- took arithmetic out of subscript operation
-- 
-- Simplified the code even further. No noticable speed gain, though.
-- /Mic, 030527
procedure InitTree()
	rson[N+2..N+257] = rson_init
	dad = dad_init
end procedure



-- Matt Lewis 5/21/03:
-- this makes compression about 40% faster
-- Added c1 and c2 to simplify slices and subscripts
-- Added FM1 above to be F-1, so we don't have to subract each
-- time through the loop
-- Changed "if cpm!=0" to "if cmp"
-- eliminated nasty inner loop and turned into nested if statements
-- it's ugly, but a lot faster
procedure InsertNode(integer r)
integer p,cmp,key, ii, c1, c2, r1, ls
sequence cmp2

	cmp=1
	key=r                           -- (char *)key = &text_buf[r]
	c1 = key+1
	r1 = r + 1
	p=N+1+text_buf[c1]
	c2 = p+1
	rson[r1]=NIL
	lson[r1]=NIL
	match_length=0

	while 1 do

		if (cmp>=0) then
			if rson[c2]!=NIL then
				p = rson[c2] 
				c2 = p+1
			else
				rson[c2] = r
				dad[r1] = p
				return
			end if
		else
			if lson[c2]!=NIL then
				p = lson[c2]
				c2 = p+1
			else
				lson[c2] = r
				dad[r1] = p
				return
			end if
		end if


		-- this used to be a nice looking for-loop
		-- now it's ugly, but faster (Matt)
		--
		-- Changed the indentation. Equally ugly, but at least
		-- fits on one screen. Also added a check to make sure
		-- c1 and c2 aren't equal (slightly improved performance).
		-- /Mic, 030527
		if c1=c2 then
			ii = 18
		else
		cmp = text_buf[c1+1] - text_buf[c2+1]
		if cmp then     
			ii = 1
		else
		cmp = text_buf[c1+2] - text_buf[c2+2]
		if cmp then     
			ii = 2
		else
		cmp = text_buf[c1+3] - text_buf[c2+3]
		if cmp then     
			ii = 3
		else
		cmp = text_buf[c1+4] - text_buf[c2+4]
		if cmp then     
			ii = 4
		else
		cmp = text_buf[c1+5] - text_buf[c2+5]
		if cmp then     
			ii = 5
		else
		cmp = text_buf[c1+6] - text_buf[c2+6]
		if cmp then     
			ii = 6
		else
		cmp = text_buf[c1+7] - text_buf[c2+7]
		if cmp then     
			ii = 7
		else
		cmp = text_buf[c1+8] - text_buf[c2+8]
		if cmp then     
			ii = 8
		else
		cmp = text_buf[c1+9] - text_buf[c2+9]
		if cmp then     
			ii = 9
		else
		cmp = text_buf[c1+10] - text_buf[c2+10]
		if cmp then     
			ii = 10
		else
		cmp = text_buf[c1+11] - text_buf[c2+11]
		if cmp then     
			ii = 11
		else
		cmp = text_buf[c1+12] - text_buf[c2+12]
		if cmp then     
			ii = 12
		else
		cmp = text_buf[c1+13] - text_buf[c2+13]
		if cmp then     
			ii = 13
		else
		cmp = text_buf[c1+14] - text_buf[c2+14]
		if cmp then     
			ii = 14
		else
		cmp = text_buf[c1+15] - text_buf[c2+15]
		if cmp then     
			ii = 15
		else
		cmp = text_buf[c1+16] - text_buf[c2+16]
		if cmp then     
			ii = 16
		else
		cmp = text_buf[c1+17] - text_buf[c2+17]
		if cmp then     
			ii = 17
		else
			ii = 18
		end if
		end if
		end if
		end if
		end if
		end if
		end if
		end if
		end if
		end if
		end if
		end if
		end if
		end if
		end if
		end if
		end if
		end if

		if (ii>match_length) then
			match_position = p
			match_length = ii
			if ii = F then
				exit
			end if
		end if
	end while
	
	dad[r1] = dad[c2]
	lson[r1] = lson[c2]
	rson[r1] = rson[c2]
	dad[lson[c2]+1] = r
	dad[rson[c2]+1] = r
	c1 = dad[c2]+1  
	if (rson[c1]=p) then
		rson[c1] = r
	else
		lson[c1] = r
	end if
	dad[c2] = NIL
end procedure


procedure DeleteNode(integer p)
	integer q, qp1, pp1,d

	pp1 = p + 1

	if (dad[pp1]=NIL) then return end if

	if (rson[pp1]=NIL) then
		q = lson[pp1]
		qp1 = q+1
	else
		if (lson[pp1]=NIL) then
			q = rson[pp1]
			qp1 = q+1
		else
			q = lson[pp1]
			qp1 = q+1
			if (rson[qp1]!=NIL) then
				while (rson[qp1]!=NIL) do
					q = rson[qp1]
					qp1 = q+1
				end while
				rson[dad[qp1]+1] = lson[qp1]
				dad[lson[qp1]+1] = dad[qp1]
				lson[qp1] = lson[pp1]
				dad[lson[pp1]+1] = q
			end if 
			rson[qp1] = rson[pp1]
			dad[rson[pp1]+1] = q
		end if
	end if
	
	dad[qp1] = dad[pp1]
	d = dad[pp1]+1  --/Mic, 030527
	if rson[d]=p then
		rson[d] = q
	else
		lson[d] = q
	end if
		dad[pp1] = NIL
end procedure


--with profile
global procedure Encode(sequence source,sequence dest)
integer c,len,r,s,last_match_length,code_buf_ptr,mask, loop, i_i, rp1, sp1
sequence code_buf, cb
--profile(1)
	code_buf = repeat(0,17)
	infile = open(source,"rb")
	outfile = open(dest,"wb")
	InitTree()
	code_buf_ptr = 1
	mask=1
	s = 0
	sp1 = 1
	r = N-F
	rp1 = r+1
	
	-- Got rid of the for-loop  /Mic, 030527
	text_buf[1..r] = repeat(' ',r)
	loop = 1
	len = 0

	-- mwl: simplified this loop
	while len < F do
			c = getc(infile)
			if (c=-1) then
				exit
				loop = 0
			else
				text_buf[rp1+len] = c
				len += 1
			end if
	end while

	textsize=len
	if len=0 then
		return 
	end if
	
	for i=1 to F do
		InsertNode(r-i)
	end for
	InsertNode(r)
	
	while len do
		if match_length>len then 
			match_length=len
		end if
		if match_length<=THRESHOLD then
			match_length=1
			code_buf[1]=or_bits(code_buf[1],mask)
			code_buf_ptr+=1
			code_buf[code_buf_ptr]=text_buf[rp1]

		else
			code_buf_ptr+=1
			code_buf[code_buf_ptr]=and_bits(match_position,255)
			code_buf_ptr+=1
			code_buf[code_buf_ptr]=and_bits(or_bits(and_bits(floor(match_position/16),#F0),
			(match_length-(THRESHOLD+1))),255)

		end if
		
		mask += mask
		if mask > 255 then
			-- Got rid of the for-loop  /Mic, 030527
			puts(outfile,code_buf[1..code_buf_ptr])
			codesize += code_buf_ptr
			code_buf[1] = 0
			code_buf_ptr = 1
			mask = 1
		end if
		last_match_length = match_length

		i_i = last_match_length
		for i = 1 to last_match_length do
			c = getc(infile)
			if c = -1 then
				i_i = i-1
				exit
			end if
			DeleteNode(s)

			text_buf[sp1] = c
			if (sp1<F) then 
				text_buf[sp1+N] = c 
			end if
			s = and_bits(sp1,NM1)
			sp1 = s+1
			r = and_bits(rp1,NM1)
			rp1 = r+1

			InsertNode(r)                   
		end for

		textsize+=i_i
		if textsize>printcount then 
			printcount+=1024 
		end if

		while i_i < last_match_length do
			DeleteNode(s)
			s = sp1
			if s>NM1 then s-=N end if
			sp1 = s+1
			r = rp1
			if r>NM1 then r-=N end if
			rp1 = r+1
			len-=1
			if len then 

				InsertNode(r) 
			end if
			i_i+=1
		end while
	end while
	if code_buf_ptr>1 then
		-- Got rid of the for-loop /Mic, 030527
		puts(outfile,code_buf[1..code_buf_ptr])
		codesize += code_buf_ptr
	end if

	close(infile)
	close(outfile)
	
	bytes_in = textsize
	bytes_out = codesize

end procedure  


global procedure Decode(sequence source,sequence dest)
	integer ii,j,k,r,s,c,flags,idx
	
	infile = open(source,"rb")
	outfile = open(dest,"wb")
	
	r = N-F
	flags=0

	-- Got rid of the for-loop /Mic, 030527
	text_buf[1..r] = repeat(' ',r)

	
	--profile(1)
	while 1 do
		flags = floor(flags/2)
		
		if not and_bits(flags,256) then
			c = getc(infile)
			if c=-1 then 
				exit 
			end if
			flags = c + #FF00
		end if
		if and_bits(flags,1) then
			c = getc(infile)
			if c=-1 then 
				exit 
			end if
			puts(outfile,c)
			r += 1
			text_buf[r] = c
			if r>NM1 then
				r -= N
			end if
		else
			ii = getc(infile)
			if ii=-1 then 
				exit 
			end if
			
			j = getc(infile)
			if j=-1 then 
				exit 
			end if
			
			ii = or_bits(ii,(and_bits(j,#F0)*16))
			j = and_bits(j,#0F) + THRESHOLD

			-- Added another variable for faster indexing in the 
			-- following loop
			idx = and_bits(ii,N-1)+1
		
			while j>=0 do
				c = text_buf[idx]
				idx += 1
				if idx>N then
					idx = 1
				end if
				puts(outfile,c)
				r += 1
				text_buf[r] = c
				j -= 1
				if r>NM1 then
					r = 0
				end if
			end while
			
		end if
	end while
	--profile(0)
	close(infile)
	close(outfile)
end procedure

without profile



 
	    
