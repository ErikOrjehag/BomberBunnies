LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY PM_tb IS
END PM_tb;

ARCHITECTURE behavior OF PM_tb IS

  --Component Declaration for the Unit Under Test (UUT)
  COMPONENT PROGRAM_MEMORY
  PORT(
    pAddr : in  unsigned(11 downto 0);
    pData : out std_logic_vector(21 downto 0));
  END COMPONENT;

  signal data : std_logic_vector(21 downto 0);
    
  --Inputs
  signal clk : std_logic:= '0';
  signal rst : std_logic:= '0';

  --Clock period definitions
  constant clk_period : time:= 1 us;

BEGIN
  -- Instantiate the Unit Under Test (UUT)
  uut: PROGRAM_MEMORY PORT MAP (
    pAddr => "000000000000",
    pData => data
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

