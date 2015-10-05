--Made by Daniel Kluss(xerox_irs), who incouraged RDS to add asm-c_funcs/c_procs
--all ports are fully recursive, meaning, you can inb a whole structure, 
--or use the cfunc/cproc's for speed
include asm.e   --by Pete Eberlein <xseal@harborside.com>, get from archive, search for "asm2"
include dll.e
constant
        get_code_segment_asm=get_asm("push cs pop eax ret"),
        get_data_segment_asm=get_asm("push ds pop eax ret"),
        inb_asm=get_asm(
                "push ebp \n"&
                "lea ebp, [ss:esp+8] \n"&
                "mov edx, [ebp] \n"&--port
                "in al, dx \n"&
                "movzx eax, al \n"&
                "pop ebp \n"&
                "ret"),
        inw_asm=get_asm(
                "push ebp \n"&
                "lea ebp, [ss:esp+8] \n"&
                "mov edx, [ebp] \n"&--port
                "in ax, dx \n"&
                "movzx eax, ax \n"&
                "pop ebp \n"&
                "ret"),
        ind_asm=get_asm(
                "push ebp \n"&
                "lea ebp, [ss:esp+8] \n"&
                "mov edx, [ebp] \n"&--port
                "in eax, dx \n"&
                "pop ebp \n"&
                "ret"),
        outb_asm=get_asm(
                "push ebp \n"&
                "lea ebp, [ss:esp+8] \n"&
                "mov edx, [ebp] \n"&--port
                "mov eax, [ebp+4] \n"&--data
                "out dx, al \n"&
                "pop ebp \n"&
                "ret"),
        outw_asm=get_asm(
                "push ebp \n"&
                "lea ebp, [ss:esp+8] \n"&
                "mov edx, [ebp] \n"&--port
                "mov eax, [ebp+4] \n"&--data
                "out dx, ax \n"&
                "pop ebp \n"&
                "ret"),
        outd_asm=get_asm(
                "push ebp \n"&
                "lea ebp, [ss:esp+8] \n"&
                "mov edx, [ebp] \n"&--port
                "mov eax, [ebp+4] \n"&--data
                "out dx, eax \n"&
                "pop ebp \n"&
                "ret")
global constant
        Cget_code_segment=define_c_func({},get_code_segment_asm,{},C_USHORT),
        Cget_data_segment=define_c_func({},get_data_segment_asm,{},C_USHORT),
        Cinb=define_c_func({},inb_asm,{C_USHORT},C_UCHAR),
        Cinw=define_c_func({},inw_asm,{C_USHORT},C_USHORT),
        Cind=define_c_func({},ind_asm,{C_USHORT},C_ULONG),
        Coutb=define_c_proc({},outb_asm,{C_USHORT,C_UCHAR}),
        Coutw=define_c_proc({},outw_asm,{C_USHORT,C_USHORT}),
        Coutd=define_c_proc({},outd_asm,{C_USHORT,C_ULONG})

--cs=c_func(Cget_code_segment,{})--use me to set up interrupt vetors, look at hardint.ex
--ds=c_func(Cget_data_segment,{})--use me to set up interrupt vetors, look at hardint.ex
--data=c_func(Cinb,{port})
--data=c_func(Cinw,{port})
--data=c_func(Cind,{port})
--c_proc(Coutb,{port,data})
--c_proc(Coutw,{port,data})
--c_proc(Coutd,{port,data})

global function inb(object port)
        sequence ret
        if atom(port) then
                return c_func(Cinb,{port})
        else
                ret=repeat(0,port[2])
                for i = 1 to port[2] do
                        ret=inb(port[1])
                end for
                return ret
        end if
end function

global function inw(object port)
        sequence ret
        if atom(port) then
                return c_func(Cinw,{port})
        else
                ret=repeat(0,port[2])
                for i = 1 to port[2] do
                        ret=inw(port[1])
                end for
                return ret
        end if
end function

global function ind(object port)
        sequence ret
        if atom(port) then
                return c_func(Cind,{port})
        else
                ret=repeat(0,port[2])
                for i = 1 to port[2] do
                        ret=ind(port[1])
                end for
                return ret
        end if
end function

global procedure outb(atom port, object data)
        if atom(data) then
                c_proc(Coutb,{port,data})
        else
                for i = 1 to length(data) do
                        outb(port,data[i])
                end for
        end if
end procedure

global procedure outw(atom port, object data)
        if atom(data) then
                c_proc(Coutw,{port,data})
        else
                for i = 1 to length(data) do
                        outw(port,data[i])
                end for
        end if
end procedure

global procedure outd(atom port, object data)
        if atom(data) then
                c_proc(Coutd,{port,data})
        else
                for i = 1 to length(data) do
                        outd(port,data[i])
                end for
        end if
end procedure


