--------------------------------------------------------------------------------
-- BomberBunnies
-- TEAM REG


-- library declaration
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;            -- basic IEEE library
use IEEE.NUMERIC_STD.ALL;               -- IEEE library for the unsigned type
                                        -- and various arithmetic operations

-- entity
entity BomberBunnies is
  port (
    clk	                : in std_logic;                         -- system clock
    rst                 : in std_logic;                         -- reset
    hSync	        : out std_logic;                        -- horizontal sync
    vSync	        : out std_logic;                        -- vertical sync
    vgaRed	        : out std_logic_vector(2 downto 0);     -- VGA red
    vgaGreen            : out std_logic_vector(2 downto 0);     -- VGA green
    vgaBlue	        : out std_logic_vector(2 downto 1);     -- VGA blue
    MISO1               : in  std_logic;			-- Master input slave output
    MOSI1               : out STD_LOGIC;			-- Master out slave in
    SCLK1               : buffer STD_LOGIC := '0';		-- Serial clock
    SS1                 : out STD_LOGIC;
    MISO2               : in  std_logic;			-- Master input slave output
    MOSI2               : out STD_LOGIC;			-- Master out slave in
    SCLK2               : buffer STD_LOGIC := '0';		-- Serial clock
    SS2                 : out STD_LOGIC);
end BomberBunnies;

-- architecture
architecture Behavioral of BomberBunnies is

  -- VGA motor component
  component CPU
    port (
      clk               : in std_logic;                      -- system clock (100 MHz)
      rst	        : in std_logic;
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
      p1x               : out std_logic_vector(3 downto 0);
      p1y               : out std_logic_vector(3 downto 0);
      p2x               : out std_logic_vector(3 downto 0);
      p2y               : out std_logic_vector(3 downto 0));
  end component;

-- VGA motor component
  component VGA_MOTOR
    port (
      clk		: in std_logic;                         -- system clock
      rst	        : in std_logic;
      playerPixel       : in std_logic_vector(7 downto 0);      -- pixel from player
      tilePixel         : in std_logic_vector(7 downto 0);      -- Tile pixel data
      xPixel            : buffer unsigned(9 downto 0);          -- Horizontal pixel counter
      yPixel	        : buffer unsigned(9 downto 0);		-- Vertical pixel counter
      vgaRed            : out std_logic_vector(2 downto 0);
      vgaGreen          : out std_logic_vector(2 downto 0);
      vgaBlue           : out std_logic_vector(2 downto 1);
      hSync             : out std_logic;
      vSync	        : out std_logic);
  end component;
	
  -- VGA motor component
  component MAP_MEMORY
    port (
      clk               : in std_logic;                         -- system clock (100 MHz)
      xPixel            : in unsigned(9 downto 0);              -- Horizontal pixel counter
      yPixel	        : in unsigned(9 downto 0);              -- Vertical pixel counter
      readMap           : in std_logic;
      writeMap          : in std_logic;
      tilePointer       : in std_logic_vector(7 downto 0);
      pixelIn           : in std_logic_vector(7 downto 0);
      tileTypeRead      : out std_logic_vector(7 downto 0);
      tileTypeWrite     : in std_logic_vector(7 downto 0);
      pixelOut          : out std_logic_vector(7 downto 0);
      tilePixelIndex    : out integer;
      tileIndex         : out integer);    
  end component;

  -- VGA motor component
  component TILE_MEMORY
    port (
      clk	        : in std_logic;                         -- system clock
      tilePixelIndex    : in integer;
      tileIndex         : in integer;
      pixel             : out std_logic_vector(7 downto 0));
  end component;

  -- VGA motor component
  component SPRITE_MEMORY
    port (
      clk		: in std_logic;                         -- system clock
      xPixel            : in unsigned(9 downto 0);              -- Horizontal pixel counter
      yPixel	        : in unsigned(9 downto 0);	        -- Vertical pixel counter
      p1x               : in unsigned(3 downto 0);              -- Number of pixels on board 16x16x15
      p1y               : in unsigned(3 downto 0);              -- Number of pixels on board 16x16x13
      p2x               : in unsigned(3 downto 0);              -- Number of pixels on board 16x16x15
      p2y               : in unsigned(3 downto 0);              -- Number of pixels on board 16x16x13
      playerPixel       : out std_logic_vector(7 downto 0));    -- pixel from player
           
  end component;

  component JOYSTICK
    port (
      clk       : in  std_logic;                                -- system clock
      rst       : in  std_logic;
      SCLK      : out std_logic;
      MISO      : in  STD_LOGIC;
      MOSI      : out  STD_LOGIC;
      joyX      : out std_logic_vector(1 downto 0);
      joyY      : out std_logic_vector(1 downto 0);
      btn       : out std_logic;			        -- Master input slave output
      SS        : out std_logic
    );
  end component;
	
  -- intermediate signals between PICT_MEM and VGA_MOTOR
  signal data_out2_s : std_logic_vector(7 downto 0);            -- data
  signal addr2_s : unsigned(10 downto 0);                       -- address

  signal xPixel : unsigned(9 downto 0);
  signal yPixel : unsigned(9 downto 0);

  signal playerPixel : std_logic_vector(7 downto 0);
  signal tilePixel : std_logic_vector(7 downto 0);
  
  signal tilePixelToVGA : std_logic_vector(7 downto 0);
  signal tilePixelIndexToTILE_MEMORY : integer;
  signal tileIndexToTILE_MEMORY : integer;

  signal tileTypeRead : std_logic_vector(7 downto 0);
  signal tileTypeWrite : std_logic_vector(7 downto 0);
  signal tilePointer : std_logic_vector(7 downto 0);

  signal readMap : std_logic;
  signal writeMap : std_logic;
  
  signal p1x : std_logic_vector(3 downto 0);
  signal p1y : std_logic_vector(3 downto 0);
  signal p2x : std_logic_vector(3 downto 0);
  signal p2y : std_logic_vector(3 downto 0);

  signal joy1x : std_logic_vector(1 downto 0);
  signal joy1y : std_logic_vector(1 downto 0);
  signal btn1  : std_logic;
  signal joy2x : std_logic_vector(1 downto 0);
  signal joy2y : std_logic_vector(1 downto 0);
  signal btn2  : std_logic;

  signal CPUClkDiv : unsigned(19 downto 0) := (others => '0');
  constant CPUClkEndVal : unsigned(19 downto 0) := "00000101000000000000";
  signal CPUClk : std_logic := '0';

  signal JOYClkDiv : unsigned(9 downto 0) := (others => '0');	        -- Stores count value
  constant JOYClkEndVal : unsigned(9 downto 0) := "1011101110";	        -- End count value
  signal JOYClk : std_logic := '0';

