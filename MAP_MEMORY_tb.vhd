LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY MAP_MEMORY_tb IS
END MAP_MEMORY_tb;

ARCHITECTURE behavior OF MAP_MEMORY_tb IS

  --Component Declaration for the Unit Under Test (UUT)
  COMPONENT MAP_MEMORY
  PORT(
    clk               : in std_logic;                      -- system clock (100 MHz)
    rst	              : in std_logic;

  END COMPONENT;
  
  --Inputs
  signal clk : std_logic:= '0';
  signal rst : std_logic:= '0';

  --Clock period definitions
  constant clk_period : time:= 1 us;

BEGIN
  -- Instantiate the Unit Under Test (UUT)
  uut: MAP_MEMORY PORT MAP (
    clk => clk,
    rst => rst,

  );
		
  -- Clock process definitions
  clk_process :process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;

  --rst <= '1', '0' after 1.7 us;
END;
