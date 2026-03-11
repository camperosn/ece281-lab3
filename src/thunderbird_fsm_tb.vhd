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
--| FILENAME      : thunderbird_fsm_tb.vhd (TEST BENCH)
--| AUTHOR(S)     : Capt Phillip Warner
--| CREATED       : 03/2017
--| DESCRIPTION   : This file tests the thunderbird_fsm modules.
--|
--|
--+----------------------------------------------------------------------------
--|
--| REQUIRED FILES :
--|
--|    Libraries : ieee
--|    Packages  : std_logic_1164, numeric_std
--|    Files     : thunderbird_fsm_enumerated.vhd, thunderbird_fsm_binary.vhd, 
--|				   or thunderbird_fsm_onehot.vhd
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
  
entity thunderbird_fsm_tb is
end thunderbird_fsm_tb;

architecture test_bench of thunderbird_fsm_tb is 
	
	component thunderbird_fsm is 
    port(
        i_clk, i_reset  : in    std_logic;
        i_left, i_right : in    std_logic;
        o_lights_L      : out   std_logic_vector(2 downto 0);
        o_lights_R      : out   std_logic_vector(2 downto 0)
    );
	end component thunderbird_fsm;

	-- test I/O signals
	
	-- Inputs
	signal w_i_left : std_logic := '0';
	signal w_i_right : std_logic := '0';
	signal w_reset : std_logic := '0';
	signal w_clk : std_logic := '0';
    signal w_f_Q : STD_LOGIC_VECTOR(7 downto 0) := "10000000";
    signal w_f_Q_next: STD_LOGIC_VECTOR(7 downto 0) := "10000000";
    	
	-- Outputs
	signal w_o_lights_L : std_logic_vector(2 downto 0) := "000";
	signal w_o_lights_R : std_logic_vector(2 downto 0) := "000";

	-- constants
	constant k_clk_period : time := 10 ns;
	
	
begin
	-- PORT MAPS ----------------------------------------
	uut: thunderbird_fsm port map (
	   i_left => w_i_left,
	   i_right => w_i_right,
	   i_reset => w_reset,
	   i_clk => w_clk,
	   o_lights_L => w_o_lights_L,
	   o_lights_R => w_o_lights_R
	);
	-----------------------------------------------------
	
	-- PROCESSES ----------------------------------------	
    -- Clock process ------------------------------------
    clk_proc : process
    begin
        w_clk <= '0';
        wait for k_clk_period/2;
        w_clk <= '1';
        wait for k_clk_period/2;
    end process;
	-----------------------------------------------------
	
	-- Test Plan Process --------------------------------
	sim_proc : process
	begin
	
	   w_reset <= '1';
	   wait for k_clk_period*1;
	       assert w_o_lights_L = "000" report "bad reset" severity failure;
	       assert w_o_lights_R = "000" report "bad reset" severity failure;
	   
	   w_reset <= '0';
	   wait for k_clk_period*1;
	   
	   -- Test 1: Activate left - disable midway
	   
	   -- Enable - should begin cycle
	   w_i_left <= '1'; wait for k_clk_period;
	       assert w_o_lights_L = "001" report "bad left cycle 1" severity failure;
	   wait for k_clk_period;
	       assert w_o_lights_L = "011" report "bad left cycle 2" severity failure;
	   wait for k_clk_period;
	       assert w_o_lights_L = "111" report "bad left cycle 3" severity failure;
	   wait for k_clk_period;
	       assert w_o_lights_L = "000" report "bad left cycle 4" severity failure;
	   wait for k_clk_period;
	       assert w_o_lights_L = "001" report "bad left cycle 5" severity failure;
	   -- Disable - should complete cycle then stop
	   w_i_left <= '0'; wait for k_clk_period;
	  	   assert w_o_lights_L = "011" report "bad left cycle 6" severity failure;
	   wait for k_clk_period;
	       assert w_o_lights_L = "111" report "bad left cycle 7" severity failure;
	   wait for k_clk_period*2; -- wait 2 cycles
	       assert w_o_lights_L = "000" report "bad left cycle 8" severity failure;
	   
	           	  	   
	   -- Test 2: Activate right, disable midway
        -- Enable - should begin cycle
	   w_i_right <= '1'; wait for k_clk_period;
	       assert w_o_lights_R = "001" report "bad right cycle 1" severity failure;
	   wait for k_clk_period;
	       assert w_o_lights_R = "011" report "bad right cycle 2" severity failure;
	   wait for k_clk_period;
	       assert w_o_lights_R = "111" report "bad right cycle 3" severity failure;
	   wait for k_clk_period;
	       assert w_o_lights_R = "000" report "bad right cycle 4" severity failure;
	   wait for k_clk_period;
	       assert w_o_lights_R = "001" report "bad right cycle 5" severity failure;
	   -- Disable - should complete cycle then stop
	   w_i_right <= '0'; wait for k_clk_period;
	  	   assert w_o_lights_R = "011" report "bad right cycle 6" severity failure;
	   wait for k_clk_period;
	       assert w_o_lights_R = "111" report "bad right cycle 7" severity failure;
	   wait for k_clk_period*2; -- wait 2 cycles
	       assert w_o_lights_R = "000" report "bad right cycle 8" severity failure;	   
	   
	   -- Test 5: Activate left and right at the same time
	   -- Enable - should begin cycle
	   w_i_right <= '1';
	   w_i_left <= '1';
	   wait for k_clk_period;
	       assert w_o_lights_R = "111" report "bad hazard cycle 1R" severity failure;
	       assert w_o_lights_L = "111" report "bad hazard cycle 1L" severity failure;
	   wait for k_clk_period;
	       assert w_o_lights_R = "000" report "bad hazard cycle 2R" severity failure;
	       assert w_o_lights_L = "000" report "bad hazard cycle 2L" severity failure;
	   wait for k_clk_period;
	       assert w_o_lights_R = "111" report "bad hazard cycle 3R" severity failure;
	       assert w_o_lights_L = "111" report "bad hazard cycle 3L" severity failure;
	   wait for k_clk_period;
	       assert w_o_lights_R = "000" report "bad hazard cycle 4R" severity failure;
	       assert w_o_lights_L = "000" report "bad hazard cycle 4L" severity failure;
	   wait for k_clk_period;
	       assert w_o_lights_R = "111" report "bad hazard cycle 5R" severity failure;
	       assert w_o_lights_L = "111" report "bad hazard cycle 5L" severity failure;
	   -- Disable - should complete cycle then stop
	   w_i_right <= '0';
	   w_i_left <= '0';	   
	   wait for k_clk_period*3; -- Wait 3 cycles
	       assert w_o_lights_R = "000" report "bad hazard cycle 6R" severity failure;
	       assert w_o_lights_L = "000" report "bad hazard cycle 6L" severity failure;
	       	   	
	-- Tests complete
	   	wait;
	end process;
	-----------------------------------------------------	
	
end test_bench;
