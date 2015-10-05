--  ports.e 
--  by Jacques Deschenes, Baie-Comeau, PQ, Canada, e-mail: desja@quebectel.com
--  creation date: september 7th, 1996
--
--  revisions:
--    June 15th, 1997
--       added WriteReg() and ReadReg()
--   June 21th, 1997
--       added inpw() and outpw()  which have the same syntax and behavior as
--                                 in C.
--   January 3th, 1997
--     minor update to improve speed.
--     Considering the small amount of memory needed by assembler code, I
--     remove FreePorts() function and made InitPorts() local as there is
--     no needs to free the memory and reinitialize the code during the course
--     of a program execution.
--
--  the functions defined in this file are for reading and writing to I/O ports.
--  *****     Exported functions and procedures ***
--      Input  to read a byte from an I/O port
--      Output to write a byte to an I/O port
--      InputW to read a word from an I/O port * see note
--      OutputW to write a word to an I/O port * see note
--      WriteReg to write to a dual port first one selecting a register index
--      ReadReg  to read from a dual port    first one selecting a register ind
--      inpw() to read a word from port  identical to C
--      outpw() to write a word to port  identical to C
 
--   * NOTE:  InputW and OutputW doesn't behave like inport and outport in C
--            the low byte and the Hi byte are read and outputed to the same
--            port id. For C equivalent use inpw() and outpw()

include machine.e
-- without type_check

global type byte(integer b)
   return b >= 0 and b < 256
end type --byte()

global type word(integer w)
   return w >= 0 and w <= #FFFF
end type -- word()

sequence OutputCode, InputCode, OutputWCode, InputWCode,WriteRegCode,
	 ReadRegCode, outpwCode, inpwCode

OutputCode = {
		#50,        -- PUSH EAX
		#52,        -- PUSH EDX
		#BA,0,0,0,0,-- MOV EDX, PORT  (port, to be poked in) (3) 
		#B0,#00,    -- MOV AL, byte  (byte, to be poked in) (8) 
		#EE,        -- OUT DX, AL           
		#5A,        -- POP EDX
		#58,        -- POP EAX
		#C3         -- RET
	    }
	    
InputCode = {
		#50,        -- PUSH EAX
		#52,        -- PUSH EDX
		#BA,0,0,0,0,-- MOV EDX, PORT  (port to be poked in) (3)
		#EC,        -- IN AL, DX            
		#BA,0,0,0,0,--  MOV EDX, storage address (9)
		#88,#02,    -- MOV [EDX],AL
		#5A,        -- POP EDX
		#58,        -- POP EAX
		#C3,        -- RET
		#0          -- DB ? result holder
	    }
	    
OutputWCode = {
		#50,        -- PUSH EAX
		#52,        -- PUSH EDX
		#BA,0,0,0,0,-- MOV EDX, PORT  (port, to be poked in) (3) 
		#B8,0,0,0,0,-- MOV EAX, word  ;word to be poked in) (8) 
		#EE,        -- OUT DX, AL   ;output low byte        
		#86,#C4,    -- XCHG AH,AL    ; send high byte in al
		#EE,        -- OUT DX, AL    ;output high byte        
		#5A,        -- POP EDX
		#58,        -- POP EAX
		#C3         -- RET
		}
		
InputWCode = {
		#50,        -- PUSH EAX
		#53,        -- PUSH EBX
		#52,        -- PUSH EDX
		#BA,0,0,0,0,-- MOV EDX, PORT  (port to be poked in) (4)
		#BB,0,0,0,0,-- MOV EBX, storage address (9)
		#EC,        -- IN AL, EDX            
		#88,#03,    -- MOV [EBX],AL
		#43,        -- INC EBX
		#EC,        -- IN AL, EDX
		#88,#03,    -- MOV [EBX],AL
		#5A,        -- POP EDX
		#5B,        -- POP EBX
		#58,        -- POP EAX
		#C3,        -- RET
		#0,#0       -- DW ? result holder
		}
		
WriteRegCode = {
		#50,        -- PUSH EAX
		#52,        -- PUSH EDX
		#BA,0,0,0,0,-- MOV  EDX, PORT (+3)
		#B0,0,      -- MOV  AL, INDEX (+8)
		#EE,        -- OUT  DX, AL
		#42,        -- INC  EDX
		#B0,0,      -- MOV  AL, DATA  (+12)
		#EE,        -- OUT DX, AL
		#5A,        -- POP  EDX
		#58,        -- POP  EAX
		#C3         -- RET
	       }
		
ReadRegCode = {
		#50,        -- PUSH EAX
		#53,        -- PUSH EBX
		#52,        -- PUSH EDX
		#BB,0,0,0,0,-- MOV EBX, storage (+4)
		#BA,0,0,0,0,-- MOV  EDX, PORT  (+9)
		#B0,0,      -- MOV  AL, INDEX  (+14)
		#EE,        -- OUT  DX, AL
		#42,        -- INC  EDX
		#88,03,     -- MOV [EBX], al
		#5A,        -- POP  EDX
		#5B,        -- POP  EBX 
		#58,        -- POP  EAX
		#C3,        -- RET
		#00         -- data storage 
	      }

outpwCode = {
		#50,        -- PUSH EAX
		#52,        -- PUSH EDX
		#BA,0,0,0,0,-- MOV EDX, PORT  (port, to be poked in) (3) 
		#B8,0,0,0,0,-- MOV EAX, dword  (to be poked in) (8) 
		#66,#EF,    -- OUT DX, AX
		#5A,        -- POP EDX
		#58,        -- POP EAX
		#C3         -- RET
	    }

