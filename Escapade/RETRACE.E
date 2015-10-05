--To use this simply add:
--
-- call(retrace_vertical)
--
--to your main graphics and code loop

global constant retrace_vertical = allocate(20)
poke(retrace_vertical, {
    #50,          --    PUSH EAX
    #52,          --    PUSH EDX
    #BA,#DA,3,0,0,--    MOV EDX, 0x03DA
    #EC,          -- 1: IN AL, DX
    #A8,#08,      --    TEST AL, 0x08
    #75,#FB,      --    JNZ 1:
    #EC,          -- 2: IN AL, DX
    #A8,#08,      --    TEST AL, 0x08
    #74,#FB,      --    JZ 2:
    #5A,          --    POP EDX
    #58,          --    POP EAX
    #C3 } )       --    RET

