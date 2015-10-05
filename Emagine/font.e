--  file    : font.e
--  author  : jiri babor
--  email   : jbabor@paradise.net.nz
--  project : graphics font library
--  tool    : euphoria 2.2
--  date    : 00-02-05
--  version : 5.30
--  UPDATED FOR USE WITH THE ESCREEN LIBRARY : NOVEMBER 2003

--  font file format
--      byte 1: ascii code of the first char
--      byte 2: ascii code of the last char
--      byte 3: width in bytes
--      byte 4: height in pixels
--      byte 5: version                           unused
--      byte 6: baseline height
--      next block of bytes: actual char widths
--      next block of bytes: simple char bitmaps, left-to-right, top-to-bottom

without type_check
without warning

global constant ROM = 1,-- 8x16 rom font - default

    -- attributes are 'additive', e.g.: BOLD+SHADOW=1+4=5
    NONE        = 0,    -- plain
    BOLD        = 1,
    ITALIC      = 2,
    SHADOW      = 4,
    UNDERLINE   = 8,

    -- (multi-)line justification
    LEFT        = 0,
    CENTRE      = 1,
    RIGHT       = 2,
    BOXED       = 4

object fc           -- text foreground color or 2-d pattern (tile)

sequence
    baselines,      -- baseline heights of all loaded fonts
    byte_widths,    -- max byte widths of all loaded fonts
    font,           -- currently loaded font image
    fonts,          -- all loaded fonts (images)
    heights,        -- heights of all loaded fonts
    io,             -- italic line offset
    names,          -- font filenames
    width,          -- char widths of current font (in pixels)
    widths          -- char widths of all loaded fonts (in pixels)

integer
    at,             -- current combined attributes
    baseline,       -- baseline height of current font
    byte_width,         -- max byte width of current font
    bold,           -- boldface flag (also is bold offset)
    ecp,            -- extra char pitch (extra kerning space)
    elp,            -- extra line pitch (extra line spacing)
    f,              -- current font handle
    height,         -- nominal height of current font
    hso,            -- horizontal shadow offset
    italic,         -- italic flag
    ju,             -- text justification (see global constants above)
    pc,             -- paper color, prompt background
    sc,             -- shadow color
    shadow,         -- shadow flag
    underline,      -- underline flag
    vso,            -- vertical shadow offset
    x,              -- text pointer: left edge char space
    y               -- text pointer: top  edge char space

--  defaults
object
    default_foreground
integer
    default_attributes,
    default_extra_char_pitch,
    default_extra_line_pitch,
    default_font,
    default_horizontal_shadow_offset,
    default_justification,
    default_paper_color,
    default_shadow_color,
    default_vertical_shadow_offset


function rtrim(sequence s)
    -- trim (discard) trailing zeros of sequence s
    integer i
    i=length(s)
    while i do
	if s[i] then exit end if
	i-=1
    end while
    return s[1..i]
end function

procedure expand_foreground_pattern()
    integer maxwidth

    if sequence(fc) then
	maxwidth = 8*byte_width+floor(height/4)+ecp+1
	for i=1 to length(fc) do
	    while length(fc[i]) < maxwidth do fc[i] &= fc[i] end while
	end for
	while length(fc) < height do fc &= fc end while
    end if
end procedure -- expand_foreground_pattern

function rle(sequence s)
    -- return run-length-encoded *bit* sequence s
    -- trailing zeros are not counted, simply trimmed off
    -- count always starts with count of leading zeros

    sequence u
    integer flag,sum

    s=rtrim(s)
    flag=1
    sum=0
    u={}
    for i=1 to length(s) do
	if flag xor s[i] then
	    sum+=1
	else
	    u&=sum
	    flag=not flag
	    sum=1
	end if
    end for
    if sum then u&=sum end if
    return u
end function -- rle

function loaded(sequence name)
    -- returns allocated handle if font already loaded, else zero
    integer f
    f=0
    for i=1 to length(names) do
	if equal(name,names[i]) then
	    f=i exit
	end if
    end for
    return f
end function -- loaded