begin

  process(clk)
  begin
    if rising_edge(clk) then
      if rst='1' or CPUClkDiv = CPUClkEndVal then
	CPUClkDiv <= (others => '0');
        CPUClk <= not CPUClk;
      else
	CPUClkDiv <= CPUClkDiv + 1;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      if rst='1' or JOYClkDiv = JOYClkEndVal then
	JOYClkDiv <= (others => '0');
        JOYClk <= not JOYClk;
      else
	JOYClkDiv <= JOYClkDiv + 1;
      end if;
    end if;
  end process;

  -- picture memory component connection
  U1 : VGA_MOTOR port map(
    clk=>clk,
    rst=>rst,
    playerPixel=>playerPixel,
    tilePixel=>tilePixelToVGA,
    xPixel=>xPixel,
    yPixel=>yPixel,
    vgaRed=>vgaRed,
    vgaGreen=>vgaGreen,
    vgaBlue=>vgaBlue,
    hSync=>hSync,
    vSync=>vSync);

  U2 : MAP_MEMORY port map (
    clk => clk,
    xPixel => xPixel,
    yPixel => yPixel,
    readMap => readMap,
    writeMap => writeMap,
    tilePointer => tilePointer,
    pixelIn => tilePixel,
    tileTypeRead => tileTypeRead,
    tileTypeWrite => tileTypeWrite,
    pixelOut => tilePixelToVGA,
    tilePixelIndex => tilePixelIndexToTILE_MEMORY,
    tileIndex => tileIndexToTILE_MEMORY);
  
  U3 : TILE_MEMORY port map (
    clk => clk,
    tilePixelIndex => tilePixelIndexToTILE_MEMORY,
    tileIndex => tileIndexToTILE_MEMORY,
    pixel => tilePixel);

  U4 : SPRITE_MEMORY port map (
    clk         => clk,
    xPixel      => xPixel,
    yPixel      => yPixel,
    p1x         => unsigned(p1x),
    p1y         => unsigned(p1y),
    p2x         => unsigned(p2x),
    p2y         => unsigned(p2y),
    playerPixel => playerPixel);

  U5 : CPU port map (--
    clk => CPUClk,
    rst => rst,
    joy1x => joy1x,
    joy1y => joy1y,
    btn1 => btn1,
    joy2x => joy2x,
    joy2y => joy2y,
    btn2 => btn2,
    tilePointer => tilePointer,
    tileTypeRead => tileTypeRead,
    tileTypeWrite => tileTypeWrite,
    readMap => readMap,
    writeMap => writeMap,
    p1x => p1x,
    p1y => p1y,
    p2x => p2x,
    p2y => p2y
  );

  U6 : JOYSTICK port map (              -- Player 1
    clk => JOYClk,
    rst => rst,
    joyX => joy1x,
    joyY => joy1y,
    btn => btn1,
    MISO => MISO1,
    MOSI => MOSI1,
    SCLK => SCLK1,
    SS => SS1
  );

  U7 : JOYSTICK port map (              -- Player 2
    clk => JOYClk,
    rst => rst,
    joyX => joy2x,
    joyY => joy2y,
    btn => btn2,
    MISO => MISO2,
    MOSI => MOSI2,
    SCLK => SCLK2,
    SS => SS2
  );
  
end Behavioral;
