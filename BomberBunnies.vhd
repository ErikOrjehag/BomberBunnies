--------------------------------------------------------------------------------
-- VGA lab
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
    vgaRed	        : out std_logic_vector(2 downto 0);   -- VGA red
    vgaGreen            : out std_logic_vector(2 downto 0);     -- VGA green
    vgaBlue	        : out std_logic_vector(2 downto 1));     -- VGA blue
end BomberBunnies;


-- architecture
architecture Behavioral of BomberBunnies is

-- VGA motor component
  component VGA_MOTOR
    port (
      clk		: in std_logic;                         -- system clock
      rst	        : in std_logic;
      playerPixel       : in std_logic_vector(7 downto 0);   -- pixel from player
      mapPixel          : in std_logic_vector(7 downto 0);   -- Tile pixel data
      xPixel            : buffer unsigned(9 downto 0);         -- Horizontal pixel counter
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
      rst	        : in std_logic;
      xPixel            : in unsigned(9 downto 0);      -- Horizontal pixel counter
      yPixel	        : in unsigned(9 downto 0);      -- Vertical pixel counter
      readWrite         : in std_logic;                         -- 0 is read, 1 is write
      tilePointer       : in integer;
      pixelIn           : in std_logic_vector(7 downto 0);
      writeTile         : in std_logic_vector(7 downto 0);
      readTile          : out std_logic_vector(7 downto 0);
      pixelOut          : out std_logic_vector(7 downto 0);
      tilePixelIndex    : out integer;
      tileIndex         : out std_logic_vector(7 downto 0));    
  end component;

  -- VGA motor component
  component TILE_MEMORY
    port (
      clk	        : in std_logic;                         -- system clock
      tilePixelIndex    : in integer;
      tileIndex         : in integer;
      rst               : in std_logic;
      pixel             : out std_logic_vector(7 downto 0));
  end component;

  -- VGA motor component
  component SPRITE_MEMORY
    port (
      clk		: in std_logic;                 -- system clock
      rst	        : in std_logic;
      xPixel            : in unsigned(9 downto 0);               -- Horizontal pixel counter
      yPixel	        : in unsigned(9 downto 0);	        -- Vertical pixel counter
      p1x               : in unsigned(7 downto 0);               -- Number of pixels on board 16x16x15
      p1y               : in unsigned(7 downto 0);               -- Number of pixels on board 16x16x13
      p2x               : in unsigned(7 downto 0);               -- Number of pixels on board 16x16x15
      p2y               : in unsigned(7 downto 0);               -- Number of pixels on board 16x16x13
      playerPixel       : out std_logic_vector(7 downto 0));     -- pixel from player
           
  end component;

  -- VGA motor component
  component CPU
    port (
      clk		: in std_logic;                         -- system clock
      joy1x             : in std_logic_vector(1 downto 0);
      joy1y             : in std_logic_vector(1 downto 0);
      btn1              : in std_logic;
      joy2x             : in std_logic_vector(1 downto 0);
      joy2y             : in std_logic_vector(1 downto 0);
      btn2              : in std_logic;
      tilePointer       : buffer std_logic_vector(7 downto 0);
      tileIndex         : buffer std_logic_vector(7 downto 0);
      readTile          : out std_logic;
      writeTile         : out std_logic;
      p1x               : out std_logic_vector(7 downto 0);
      p1y               : out std_logic_vector(7 downto 0);
      p2x               : out std_logic_vector(7 downto 0);
      p2y               : out std_logic_vector(7 downto 0));
  end component;
	
  -- intermediate signals between PICT_MEM and VGA_MOTOR
  signal	data_out2_s     : std_logic_vector(7 downto 0);         -- data
  signal	addr2_s		: unsigned(10 downto 0);                -- address

  signal xPixel : unsigned(9 downto 0);
  signal yPixel : unsigned(9 downto 0);

  signal tilePixel : std_logic_vector(7 downto 0);
  signal tilePixelToVGA : std_logic_vector(7 downto 0);
  signal tilePixelIndexToTILE_MEMORY : integer;
  signal tileIndexToTILE_MEMORY : std_logic_vector(7 downto 0);
	
begin

  -- picture memory component connection
  U1 : VGA_MOTOR port map(
    clk=>clk,
    rst=>rst,
    playerPixel=>"10010000",
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
    readWrite => '0',
    tilePointer => 0,
    pixelIn => tilePixel,
    writeTile => "00000000",
    readTile => "00000000",
    pixelOut => tilePixelToVGA,
    tilePixelIndex => tilePixelIndexToTILE_MEMORY,
    tileIndex => tileIndexToTILE_MEMORY;
    );
	
  -- VGA motor component connection
  --U2 : VGA_MOTOR port map(clk=>clk, rst=>rst, data=>data_out2_s, addr=>addr2_s, vgaRed=>vgaRed, vgaGreen=>vgaGreen, vgaBlue=>vgaBlue, Hsync=>Hsync, Vsync=>Vsync);

end Behavioral;
