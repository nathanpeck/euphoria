-- MPU-401 I/O Routines
-- by Andrew Greenwood
-- Goldcroft@compuserve.com

-- Very simple, very useful.

without warning
include ports.e


global constant  ------------------------ Control Changes
	CCH_BANK_MSB = 0,
	CCH_MODULATION_MSB = 1,
	CCH_BREATH_MSB = 2,
	CCH_FOOT_MSB = 4,
	CCH_PORTAMENTOTIME_MSB = 5,
	CCH_DATAENTRY_MSB = 6,
	CCH_VOLUME_MSB = 7,
	CCH_BALANCE_MSB = 8,
	CCH_PAN_MSB = 10,
	CCH_EXPRESSION_MSB = 11,
	CCH_EFFECT1_MSB = 12,
	CCH_EFFECT2_MSB = 13,
	CCH_GENERAL1_MSB = 16,
	CCH_GENERAL2_MSB = 17,
	CCH_GENERAL3_MSB = 18,
	CCH_GENERAL4_MSB = 19,
	CCH_BANK_LSB = 32,
	CCH_MODULATION_LSB = 33,
	CCH_BREATH_LSB = 34,
	CCH_FOOT_LSB = 36,
	CCH_PORTAMENTOTIME_LSB = 37,
	CCH_DATAENTRY_LSB = 38,
	CCH_VOLUME_LSB = 39,
	CCH_BALANCE_LSB = 40,
	CCH_PAN_LSB = 42,
	CCH_EXPRESSION_LSB = 43,
	CCH_EFFECT1_LSB = 44,
	CCH_EFFECT2_LSB = 45,
	CCH_GENERAL1_LSB = 48,
	CCH_GENERAL2_LSB = 49,
	CCH_GENERAL3_LSB = 50,
	CCH_GENERAL4_LSB = 51,
	CCH_SUSTAIN = 64,
	CCH_PORTAMENTO = 65,
	CCH_SOSTENUTO = 66,
	CCH_SOFT = 67,
	CCH_LEGATO = 68,
	CCH_HOLD2 = 69,
	CCH_VARIATION = 70,
	CCH_HARMONIC = 71,
	CCH_RELEASE = 72,
	CCH_ATTACK = 73,
	CCH_BRIGHTNESS = 74,
	CCH_SOUND6 = 75,
	CCH_SOUND7 = 76,
	CCH_SOUND8 = 77,
	CCH_SOUND9 = 78,
	CCH_SOUND10 = 79,
	CCH_GENERAL5 = 80,
	CCH_GENERAL6 = 81,
	CCH_GENERAL7 = 82,
	CCH_GENERAL8 = 83,
	CCH_PORTAMENTO_SOURCE = 84,
	CCH_REVERB = 91,
	CCH_FX2 = 92,
	CCH_CHORUS = 93,
	CCH_DSP = 94,
	CCH_FX5 = 95,
	CCH_DATA_INC = 96,
	CCH_DATA_DEC = 97,
	CCH_NRPN_LSB = 98,
	CCH_NRPN_MSB = 99,
	CCH_RPN_LSB = 100,
	CCH_RPN_MSB = 101


object MPU401_PORTS  -- Not a constant because detect routine can add to it.

MPU401_PORTS = {#300,#320,#330,#332,#334}


object mpu401port,junk

mpu401port=-1  -- Default is error


global procedure reset_mpu401()
object junk
 if mpu401port != -1 then
   Output(#0FF,mpu401port+1)
  for junkloop=1 to 100000 do
  end for
   junk=Input(mpu401port)
   Output(#3F,mpu401port+1)
  for junkloop=1 to 100000 do
  end for
   junk=Input(mpu401port)
 end if
end procedure



global function detect_mpu401(object reset, object checkport)
 integer time_out
 if checkport != -1 then
  MPU401_PORTS=MPU401_PORTS & checkport  -- Add "checkport" to list
 end if
 for loop=1 to length(MPU401_PORTS) do
  if reset != 0 then
   mpu401port=MPU401_PORTS[loop]
   reset_mpu401()
   mpu401port=-1
  end if
  time_out=1000
  while time_out>0 and Input(MPU401_PORTS[loop]) != #FE do
   time_out=time_out-1
  end while
  if time_out>0 then
   mpu401port=MPU401_PORTS[loop]
   return(mpu401port)
  end if
 end for
 return(-1)
 -- Return port number if ok, -1 if not
end function



global procedure write_mpu401_data(object data)
 if mpu401port != -1 then
  if sequence(data) then
   for loop=1 to length(data) do
    while floor(Input(mpu401port+1)/#40) = 1 do
    end while
    Output(data[loop],mpu401port)
   end for
  else
   while floor(Input(mpu401port+1)/#40) = 1 do
   end while
   Output(data,mpu401port)
  end if
 end if
end procedure



global function read_mpu401_data()
 object incoming_data
 if mpu401port != -1 then
  incoming_data=0
  while floor(Input(mpu401port+1)/#80) = 1 do
   incoming_data=Input(mpu401port)
  end while
  if incoming_data=0 then
   incoming_data=Input(mpu401port)
  end if
  return incoming_data
 else
  return -1
 end if
end function



global procedure control_change(integer chan, integer control, integer param)
 -- If there is no parameter, set param to -1
 if chan>0 and chan<17 and control>-1 and control<128 and param<128 then
  write_mpu401_data(#B0-1+chan)
  write_mpu401_data(control)
  if param != -1 then
   write_mpu401_data(param)
  end if
 end if
end procedure



global procedure program_change(integer chan, integer param)
 if chan>0 and chan<17 and param>-1 and param<128 then
  write_mpu401_data(#C0-1+chan)
  write_mpu401_data(param)
 end if
end procedure