inpwCode = {
		#50,        -- PUSH EAX
		#53,        -- PUSH EBX
		#52,        -- PUSH EDX
		#BA,0,0,0,0,-- MOV EDX, PORT  (port to be poked in) (4)
		#BB,0,0,0,0,-- MOV EBX, storage address (9)
		#66,#ED,    -- IN AX, DX            
		#66,#89,#03,-- MOV [EBX],AX
		#5A,        -- POP EDX
		#5B,        -- POP EBX
		#58,        -- POP EAX
		#C3,        -- RET
		#0,#0       -- DW ? data to be returned
	   }

atom InputAsm, InputPort, InputByte,
     OutputAsm, OutputPort, OutputByte,
     OutputWAsm, OutputWPort, OutputWord,
     InputWAsm,  InputWPort, InputWord,
     WriteRegAsm, WriteRegPort, WriteRegIndex, WriteRegData,
     ReadRegAsm, ReadRegPort, ReadRegIndex, ReadRegData,
     inpwAsm, inpwPort, inpword,
     outpwAsm, outpwPort, outpword


function allocate_v(integer count) -- allocate and validate
atom pointer
    pointer = allocate(count)
    if not pointer then
	puts(1,"Fatal error! memory allocation failed in ports.e\n")
	abort(1)
    end if
    return pointer
end function

procedure InitPorts()
-- init code space for assembler routines
integer CodeLength
    
    CodeLength = length(InputCode)
    InputAsm = allocate_v(CodeLength)
    poke(InputAsm,InputCode)
    poke4(InputAsm+9,InputAsm+CodeLength-1) -- storage pointer
    InputPort = InputAsm + 3
    InputByte = InputAsm+CodeLength-1
    
    OutputAsm = allocate_v(length(OutputCode))
    poke(OutputAsm,OutputCode)
    OutputPort = OutputAsm + 3
    OutputByte = OutputAsm + 8
    
    OutputWAsm = allocate_v(length(OutputWCode))
    poke(OutputWAsm,OutputWCode)
    OutputWPort =OutputWAsm + 3
    OutputWord = OutputWAsm + 8
    
    CodeLength = length(InputWCode)
    InputWAsm = allocate_v(CodeLength)
    poke(InputWAsm,InputWCode)
    poke4(InputWAsm+9,InputWAsm+CodeLength-2) -- storage pointer
    InputWPort = InputWAsm + 4
    InputWord = InputWAsm + CodeLength - 2
    
    WriteRegAsm = allocate_v(length(WriteRegCode))
    poke(WriteRegAsm,WriteRegCode)
    WriteRegPort = WriteRegAsm+3
    WriteRegIndex = WriteRegAsm+8
    WriteRegData = WriteRegAsm+12
    
    CodeLength = length(ReadRegCode)
    ReadRegAsm = allocate_v(CodeLength)
    poke(ReadRegAsm,ReadRegCode)
    poke4(ReadRegAsm+4,ReadRegAsm+CodeLength-1)
    ReadRegPort = ReadRegAsm+9
    ReadRegIndex = ReadRegAsm+14
    ReadRegData = ReadRegAsm+CodeLength-1
    
    CodeLength = length(inpwCode)
    inpwAsm = allocate_v(CodeLength)
    poke(inpwAsm,inpwCode)
    poke(inpwAsm+9,inpwAsm+CodeLength-2)
    inpwPort = inpwAsm + 4
    inpword = inpwAsm+CodeLength-2
    
    outpwAsm = allocate_v(length(outpwCode))
    poke(outpwAsm,outpwCode)
    outpwPort = outpwAsm + 3
    outpword = outpwAsm + 8
end procedure -- InitPorts()

global function Input(word port) -- byte input
 byte b
    poke4(InputPort,port)
    call(InputAsm)
    b = peek(InputByte)
    return b
end function -- Input()

global  procedure Output(byte b, word port)
    poke4(OutputPort,port)
    poke(OutputByte,b)
    call(OutputAsm)
end procedure -- Output()

global function InputW(word port)
-- read a word form port.  Low byte is read then High byte
-- return HighByte*256+LowByte
    poke4(InputWPort,port)
    call(InputWAsm)
    return peek(InputWord + 1)*256 + peek(InputWord)
end function -- InputW()

global procedure OutputW(word w, word port)
    poke4(OutputWPort,port)
    poke4(OutputWord,w)
    call(OutputWAsm)
end procedure -- OutputW()

global procedure WriteReg(word port, byte index, byte data)
  poke4(WriteRegPort,port)
  poke(WriteRegIndex,index)
  poke(WriteRegData,data)
  call(WriteRegAsm)
end procedure

global function ReadReg(word port, byte index)
  poke4(ReadRegPort,port)
  poke(ReadRegIndex,index)
  call(ReadRegAsm)
  return peek(ReadRegData)
end function

global function inpw(word port)
sequence bytes
  poke4(inpwPort,port)
  call(inpwAsm)
  bytes = peek({inpword,2})
  return bytes[2]*256+bytes[1]
end function

global procedure outpw(word port, word w)
  poke4(outpwPort,port)
  poke4(outpword,w)
  call(outpwAsm)
end procedure 

InitPorts()
