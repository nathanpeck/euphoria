include machine.e

-- <<mousfunc.e >> - more mouse functions
--  Colin Taylor - 71630.1776@compuserve.com
--  Version 1.0 - 7/19/97

global function mouse_reset()
-- resets mouse hardware and software and parameters
-- returns {m, b} where:
--      m = -1 if mouse present, 0 if mouse not detected
--      b = number of buttons (if mouse present), 0 if mouse not detected
-- resets:
--      pointer to center of screen and hidden
--      pointer movement range to current screen size
--      acceleration threshold to default value
    sequence reg_list
    reg_list = repeat(0,10)
    reg_list[REG_AX] = 0
    reg_list = dos_interrupt(#33,reg_list)
    return {reg_list[REG_AX], reg_list[REG_BX]}
end function  -- mouse_reset

global function mouse_sw_reset()
-- resets mouse software and parameters (works much faster than mouse_reset)
-- returns {m, b} where:
--      m = -1 if mouse driver present, 33 if no mouse driver found
--      b = number of buttons (if mouse driver present), 0 if no driver
-- resets:
--      pointer to center of screen and hidden
--      pointer movement range to current screen size
--      acceleration threshold to default value
    sequence reg_list
    reg_list = repeat(0,10)
    reg_list[REG_AX] = 33
    reg_list = dos_interrupt(#33,reg_list)
    return {reg_list[REG_AX], reg_list[REG_BX]}
end function  -- mouse_sw_reset

global function mouse_get_speed()
-- returns {x, y, a} where:
--      x = current horizontal speed setting (range 0 - 256)
--      y = current vertical speed setting (range 0 - 256)
--      a = current acceleration threshold setting (range 0 - 256)
    sequence reg_list
    reg_list = repeat(0,10)
    reg_list[REG_AX] = 27
    reg_list = dos_interrupt(#33,reg_list)
    return {reg_list[REG_BX], reg_list[REG_CX], reg_list[REG_DX]}
end function  -- mouse_get_speed

global procedure mouse_set_speed(sequence speed)
-- sets mouse speed parameters to speed {x, y, a} where:
--      x = new horizontal speed setting (range 0 - 256)
--      y = new vertical speed setting (range 0 - 256)
--      a = new acceleration threshold setting (range 0 - 256)
    sequence reg_list
    reg_list = repeat(0,10)
    reg_list[REG_AX] = 26
    reg_list[REG_BX] = speed[1]  -- horiz. speed
    reg_list[REG_CX] = speed[2]  -- vert. speed
    reg_list[REG_DX] = speed[3]  -- accel. threshhold
    reg_list = dos_interrupt(#33,reg_list)
end procedure  -- mouse_set_speed

