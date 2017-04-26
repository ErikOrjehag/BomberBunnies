LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY JOYSTICK_tb IS
END JOYSTICK_tb;

ARCHITECTURE behavior OF JOYSTICK_tb IS

  --Component Declaration for the Unit Under Test (UUT)
  COMPONENT JOYSTICK
  PORT(
    clk         : in  std_logic;          -- system clock
    rst         : in  std_logic;

    -- Outputs
    joyX      : out std_logic_vector(1 downto 0);
    joyY      : out std_logic_vector(1 downto 0);
    btn       : out std_logic;

    -- Joystick pins
    MISO        : in  STD_LOGIC;			-- Master input slave output
    MOSI        : out  STD_LOGIC;		-- Master out slave in
    SCLK        : out  STD_LOGIC);			-- Serial clock
  END COMPONENT;
  
  --Inputs
  signal clk : std_logic:= '0';
  signal rst : std_logic:= '0';

  --Clock period definitions
  constant clk_period : time:= 1 us;

  signal btn : std_logic;
  signal joyX : std_logic_vector(1 downto 0);
  signal joyY : std_logic_vector(1 downto 0);
  signal MISO : std_logic := '1';
  signal MOSI : std_logic;
  signal SCLK : std_logic;
  
BEGIN
  -- Instantiate the Unit Under Test (UUT)
  uut: JOYSTICK PORT MAP (
    clk => clk,
    rst => rst,
    joyX => joyX,
    joyY => joyY,
    btn => btn,
    MISO => MISO,
    MOSI => MOSI,
    SCLK => SCLK
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

