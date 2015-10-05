-- ratbag.e : mouse related routines
-- Jiri Babor
-- baborj@gns.cri.nz

include machine.e

global integer mbox

global object mouse_event

global function mouse_box(sequence b)
-- returns mouse box number within which mouse event happened, or zero
-- b is sequence of co-ordinate sequences: {{{x11,y11},{x12,y12}}, {{x21...
   mbox = 0
   if length(b) > 0 then
      for i = 1 to length(b) do
         if  mouse_event[2] >= b[i][1][1] and mouse_event[2] <= b[i][2][1]
         and mouse_event[3] >= b[i][1][2] and mouse_event[3] <= b[i][2][2] then
            mbox = i
            exit
         end if
      end for
   end if
   return mbox
end function   -- mouse_box

global procedure set_mouse_xy(integer x, integer y)
   -- places the mouse pointer where you want it
   sequence rl -- list of register values
   rl = repeat(0,10)
   rl[REG_AX] = 4
   rl[REG_CX] = x
   rl[REG_DX] = y
   rl = dos_interrupt(#33,rl)
end procedure  -- set_mouse_xy

global procedure confine_mouse(sequence s)
   -- confines mouse pointer to within input rectangle s={{x1,y1},{x2,y2}}
   sequence rl -- list of register values
   rl = repeat(0,10)
   rl[REG_AX] = 7
   rl[REG_CX] = s[1][1]
   rl[REG_DX] = s[2][1]
   rl = dos_interrupt(#33,rl)
   rl[REG_AX] = 8
   rl[REG_CX] = s[1][2]
   rl[REG_DX] = s[2][2]
   rl = dos_interrupt(#33,rl)
end procedure  -- confine_mouse

global function poll_mouse()
   -- returns mouse status: {button_status,x_coord,y_coord}
   -- button status: 0 .. no button pressed
   --                1 .. left button pressed
   --                2 .. right button pressed
   --                4 .. middle button pressed (if your rat has it)
   sequence  rl -- list of register values
   rl = repeat(0,10)
   rl[REG_AX] = 3
   rl = dos_interrupt(#33,rl)
   return {rl[REG_BX], rl[REG_CX], rl[REG_DX]}
end function   -- poll_mouse_status

global function get_text_mouse()
   -- same as get_mouse(), except it returns column & row of mouse text cursor
   object me
   me = machine_func(14,0)
   if sequence(me) then
      me[2..3]=me[2..3]/8+1
   end if
   return me
end function   -- get_text_mouse
