LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY GRAPHICS_tb IS
END GRAPHICS_tb;

ARCHITECTURE behavior OF GRAPHICS_tb IS

  --Component Declaration for the Unit Under Test (UUT)
  COMPONENT CPU
  PORT(
    clk               : in std_logic;                      -- system clock (100 MHz)
    rst	              : in std_logic;
    joy1x             : in std_logic_vector(1 downto 0);
    joy1y             : in std_logic_vector(1 downto 0);
    btn1              : in std_logic;
    joy2x             : in std_logic_vector(1 downto 0);
    joy2y             : in std_logic_vector(1 downto 0);
    btn2              : in std_logic;
    tilePointer       : buffer std_logic_vector(7 downto 0);
    tileTypeRead      : in std_logic_vector(7 downto 0);
    tileTypeWrite     : out std_logic_vector(7 downto 0);
    readMap           : out std_logic;
    writeMap          : out std_logic;
    p1x               : out std_logic_vector(9 downto 0);
    p1y               : out std_logic_vector(9 downto 0);
    p2x               : out std_logic_vector(9 downto 0);
    p2y               : out std_logic_vector(9 downto 0));
  END COMPONENT;

  component MAP_MEMORY
    port (
      clk : <type > );
  end component;
  
  --Inputs
  signal clk : std_logic:= '0';
  signal rst : std_logic:= '0';

  --Clock period definitions
  constant clk_period : time:= 1 us;

BEGIN
  -- Instantiate the Unit Under Test (UUT)
  uut: CPU PORT MAP (
    clk => clk,
    rst => rst,
    joy1x => "00",
    joy1y => "10",
    btn1 => '0',
    joy2x => "00",
    joy2y => "00",
    btn2 => '0',
    tileTypeRead => "00000000"
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

