LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY MAP_MEMORY_tb IS
END MAP_MEMORY_tb;

ARCHITECTURE behavior OF MAP_MEMORY_tb IS

  --Component Declaration for the Unit Under Test (UUT)
  COMPONENT MAP_MEMORY
  PORT(
<<<<<<< HEAD
    clk                 : in std_logic;                      -- system clock (100 MHz)
    rst	                : in std_logic;
    xPixel              : in unsigned(9 downto 0);              -- Horizontal pixel counter
    yPixel	        : in unsigned(9 downto 0);		-- Vertical pixel counter
    readMap             : in std_logic;
    writeMap            : in std_logic;
    pixelIn             : in std_logic_vector(7 downto 0);
    tilePointer         : in std_logic_vector(7 downto 0);
    tileTypeRead        : out std_logic_vector(7 downto 0);
    tileTypeWrite       : in std_logic_vector(7 downto 0);
    pixelOut            : out std_logic_vector(7 downto 0);
    tilePixelIndex      : out integer := 0;
    tileIndex           : out integer := 0);
    
=======
    clk               : in std_logic;                      -- system clock (100 MHz)
    rst	              : in std_logic);
>>>>>>> 2c45cb4e27b3d472249dd4caa4ed44d396f12e6b

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
<<<<<<< HEAD
    rst => rst,
    xPixel => "0000000000",
    yPixel => "0000000000",
    readMap => '1',
    writeMap => '0',
    pixelIn => "00000000",
    tilePointer => "00000010",
--    tileTypeRead => "00000000",
    tileTypeWrite => "00000000"
--    pixelOut => "00000000",
--    tilePixelIndex => 0,
--    tileIndex => 0
    
=======
    rst => rst

>>>>>>> 2c45cb4e27b3d472249dd4caa4ed44d396f12e6b
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