global procedure align(integer some_other_font)
    -- align current font with some_other_font
    if some_other_font>0 and some_other_font<=length(baselines) then
	y+=baselines[some_other_font]-baseline
    end if
end procedure -- align

global function font_height(integer f)
    return heights[f]
end function

global function font_baseline(integer f)
    return baselines[f]
end function

global function attributes()
    return at
end function

global procedure set_attributes(integer a)
    at=a
    bold=and_bits(at,BOLD)              -- new bold flag & offset
    italic=and_bits(at,ITALIC)!=0       -- new italic flag
    shadow=and_bits(at,SHADOW)!=0       -- new shadow flag
    underline=and_bits(at,UNDERLINE)!=0 -- new underline flag
end procedure

global procedure select_font(integer fh)
    -- select font with handle fh, make it current

    if fh>0 and fh<=length(fonts) and f!=fh then
	f = fh                  -- current handle
	font = fonts[f]         -- current font images
	width = widths[f]       -- widths of current font
	height = heights[f]     -- heights of current font
	baseline = baselines[f] -- baseline height of current font
	byte_width = byte_widths[f]
	-- calculate italic offsets
	io = repeat(0,height)
	for i=1 to height do
	    io[i] = floor((height-i)/4)
	end for
	expand_foreground_pattern()
    end if
end procedure -- select_font

global procedure reset_font()
    -- reset current font to defaults

    set_attributes(default_attributes)
    fc = default_foreground
    pc = default_paper_color
    sc = default_shadow_color
    ju = default_justification
    ecp = default_extra_char_pitch
    elp = default_extra_line_pitch
    hso = default_horizontal_shadow_offset  -- right
    vso = default_vertical_shadow_offset    -- down
    select_font(default_font)
end procedure -- reset_font

