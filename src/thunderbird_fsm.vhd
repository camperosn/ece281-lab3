--+----------------------------------------------------------------------------
--| 
--| COPYRIGHT 2017 United States Air Force Academy All rights reserved.
--| 
--| United States Air Force Academy     __  _______ ___    _________ 
--| Dept of Electrical &               / / / / ___//   |  / ____/   |
--| Computer Engineering              / / / /\__ \/ /| | / /_  / /| |
--| 2354 Fairchild Drive Ste 2F6     / /_/ /___/ / ___ |/ __/ / ___ |
--| USAF Academy, CO 80840           \____//____/_/  |_/_/   /_/  |_|
--| 
--| ---------------------------------------------------------------------------
--|
--| FILENAME      : thunderbird_fsm.vhd
--| AUTHOR(S)     : Nicholas Camperos
--| CREATED       : 03/2017 Last modified 3/9/2026
--| DESCRIPTION   : This file implements the ECE 281 Lab 2 Thunderbird tail lights
--|					FSM using enumerated types.  This was used to create the
--|					erroneous sim for GR1
--|
--|					Inputs:  i_clk 	 --> 100 MHz clock from FPGA
--|                          i_left  --> left turn signal
--|                          i_right --> right turn signal
--|                          i_reset --> FSM reset
--|
--|					Outputs:  o_lights_L (2:0) --> 3-bit left turn signal lights
--|					          o_lights_R (2:0) --> 3-bit right turn signal lights
--|
--|					Upon reset, the FSM by defaults has all lights off.
--|					Left ON - pattern of increasing lights to left
--|						(OFF, LA, LA/LB, LA/LB/LC, repeat)
--|					Right ON - pattern of increasing lights to right
--|						(OFF, RA, RA/RB, RA/RB/RC, repeat)
--|					L and R ON - hazard lights (OFF, ALL ON, repeat)
--|					A is LSB of lights output and C is MSB.
--|					Once a pattern starts, it finishes back at OFF before it 
--|					can be changed by the inputs
--|					
--|
--|                 xxx State Encoding key
--|                 --------------------
--|                 One-Hot  State | Encoding
--|                 --------------------
--|                     State,S7,S6,S5,S4,S3,S2,S1,S0
--                      OFF| 1,0,0,0,0,0,0,0
--                      ON | 0,1,0,0,0,0,0,0
--                      R1 | 0,0,1,0,0,0,0,0
--                      R2 | 0,0,0,1,0,0,0,0
--                      R3 | 0,0,0,0,1,0,0,0
--                      L1 | 0,0,0,0,0,1,0,0
--                      L2 | 0,0,0,0,0,0,1,0
--                      L3 | 0,0,0,0,0,0,0,1
--|                 --------------------
--|
--|
--+----------------------------------------------------------------------------
--|
--| REQUIRED FILES :
--|
--|    Libraries : ieee
--|    Packages  : std_logic_1164, numeric_std
--|    Files     : None
--|
--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>           = off-chip bidirectional port ( _pads file )
--|    xi_<port name>           = off-chip input port         ( _pads file )
--|    xo_<port name>           = off-chip output port        ( _pads file )
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--+----------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
 
entity thunderbird_fsm is 
  port(
    i_clk, i_reset  : in    std_logic;
    i_left, i_right : in    std_logic;
    o_lights_L      : out   std_logic_vector(2 downto 0);
    o_lights_R      : out   std_logic_vector(2 downto 0)
  );
end thunderbird_fsm;

architecture thunderbird_fsm_arch of thunderbird_fsm is 

-- register signals - default is OFF ------------------------------------------------------------------
    signal f_Q : STD_LOGIC_VECTOR(7 downto 0) := "10000000";
    signal f_Q_next: STD_LOGIC_VECTOR(7 downto 0) := "10000000";
begin

	-- CONCURRENT STATEMENTS --------------------------------------------------------	
	-- Next state logic
	f_Q_next(0) <= f_Q(1);
	f_Q_next(1) <= f_Q(2);
	f_Q_next(2) <= f_Q(7) AND (i_left AND (NOT i_right));
	f_Q_next(3) <= f_Q(4);
	f_Q_next(4) <= f_Q(5);
	f_Q_next(5) <= f_Q(7) AND ((NOT i_left) AND i_right);
	f_Q_next(6) <= f_Q(7) AND i_left AND i_right;
	f_Q_next(7) <= (f_Q(7) AND (NOT i_left) AND (NOT i_right)) OR f_Q(6) OR f_Q(3) OR f_Q(0);
   
    -- Output logic
    -- Note that we expect the inside right taillight,
    -- RA, to be the LSB 
    -- of o_lights_R, and RC should be the MSB.
    
    -- Left to right
    o_lights_l(2) <= f_Q(6) OR f_Q(0);
    o_lights_l(1) <= f_Q(6) OR f_Q(1) OR f_Q(0);
    o_lights_l(0) <= f_Q(6) OR f_Q(2) OR f_Q(1) OR f_Q(0);
    -- right to left
    o_lights_r(0) <= f_Q(6) OR f_Q(3);  
    o_lights_r(1) <= f_Q(6) OR f_Q(5) OR f_Q(4) OR f_Q(3); 
    o_lights_r(2) <= f_Q(6) OR f_Q(4) OR f_Q(3)
   
    ---------------------------------------------------------------------------------
	

	-- PROCESSES --------------------------------------------------------------------
    register_proc : process ( i_clk, i_reset)
    begin
        -- Reset state is OFF
        if i_reset = '1' then
            f_Q <= "10000000";
        -- Next state becomes current state
        elsif (rising_edge(i_clk)) then
            f_Q <= f_Q_next;
        end if;
     end process register_proc;
    
	-----------------------------------------------------					   
				  
end thunderbird_fsm_arch;