--------------------------------------------------------------------------------
-- VGA lab
-- TEAM REG


-- library declaration
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;            -- basic IEEE library
use IEEE.NUMERIC_STD.ALL;               -- IEEE library for the unsigned type
                                        -- and various arithmetic operations

-- entity
entity BOMBER_BUNNIES is
  port ( clk	                : in std_logic;                         -- system clock
	 rst                    : in std_logic;                         -- reset
	 hSync	                : out std_logic;                        -- horizontal sync
	 vSync	                : out std_logic;                        -- vertical sync
	 vgaRed	                : out	std_logic_vector(2 downto 0);   -- VGA red
	 vgaGreen               : out std_logic_vector(2 downto 0);     -- VGA green
	 vgaBlue	        : out std_logic_vector(2 downto 1));     -- VGA blue
end BOMBER_BUNNIES;


-- architecture
architecture Behavioral of BOMBER_BUNNIES is

-- VGA motor component
  component VGA_MOTOR
    port ( clk		: in std_logic;                         -- system clock
           rst	        : in std_logic;
           vgaRed       : out std_logic_vector(2 downto 0);
           vgaGreen     : out std_logic_vector(2 downto 0);
           vgaBlue      : out std_logic_vector(2 downto 1);
           hSync        : out std_logic;
           vSync	: out std_logic;
           xPixel       : buffer unsigned(9 downto 0);         -- Horizontal pixel counter
           yPixel	: buffer unsigned(9 downto 0);		-- Vertical pixel counter
           playerPixel : in std_logic_vector(7 downto 0);   -- pixel from player
           mapPixel    : in std_logic_vector(7 downto 0));   -- Tile pixel data
  end component;
  
  -- picture memory component
  component TILE_PIXEL
    port (  xPixel      : in unsigned(9 downto 0);              -- Horizontal pixel counter
            yPixel	: in unsigned(9 downto 0);		-- Vertical pixel counter
            tilePixel   : in std_logic_vector(7 downto 0);      -- input from TILE_MEMORY
            pixel       : out std_logic_vector(7 downto 0);     -- output to VGA_MOTOR
            xTile       : out unsigned(9 downto 0);             -- Horizontal pixel counter
            yTile	: out unsigned(9 downto 0);		-- Vertical pixel counter
            xMap        : out unsigned(9 downto 0);             -- Horizontal pixel counter
            yMap	: out unsigned(9 downto 0));		-- Vertical pixel counter
           
  end component;

  -- VGA motor component
  component TILE_MEMORY
    port ( clk			: in std_logic;                         -- system clock
           pixelXPos              : in std_logic_vector(3 downto 0);
           pixelYPos              : in std_logic_vector(3 downto 0);
           tileIndex              : in std_logic_vector(7 downto 0);
           pixel                  : out std_logic_vector(7 downto 0);
           rst                    : in std_logic);
  end component;
	
  -- VGA motor component
  component MAP_MEMORY
    port ( clk			: in std_logic;                         -- system clock
           rst	        : in std_logic;
           xPos        : in unsigned;
           yPos        : in unsigned);
           
  end component;

  -- VGA motor component
  component SPRITE_MEMORY
    port ( clk			: in std_logic;                         -- system clock
           rst	        : in std_logic;
           xPixel      : in unsigned(9 downto 0);         -- Horizontal pixel counter
           yPixel	: in unsigned(9 downto 0);	   -- Vertical pixel counter
           p1x         : in unsigned(7 downto 0);  -- Number of pixels on board 16x16x15
           p1y         : in unsigned(7 downto 0);  -- Number of pixels on board 16x16x13
           p2x         : in unsigned(7 downto 0);  -- Number of pixels on board 16x16x15
           p2y         : in unsigned(7 downto 0);  -- Number of pixels on board 16x16x13
           playerPixel : out std_logic_vector(7 downto 0));   -- pixel from player
           
  end component;

  -- VGA motor component
  component CPU
    port ( clk			: in std_logic;                         -- system clock
           rst	        : in std_logic;
           tilePointer : buffer std_logic_vector(7 downto 0) := (others => '0');
           tileIndex   : buffer std_logic_vector(7 downto 0);
           readTile    : out std_logic;
           writeTile   : out std_logic;
           joy1x       : in std_logic_vector(1 downto 0) := (others => '0');
           joy1y       : in std_logic_vector(1 downto 0) := (others => '0');
           btn1        : in std_logic;
           joy2x       : in std_logic_vector(1 downto 0) := (others => '0');
           joy2y       : in std_logic_vector(1 downto 0) := (others => '0');
           btn2        : in std_logic;
           p1x         : out std_logic_vector(7 downto 0);
           p1y         : out std_logic_vector(7 downto 0);
           p2x         : out std_logic_vector(7 downto 0);
           p2y         : out std_logic_vector(7 downto 0));
  end component;
	
  -- intermediate signals between PICT_MEM and VGA_MOTOR
  signal	data_out2_s     : std_logic_vector(7 downto 0);         -- data
  signal	addr2_s		: unsigned(10 downto 0);                -- address
	
begin

  -- picture memory component connection
  U1 : VGA_MOTOR port map(clk=>clk, rst=>rst, vgaRed=>vgaRed, vgaGreen=>vgaGreen, vgaBlue=>vgaBlue, hSync=>hSync, vSync=>vSync, playerPixel=>"11100000", mapPixel=>"10010000");
	
  -- VGA motor component connection
  --U2 : VGA_MOTOR port map(clk=>clk, rst=>rst, data=>data_out2_s, addr=>addr2_s, vgaRed=>vgaRed, vgaGreen=>vgaGreen, vgaBlue=>vgaBlue, Hsync=>Hsync, Vsync=>Vsync);

end Behavioral;