procedure load_rom_font()
    sequence regs, cb
    atom a

    -- first load : initialize fonts

    -- load 8x16 font
    regs = repeat(0,10)
    regs[REG_AX]=#1130
    regs[REG_BX]=#600
    regs=dos_interrupt(#10,regs)
    a=#10*regs[REG_ES]+regs[REG_BP]+16  -- bypass zero char
    font={}
    for i=1 to 255 do                   -- bypass zero char
	cb=rtrim(peek({a,16}))          -- char bytes, right trimmed
	for j=1 to length(cb) do
	    cb[j]=rle(and_bits(cb[j],{128,64,32,16,8,4,2,1}) and 1)
	end for
	a+=16
	font=append(font,cb)
    end for
    names={"rom8x16"}
    fonts={font}
    widths={repeat(8,255)}
    heights = {16}
    baselines = {12}
    byte_widths = {1}
    f=0
end procedure -- load_rom_fonts

global function load_font(sequence file_name)
    -- load font file into memory and make it available for selection
    object junk
    integer n,fn,byte_width,fc,first_char,last_char,size,he,bh
    sequence fo,row_bits,cs,cbs,wi

    n=loaded(file_name)
    if n then           -- if font already loaded, just select it
	select_font(n)
	return n
    else
	fn=open(file_name, "rb")
	if fn=-1 then
	    junk=graphics_mode(-1)
	    puts(1, "Font load error: " & file_name & " not found !\n")
	    abort(1)
	end if
	names=append(names,file_name)
	fc=getc(fn)
	last_char=getc(fn)
	byte_width=getc(fn)
	he=getc(fn)                 -- nominal height
	junk=getc(fn)               -- version number, unused
	bh=getc(fn)                 -- baseline height
	if bh=0 then bh=he end if   -- emergency solution for pre 3.xx fonts

	-- get widths
	wi=repeat(0,255)
	if fc=0 then                -- skip zero char
	    first_char=1
	    junk=getc(fn)           -- discard zero char
	else first_char=fc
	end if
	for i=first_char to last_char do
	    wi[i]=getc(fn)
	end for

	-- get char images
	fo=repeat({},255)
	size=he*byte_width
	if fc=0 then                -- again skip zero char
	    first_char=1
	    for i=1 to size do      -- dump
		junk=getc(fn)
	    end for
	end if
	for i=first_char to last_char do
	    cbs=repeat(0,size)      -- char byte sequence
	    cs={}                   -- char sequence of row bit sequences
	    for j=1 to size do
		cbs[j]=getc(fn)
	    end for
	    cbs=rtrim(cbs)          -- remove trailing (bottom) bytes
	    row_bits={}
	    for j=1 to length(cbs) do
		row_bits &= (and_bits(cbs[j],{128,64,32,16,8,4,2,1}) and 1)
		if remainder(j,byte_width)=0 then
		    cs=append(cs,rle(rtrim(row_bits)))
		    row_bits={}
		end if
	    end for
	    if length(row_bits) then
		cs=append(cs,rle(rtrim(row_bits)))
	    end if
	    fo[i]=cs
	end for
	close(fn)
	fonts = append(fonts,fo)
	widths = append(widths,wi)
	heights &= he
	baselines &= bh
	byte_widths &= byte_width
	n = length(fonts)
	return n
    end if
end function  -- load_font

global function lengths(sequence text)
    -- return sequence of lengths, in pixels, of substrings
    -- of text (using current font, attributes and parameters)
    -- substrings are delimited by embedded newline chars
    -- extra lengths of shadows are *ignored*

    object len
    integer a,b,c,l,w,it

    len={}   l=0
    b=bold                              -- current bold flag/offset
    a=at                                -- current combined attributes
    it=italic                           -- current italic flag
    for i=1 to length(text) do
	c=text[i]
	if c<=0 then
	    a=-c
	    b=and_bits(a,BOLD)          -- new bold offset
	    it=and_bits(a,ITALIC)!=0    -- new italic flag
	elsif c=10 then                 -- new line
	    if l then
		if it then
		    l += io[1]          -- extra italic length of last char
		end if
	    end if
	    len &= l                    -- append length of previous line
	    l=0                         -- starting length of new line
	elsif c<256 then                -- writable char
	    w=width[c]
	    if w then l += w+ecp+b end if
	end if
    end for
    if l then
	if it then
	    l += io[1]                  -- extra italic length of last char
	end if
    end if
    return len & l                      -- append also length of last line
end function   -- lengths

function substrings(sequence s)
    -- return sequence of substrings
    -- substrings are separated by embedded newlines
    sequence os
    integer i,l
    os={}
    l=length(s)
    if l then
	i=1
	for j=1 to l do
	    if s[j]=10 then
		os=append(os,s[i..j])
		i=j+1
	    end if
	end for
	if i<=l then os=append(os,s[i..l]) end if
    end if
    return os
end function -- substrings

global procedure write_char(integer ch)
    -- print single character using current font attributes

    sequence c,cr
    integer u,v,w

    w=width[ch]
    if w then
	c=font[ch]          -- rle char image
	if shadow then
	    v=y+vso
	    for r=1 to length(c) do
		u=x+hso
		if italic then
		    u+=io[r]
		end if
		cr=c[r]         -- row of char image
		for j=1 to length(cr) by 2 do
		    u+=cr[j]
		    set_pixel(repeat(sc,cr[j+1]+bold),{u,v})
		    u+=cr[j+1]
		end for
		v+=1
	    end for
	    if underline then
		set_pixel(repeat(sc,w+bold+ecp),{x+hso, y+height+vso-1})
	    end if
	end if
	v=y
	for r=1 to length(c) do
	    u=x
	    if italic then
		u+=io[r]
	    end if
	    cr=c[r]         -- row of char image
	    for j=1 to length(cr) by 2 do
		u+=cr[j]
		if atom(fc) then
		    set_pixel(repeat(fc,cr[j+1]+bold),{u,v})
		else
		    set_pixel(fc[r][u-x+1..u-x+cr[j+1]+bold],{u,v})
		end if
		u+=cr[j+1]
	    end for
	    v+=1
	end for
	if underline then
	    if atom(fc) then
		set_pixel(repeat(fc,w+bold+ecp),{x,y+height-1})
	    else
		set_pixel(fc[height][1..w+bold+ecp],{x,y+height-1})
	    end if
	end if
	x+=w+bold+ecp       -- index to next char
    end if
end procedure -- char

global procedure write(sequence s)
    sequence lens,string,strings
    integer ch,len,xo

    strings = substrings(s)
    lens = lengths(s)
    if ju>2 then                    -- BOXED
	y -= floor(length(lens)*(height+elp)/2)
    end if
    xo = x
    for i=1 to length(strings) do
	string = strings[i]
	len=lens[i]
	if and_bits(ju, RIGHT) then
	    x=xo-len
	elsif and_bits(ju, CENTRE) then
	    x=floor(xo-(len+1)/2)
	else x=xo                    -- LEFT
	end if
	for j=1 to length(string) do
	    ch=string[j]
	    if ch<=0 then set_attributes(-ch)
	    elsif ch>255 then fc=ch-256     -- change foreground color
	    elsif ch=10 then        -- newline
		y += height + elp
		x=xo
	    else                    -- writable char
		write_char(ch)
	    end if
	end for
    end for
end procedure   -- write

global procedure setx(integer i)
    x=i
end procedure

global procedure sety(integer i)
    y=i
end procedure

global procedure setxy(integer newx,integer newy)
    x=newx y=newy
end procedure

global function getx()
    return x
end function

global function gety()
    return y
end function

global function char_pitch(integer c)
    return width[c]+ecp+bold
end function

global function line_pitch()
    return height + elp
end function

global function foreground()
    return fc
end function

global procedure set_foreground(object c)
    fc = c
    expand_foreground_pattern()
end procedure -- set_foreground

global function shadow_color()
    return sc
end function

global procedure set_shadow_color(integer c)
    sc = c
end procedure

global procedure set_paper_color(integer c)
    pc = c
end procedure

global function paper_color()
    return pc
end function

global procedure set_shadow_offsets(integer xo, integer yo)
    hso=xo
    vso=yo
end procedure

global function shadow_offsets()
    return {hso, vso}
end function

global function justification()
    return ju
end function

global procedure justify(integer j)
    ju=j
end procedure

global procedure set_extra_line_pitch(integer p)
    elp = p
end procedure

global procedure set_extra_char_pitch(integer p)
    ecp=p
    expand_foreground_pattern()
end procedure

procedure xor_cursor(integer x, integer y, integer h)
    for i=0 to h-1 do
	set_pixel(xor_bits(get_display_pixel({x,y+i}),15),{x,y+i})
    end for
end procedure

function Length(sequence s)
    -- *primitive* string length in pixels
    integer len
    len=0
    for i=1 to length(s) do
	len += width[s[i]]
    end for
    return len
end function

procedure Write(sequence s)
    -- *primitive* write
    integer c
    for i=1 to length(s) do
	c=s[i]
	if c>0 and c<256 then
	    write_char(c)
	end if
    end for
end procedure

global procedure set_default(sequence s, object val)
    if equal(s, "attributes") then
	default_attributes = val
    elsif equal(s, "font") then
	default_font = val
    elsif equal(s, "foreground") then
	default_foreground = val
    elsif equal(s, "extra_char_pitch") then
	default_extra_char_pitch = val
    elsif equal(s, "extra_line_pitch") then
	default_extra_line_pitch = val
    elsif equal(s, "horizontal_shadow_offset") then
	default_horizontal_shadow_offset = val
    elsif equal(s, "justification") then
	default_justification = val
    elsif equal(s, "paper_color") then
	default_paper_color = val
    elsif equal(s, "shadow_color") then
	default_shadow_color = val
    elsif equal(s, "vertical_shadow_offset") then
	default_vertical_shadow_offset = val
    end if
end procedure -- set_default

global procedure restore_font()
    -- restore built-in defaults : initial conditions

    x = 0     y = 0
    default_attributes = NONE
    default_extra_char_pitch = 0
    default_extra_line_pitch = 1
    default_font = ROM
    default_foreground = BRIGHT_WHITE
    default_horizontal_shadow_offset = 1
    default_justification = LEFT
    default_paper_color = WHITE
    default_shadow_color = GRAY
    default_vertical_shadow_offset = 1
    reset_font()
end procedure


-- initialize : defaults ---------------------------------------------

load_rom_font()
restore_font()
