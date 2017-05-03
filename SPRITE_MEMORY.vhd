-------------------------------------------------------------------------------
-- SPRITE_MEMORY
-------------------------------------------------------------------------------
-- Rolf Sievert
-- Erik Örjehag
-- Gustav Svennas
-------------------------------------------------------------------------------


-- library declaration
library IEEE;                           -- basic IEEE library
use IEEE.STD_LOGIC_1164.ALL;            -- IEEE library for the unsigned type
use IEEE.NUMERIC_STD.ALL;               -- and various arithmetic operations
--use ieee.std_logic_unsigned.all;
--use ieee.std_logic_arith.all;

-- entity
entity SPRITE_MEMORY is
  port (
    clk         : in std_logic;                         -- system clock (100 MHz)
    xPixel      : in unsigned(9 downto 0);              -- Horizontal pixel counter
    yPixel	: in unsigned(9 downto 0);	        -- Vertical pixel counter
    p1x         : in unsigned(9 downto 0);              -- Number of pixels on board 16x15
    p1y         : in unsigned(9 downto 0);              -- Number of pixels on board 16x13
    p2x         : in unsigned(9 downto 0);              -- Number of pixels on board 16x15
    p2y         : in unsigned(9 downto 0);              -- Number of pixels on board 16x13
    playerPixel : out std_logic_vector(7 downto 0));    -- pixel from player 
end SPRITE_MEMORY;

