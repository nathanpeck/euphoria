--Adapted from code by:
--
--Daniel Kluss(xerox_irs), who incouraged RDS to add asm-c_funcs/c_procs

include cports.e

tick_rate(1000)

procedure wait_64h_in()
    while 1 do
	if not and_bits(inb(#64),2) then exit end if
    end while
end procedure

procedure wait_64h_out()
    while 1 do
	if not and_bits(inb(#64),1) then exit end if
    end while
end procedure

procedure send_cmd_60h(atom cmd)
    wait_64h_in()--wait till all data read from keyboard
    outb(#64,#AD)--disable keyboard
    wait_64h_out()--wait till all keyboard disabled
    outb(#60,cmd)--send command
    wait_64h_in()--wait till command sent
    outb(#64,#AE)--enable keyboard
end procedure

global procedure keyboard_lights(sequence lights)
    send_cmd_60h(#ED)--lights command
    send_cmd_60h(bits_to_int(lights[3]&lights[1]&lights[2]))--send lights,scroll,num,caps
end procedure