-- architecture
architecture behavioral of SPRITE_MEMORY is

  constant transparent     : std_logic_vector(7 downto 0) := "10010000";

  signal pixelSize : integer := 2;

  signal player1Index : integer := 0;
  signal player1XCount : integer := 0;
  signal player1YCount : integer := 0;
  signal p1Draw : std_logic := '0';
  
  signal player2Index : integer := 0;
  signal player2XCount : integer := 0;
  signal player2YCount : integer := 0;
  signal p2Draw : std_logic := '0';
  
  -- Tile memory type
  type sprite_t is array (0 to 511) of std_logic_vector(7 downto 0);

  constant player1 : sprite_t :=
     (x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"6D",x"6D",x"6D",x"90",x"90",x"90",x"90",
      x"90",x"90",x"90",x"90",x"6D",x"6D",x"90",x"90",x"6D",x"24",x"24",x"24",x"6D",x"90",x"90",x"90",
      x"90",x"90",x"90",x"90",x"90",x"24",x"6D",x"90",x"6D",x"24",x"90",x"24",x"6D",x"90",x"90",x"90",
      x"90",x"90",x"90",x"90",x"90",x"24",x"6D",x"90",x"6D",x"24",x"90",x"6D",x"6D",x"90",x"90",x"90",
      x"90",x"90",x"90",x"90",x"90",x"24",x"6D",x"90",x"6D",x"24",x"90",x"90",x"6D",x"90",x"90",x"90",
      x"90",x"90",x"90",x"90",x"6D",x"24",x"24",x"24",x"24",x"24",x"24",x"90",x"90",x"90",x"90",x"90",
      x"90",x"90",x"90",x"90",x"6D",x"24",x"24",x"24",x"00",x"24",x"24",x"90",x"90",x"90",x"90",x"90",
      x"90",x"90",x"90",x"90",x"6D",x"24",x"B6",x"B6",x"00",x"B6",x"B6",x"90",x"90",x"90",x"90",x"90",
      x"90",x"90",x"90",x"90",x"6D",x"24",x"24",x"24",x"00",x"00",x"24",x"90",x"90",x"90",x"90",x"90",
      x"90",x"90",x"90",x"90",x"24",x"6D",x"24",x"24",x"24",x"24",x"24",x"90",x"90",x"90",x"90",x"90",
      x"90",x"90",x"90",x"90",x"24",x"6D",x"6D",x"B5",x"DA",x"B5",x"DA",x"90",x"90",x"90",x"90",x"90",
      x"90",x"90",x"90",x"90",x"90",x"6D",x"6D",x"6D",x"6D",x"6D",x"90",x"90",x"90",x"90",x"90",x"90",
      x"90",x"90",x"90",x"90",x"90",x"6D",x"6D",x"6D",x"6D",x"90",x"90",x"90",x"90",x"90",x"90",x"90",
      x"90",x"90",x"90",x"6D",x"6D",x"6D",x"6D",x"6D",x"6D",x"6D",x"6D",x"90",x"90",x"90",x"90",x"90",
      x"90",x"90",x"6D",x"6D",x"6D",x"6D",x"B6",x"B6",x"6D",x"6D",x"6D",x"6D",x"90",x"90",x"90",x"90",
      x"90",x"6D",x"6D",x"6D",x"6D",x"B6",x"B6",x"B6",x"B6",x"6D",x"6D",x"6D",x"6D",x"90",x"90",x"90",
      x"90",x"6D",x"90",x"6D",x"B6",x"B6",x"B6",x"B6",x"8D",x"B6",x"6D",x"90",x"6D",x"90",x"90",x"90",
      x"90",x"6D",x"90",x"6D",x"B6",x"8D",x"B6",x"B6",x"B6",x"B6",x"6D",x"90",x"6D",x"90",x"90",x"90",
      x"90",x"6D",x"90",x"6D",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"6D",x"90",x"6D",x"90",x"90",x"90",
      x"90",x"6D",x"90",x"6D",x"B6",x"B6",x"B6",x"B6",x"8D",x"B6",x"6D",x"90",x"6D",x"90",x"90",x"90",
      x"90",x"6D",x"90",x"6D",x"B6",x"8D",x"B6",x"B6",x"B6",x"B6",x"6D",x"90",x"6D",x"90",x"90",x"90",
      x"90",x"6D",x"90",x"6D",x"6D",x"B6",x"B6",x"B6",x"B6",x"6D",x"6D",x"90",x"6D",x"90",x"90",x"90",
      x"B6",x"6D",x"90",x"6D",x"6D",x"6D",x"B6",x"8D",x"6D",x"6D",x"6D",x"B6",x"6D",x"90",x"90",x"90",
      x"6D",x"6D",x"90",x"6D",x"6D",x"6D",x"6D",x"6D",x"6D",x"6D",x"6D",x"6D",x"6D",x"90",x"90",x"90",
      x"90",x"90",x"90",x"6D",x"6D",x"90",x"90",x"90",x"90",x"6D",x"6D",x"90",x"90",x"90",x"90",x"90",
      x"90",x"90",x"90",x"6D",x"6D",x"90",x"90",x"90",x"90",x"6D",x"6D",x"90",x"90",x"90",x"90",x"90",
      x"90",x"90",x"90",x"6D",x"6D",x"90",x"90",x"90",x"90",x"6D",x"6D",x"90",x"90",x"90",x"90",x"90",
      x"90",x"90",x"90",x"6D",x"6D",x"90",x"90",x"90",x"90",x"6D",x"6D",x"90",x"90",x"90",x"90",x"90",
      x"90",x"90",x"90",x"6D",x"6D",x"90",x"90",x"90",x"90",x"6D",x"6D",x"90",x"90",x"90",x"90",x"90",
      x"90",x"90",x"90",x"6D",x"6D",x"90",x"90",x"90",x"90",x"6D",x"6D",x"90",x"90",x"90",x"90",x"90",
      x"90",x"90",x"90",x"6D",x"B6",x"90",x"90",x"90",x"90",x"6D",x"B6",x"90",x"90",x"90",x"90",x"90",
      x"90",x"90",x"90",x"B6",x"B6",x"B6",x"90",x"90",x"90",x"B6",x"B6",x"B6",x"90",x"90",x"90",x"90"

      --x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",
      --x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",
      --x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",
      --x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",
      --x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",
      --x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",
      --x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",
      --x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",
      --x"90",x"90",x"90",x"90",x"0B",x"0B",x"90",x"90",x"90",x"90",x"0B",x"0B",x"90",x"90",x"90",x"90",
      --x"90",x"90",x"90",x"0B",x"0B",x"0B",x"0B",x"90",x"90",x"0B",x"0B",x"0B",x"0B",x"90",x"90",x"90",
      --x"90",x"90",x"0B",x"0B",x"90",x"00",x"0B",x"90",x"90",x"0B",x"00",x"90",x"0B",x"0B",x"90",x"90",
      --x"90",x"90",x"0B",x"0B",x"90",x"90",x"00",x"2B",x"2B",x"00",x"90",x"90",x"0B",x"0B",x"90",x"90",
      --x"90",x"90",x"90",x"90",x"90",x"2B",x"E6",x"2B",x"2B",x"E6",x"2B",x"90",x"90",x"90",x"90",x"90",
      --x"90",x"90",x"90",x"90",x"90",x"2B",x"2B",x"2B",x"2B",x"2B",x"2B",x"90",x"90",x"90",x"90",x"90",
      --x"90",x"90",x"90",x"90",x"90",x"2B",x"2B",x"00",x"00",x"2B",x"2B",x"90",x"90",x"90",x"90",x"90",
      --x"90",x"90",x"90",x"90",x"90",x"90",x"00",x"2B",x"2B",x"00",x"90",x"90",x"90",x"90",x"90",x"90",
      --x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"2B",x"2B",x"90",x"90",x"90",x"90",x"90",x"90",x"90",
      --x"90",x"90",x"90",x"90",x"90",x"2B",x"2B",x"0B",x"0B",x"2B",x"2B",x"90",x"90",x"90",x"90",x"90",
      --x"90",x"90",x"0B",x"0B",x"2B",x"0B",x"0B",x"0B",x"0B",x"0B",x"0B",x"2B",x"0B",x"0B",x"90",x"90",
      --x"90",x"0B",x"0B",x"90",x"2B",x"0B",x"0B",x"0B",x"0B",x"0B",x"0B",x"2B",x"90",x"0B",x"0B",x"90",
      --x"90",x"0B",x"0B",x"90",x"2B",x"0B",x"0B",x"0B",x"0B",x"0B",x"0B",x"2B",x"90",x"0B",x"0B",x"90",
      --x"90",x"0B",x"0B",x"90",x"2B",x"0B",x"0B",x"0B",x"0B",x"0B",x"0B",x"2B",x"90",x"0B",x"0B",x"90",
      --x"90",x"0B",x"0B",x"90",x"2B",x"0B",x"0B",x"0B",x"0B",x"0B",x"0B",x"2B",x"90",x"0B",x"0B",x"90",
      --x"90",x"0B",x"0B",x"90",x"2B",x"0B",x"0B",x"0B",x"0B",x"0B",x"0B",x"2B",x"90",x"0B",x"0B",x"90",
      --x"90",x"90",x"90",x"90",x"2B",x"0B",x"0B",x"0B",x"0B",x"0B",x"0B",x"2B",x"90",x"90",x"90",x"90",
      --x"90",x"90",x"90",x"90",x"90",x"2B",x"0B",x"0B",x"0B",x"0B",x"2B",x"90",x"90",x"90",x"90",x"90",
      --x"90",x"90",x"90",x"90",x"90",x"90",x"2B",x"2B",x"2B",x"2B",x"90",x"90",x"90",x"90",x"90",x"90",
      --x"90",x"90",x"90",x"90",x"90",x"2B",x"90",x"90",x"90",x"90",x"2B",x"90",x"90",x"90",x"90",x"90",
      --x"90",x"90",x"90",x"90",x"90",x"2B",x"90",x"90",x"90",x"90",x"2B",x"90",x"90",x"90",x"90",x"90",
      --x"90",x"90",x"90",x"90",x"2B",x"90",x"90",x"90",x"90",x"90",x"90",x"2B",x"90",x"90",x"90",x"90",
      --x"90",x"90",x"90",x"90",x"2B",x"90",x"90",x"90",x"90",x"90",x"90",x"2B",x"90",x"90",x"90",x"90",
      --x"90",x"90",x"90",x"2B",x"2B",x"2B",x"90",x"90",x"90",x"90",x"2B",x"2B",x"2B",x"90",x"90",x"90"
  );

  constant player2 : sprite_t :=
    (x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"E0",x"E0",x"E0",x"90",x"90",x"90",x"90",
     x"90",x"90",x"90",x"90",x"E0",x"E0",x"90",x"90",x"E0",x"80",x"80",x"80",x"E0",x"90",x"90",x"90",
     x"90",x"90",x"90",x"90",x"90",x"80",x"E0",x"90",x"E0",x"80",x"90",x"80",x"E0",x"90",x"90",x"90",
     x"90",x"90",x"90",x"90",x"90",x"80",x"E0",x"90",x"E0",x"80",x"90",x"E0",x"E0",x"90",x"90",x"90",
     x"90",x"90",x"90",x"90",x"90",x"80",x"E0",x"90",x"E0",x"80",x"90",x"90",x"E0",x"90",x"90",x"90",
     x"90",x"90",x"90",x"90",x"E0",x"80",x"80",x"80",x"80",x"80",x"80",x"90",x"90",x"90",x"90",x"90",
     x"90",x"90",x"90",x"90",x"E0",x"80",x"80",x"80",x"00",x"80",x"80",x"90",x"90",x"90",x"90",x"90",
     x"90",x"90",x"90",x"90",x"E0",x"80",x"FF",x"FF",x"00",x"FF",x"FF",x"90",x"90",x"90",x"90",x"90",
     x"90",x"90",x"90",x"90",x"E0",x"80",x"80",x"80",x"00",x"00",x"80",x"90",x"90",x"90",x"90",x"90",
     x"90",x"90",x"90",x"90",x"80",x"E0",x"80",x"80",x"80",x"80",x"80",x"90",x"90",x"90",x"90",x"90",
     x"90",x"90",x"90",x"90",x"80",x"E0",x"E0",x"80",x"80",x"80",x"E0",x"90",x"90",x"90",x"90",x"90",
     x"90",x"90",x"90",x"90",x"90",x"E0",x"E0",x"E0",x"E0",x"E0",x"90",x"90",x"90",x"90",x"90",x"90",
     x"90",x"90",x"90",x"90",x"90",x"E0",x"E0",x"E0",x"E0",x"90",x"90",x"90",x"90",x"90",x"90",x"90",
     x"90",x"90",x"90",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"90",x"90",x"90",x"90",x"90",
     x"90",x"90",x"E0",x"E0",x"E0",x"E0",x"B6",x"B6",x"E0",x"E0",x"E0",x"E0",x"90",x"90",x"90",x"90",
     x"90",x"E0",x"E0",x"E0",x"E0",x"B6",x"B6",x"F6",x"B6",x"E0",x"E0",x"E0",x"E0",x"90",x"90",x"90",
     x"90",x"E0",x"90",x"E0",x"B6",x"F6",x"B6",x"B6",x"B6",x"B6",x"E0",x"90",x"E0",x"90",x"90",x"90",
     x"90",x"E0",x"90",x"E0",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"E0",x"90",x"E0",x"90",x"90",x"90",
     x"90",x"E0",x"90",x"E0",x"B6",x"B6",x"F6",x"B6",x"B6",x"B6",x"E0",x"90",x"E0",x"90",x"90",x"90",
     x"90",x"E0",x"90",x"E0",x"B6",x"B6",x"B6",x"B6",x"F6",x"B6",x"E0",x"90",x"E0",x"90",x"90",x"90",
     x"90",x"E0",x"90",x"E0",x"E0",x"F6",x"B6",x"B6",x"B6",x"E0",x"E0",x"90",x"E0",x"90",x"90",x"90",
     x"90",x"E0",x"90",x"E0",x"E0",x"E0",x"B6",x"B6",x"E0",x"E0",x"E0",x"90",x"E0",x"90",x"90",x"90",
     x"6D",x"E0",x"90",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"6D",x"E0",x"90",x"90",x"90",
     x"E0",x"E0",x"90",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"90",x"90",x"90",
     x"90",x"90",x"90",x"E0",x"E0",x"90",x"90",x"90",x"90",x"E0",x"E0",x"90",x"90",x"90",x"90",x"90",
     x"90",x"90",x"90",x"E0",x"E0",x"90",x"90",x"90",x"90",x"E0",x"E0",x"90",x"90",x"90",x"90",x"90",
     x"90",x"90",x"90",x"E0",x"E0",x"90",x"90",x"90",x"90",x"E0",x"E0",x"90",x"90",x"90",x"90",x"90",
     x"90",x"90",x"90",x"E0",x"E0",x"90",x"90",x"90",x"90",x"E0",x"E0",x"90",x"90",x"90",x"90",x"90",
     x"90",x"90",x"90",x"E0",x"E0",x"90",x"90",x"90",x"90",x"E0",x"E0",x"90",x"90",x"90",x"90",x"90",
     x"90",x"90",x"90",x"E0",x"E0",x"90",x"90",x"90",x"90",x"E0",x"E0",x"90",x"90",x"90",x"90",x"90",
     x"90",x"90",x"90",x"E0",x"6D",x"90",x"90",x"90",x"90",x"E0",x"6D",x"90",x"90",x"90",x"90",x"90",
     x"90",x"90",x"90",x"6D",x"6D",x"6D",x"90",x"90",x"90",x"6D",x"6D",x"6D",x"90",x"90",x"90",x"90"

     --x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",
     --x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",
     --x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",
     --x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",
     --x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",
     --x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",
     --x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",
     --x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"90",
     --x"90",x"90",x"90",x"90",x"0B",x"0B",x"90",x"90",x"90",x"90",x"0B",x"0B",x"90",x"90",x"90",x"90",
     --x"90",x"90",x"90",x"0B",x"0B",x"0B",x"0B",x"90",x"90",x"0B",x"0B",x"0B",x"0B",x"90",x"90",x"90",
     --x"90",x"90",x"0B",x"0B",x"90",x"00",x"0B",x"90",x"90",x"0B",x"00",x"90",x"0B",x"0B",x"90",x"90",
     --x"90",x"90",x"0B",x"0B",x"90",x"90",x"00",x"2B",x"2B",x"00",x"90",x"90",x"0B",x"0B",x"90",x"90",
     --x"90",x"90",x"90",x"90",x"90",x"2B",x"E6",x"2B",x"2B",x"E6",x"2B",x"90",x"90",x"90",x"90",x"90",
     --x"90",x"90",x"90",x"90",x"90",x"2B",x"2B",x"2B",x"2B",x"2B",x"2B",x"90",x"90",x"90",x"90",x"90",
     --x"90",x"90",x"90",x"90",x"90",x"2B",x"2B",x"00",x"00",x"2B",x"2B",x"90",x"90",x"90",x"90",x"90",
     --x"90",x"90",x"90",x"90",x"90",x"90",x"00",x"2B",x"2B",x"00",x"90",x"90",x"90",x"90",x"90",x"90",
     --x"90",x"90",x"90",x"90",x"90",x"90",x"90",x"2B",x"2B",x"90",x"90",x"90",x"90",x"90",x"90",x"90",
     --x"90",x"90",x"90",x"90",x"90",x"2B",x"2B",x"0B",x"0B",x"2B",x"2B",x"90",x"90",x"90",x"90",x"90",
     --x"90",x"90",x"0B",x"0B",x"2B",x"0B",x"0B",x"0B",x"0B",x"0B",x"0B",x"2B",x"0B",x"0B",x"90",x"90",
     --x"90",x"0B",x"0B",x"90",x"2B",x"0B",x"0B",x"0B",x"0B",x"0B",x"0B",x"2B",x"90",x"0B",x"0B",x"90",
     --x"90",x"0B",x"0B",x"90",x"2B",x"0B",x"0B",x"0B",x"0B",x"0B",x"0B",x"2B",x"90",x"0B",x"0B",x"90",
     --x"90",x"0B",x"0B",x"90",x"2B",x"0B",x"0B",x"0B",x"0B",x"0B",x"0B",x"2B",x"90",x"0B",x"0B",x"90",
     --x"90",x"0B",x"0B",x"90",x"2B",x"0B",x"0B",x"0B",x"0B",x"0B",x"0B",x"2B",x"90",x"0B",x"0B",x"90",
     --x"90",x"0B",x"0B",x"90",x"2B",x"0B",x"0B",x"0B",x"0B",x"0B",x"0B",x"2B",x"90",x"0B",x"0B",x"90",
     --x"90",x"90",x"90",x"90",x"2B",x"0B",x"0B",x"0B",x"0B",x"0B",x"0B",x"2B",x"90",x"90",x"90",x"90",
     --x"90",x"90",x"90",x"90",x"90",x"2B",x"0B",x"0B",x"0B",x"0B",x"2B",x"90",x"90",x"90",x"90",x"90",
     --x"90",x"90",x"90",x"90",x"90",x"90",x"2B",x"2B",x"2B",x"2B",x"90",x"90",x"90",x"90",x"90",x"90",
     --x"90",x"90",x"90",x"90",x"90",x"2B",x"90",x"90",x"90",x"90",x"2B",x"90",x"90",x"90",x"90",x"90",
     --x"90",x"90",x"90",x"90",x"90",x"2B",x"90",x"90",x"90",x"90",x"2B",x"90",x"90",x"90",x"90",x"90",
     --x"90",x"90",x"90",x"90",x"2B",x"90",x"90",x"90",x"90",x"90",x"90",x"2B",x"90",x"90",x"90",x"90",
     --x"90",x"90",x"90",x"90",x"2B",x"90",x"90",x"90",x"90",x"90",x"90",x"2B",x"90",x"90",x"90",x"90",
     --x"90",x"90",x"90",x"2B",x"2B",x"2B",x"90",x"90",x"90",x"90",x"2B",x"2B",x"2B",x"90",x"90",x"90"
     );
  
begin  -- behavioral
  process(clk)
  begin
    if rising_edge(clk) then
      -- P1
      if xPixel >= p1x*16*pixelSize and to_integer(xPixel) < to_integer(p1x)*16*pixelSize + 16*pixelSize
        and yPixel >= p1y*16*pixelSize and to_integer(yPixel) < to_integer(p1y)*16*pixelSize + 32*pixelSize then
        
        p1Draw <= '1';
        if xPixel = p1x*16*pixelSize then
          player1XCount <= 0;
          if yPixel = p1y*16*pixelSize then
            player1YCount <= 0;
          else
            player1YCount <= player1YCount + 1;
          end if;
        else
          player1XCount <= player1XCount + 1;
        end if;
        player1Index <= player1XCount/(pixelSize*4) + (player1YCount/(pixelSize*4)) * 16;
      else
        p1Draw <= '0';
      end if;

      -- P2
      if xPixel >= p2x*16*pixelSize and to_integer(xPixel) < to_integer(p2x)*16*pixelSize + 16*pixelSize
        and yPixel >= p2y*16*pixelSize and to_integer(yPixel) < to_integer(p2y)*16*pixelSize + 32*pixelSize then
        
        p2Draw <= '1';
        if xPixel = p2x*16*pixelSize then
          player2XCount <= 0;
          if yPixel = p2y*16*pixelSize then
            player2YCount <= 0;
          else
            player2YCount <= player2YCount + 1;
          end if;
        else
          player2XCount <= player2XCount + 1;
        end if;
        player2Index <= player2XCount/(pixelSize*4) + (player2YCount/(pixelSize*4)) * 16;
      else
        p2Draw <= '0';
      end if;
      
      -- Draw closest player ontop
      if p1y > p2y then
        if p1Draw = '1' and not (player1(player1Index) = transparent) then
          playerPixel <= player1(player1Index);
        elsif p2Draw = '1' then
          playerPixel <= player2(player2Index);
        else
          playerPixel <= transparent;
        end if;
      else
        if p2Draw = '1' and not (player2(player2Index) = transparent) then
          playerPixel <= player2(player2Index);
        elsif p1Draw = '1' then
          playerPixel <= player1(player1Index);
        else
          playerPixel <= transparent;
        end if;
      end if;
    end if;
  end process;    
end behavioral;
