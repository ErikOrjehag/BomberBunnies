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


-- entity
entity SPRITE_MEMORY is
  port (
    clk         : in std_logic;                      -- system clock (100 MHz)
    rst	        : in std_logic;
    xPixel      : in unsigned(9 downto 0);         -- Horizontal pixel counter
    yPixel	: in unsigned(9 downto 0);	   -- Vertical pixel counter
    p1x         : in unsigned(7 downto 0);  -- Number of pixels on board 16x16x15
    p1y         : in unsigned(7 downto 0);  -- Number of pixels on board 16x16x13
    p2x         : in unsigned(7 downto 0);  -- Number of pixels on board 16x16x15
    p2y         : in unsigned(7 downto 0);  -- Number of pixels on board 16x16x13
    playerPixel : out std_logic_vector(7 downto 0);   -- pixel from player
  );                
end SPRITE_MEMORY;

-- architecture
architecture behavioral of SPRITE_MEMORY is
  constant transparent     : std_logic_vector(7 downto 0) := "10010000";
  
  -- Tile memory type
  type sprite_t is array (0 to 255) of std_logic_vector(7 downto 0);

  constant player1 : sprite_t :=
    (x'90', x'90', x'90', x'90', x'90', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF'
     x'90', x'90', x'90', x'90', x'90', x'FF', x'90', x'FF', x'FF', x'FF', x'FF', x'CA', x'FF', x'FF', x'FF', x'FF'
     x'90', x'90', x'90', x'90', x'90', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF'
     x'90', x'90', x'90', x'90', x'90', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF'
     x'90', x'90', x'90', x'90', x'90', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF'
     x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF'
     x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF'
     x'FF', x'FF', x'FF', x'FF', x'CA', x'CA', x'CA', x'FF', x'FF', x'90', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF'
     x'FF', x'FF', x'FF', x'FF', x'CA', x'90', x'CA', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF'
     x'FF', x'FF', x'FF', x'FF', x'CA', x'CA', x'CA', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF'
     x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'CA', x'FF', x'FF', x'FF'
     x'FF', x'FF', x'CA', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF'
     x'CA', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'CA', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF'
     x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF'
     x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'CA', x'FF', x'FF'
     x'FF', x'FF', x'FF', x'CA', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF'
     x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF'
     x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'CA', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF'
     x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF'
     x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'CA', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF'
     x'FF', x'FF', x'FF', x'90', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF'
     x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF'
     x'90', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF'
     x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF'
     x'FF', x'FF', x'FF', x'FF', x'90', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'90', x'FF', x'FF', x'FF'
     x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF'
     x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF'
     x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'CA', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF'
     x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF'
     x'FF', x'CA', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF'
     x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF'
     x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF');

  constant player2 : sprite_t :=
    (x'90', x'90', x'90', x'90', x'90', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF'
     x'90', x'90', x'90', x'90', x'90', x'FF', x'90', x'FF', x'FF', x'FF', x'FF', x'CA', x'FF', x'FF', x'FF', x'FF'
     x'90', x'90', x'90', x'90', x'90', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF'
     x'90', x'90', x'90', x'90', x'90', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF'
     x'90', x'90', x'90', x'90', x'90', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF'
     x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF'
     x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF'
     x'FF', x'FF', x'FF', x'FF', x'CA', x'CA', x'CA', x'FF', x'FF', x'90', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF'
     x'FF', x'FF', x'FF', x'FF', x'CA', x'90', x'CA', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF'
     x'FF', x'FF', x'FF', x'FF', x'CA', x'CA', x'CA', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF'
     x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'CA', x'FF', x'FF', x'FF'
     x'FF', x'FF', x'CA', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF'
     x'CA', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'CA', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF'
     x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF'
     x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'CA', x'FF', x'FF'
     x'FF', x'FF', x'FF', x'CA', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF'
     x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF'
     x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'CA', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF'
     x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF'
     x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'CA', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF'
     x'FF', x'FF', x'FF', x'90', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF'
     x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF'
     x'90', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF'
     x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF'
     x'FF', x'FF', x'FF', x'FF', x'90', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'90', x'FF', x'FF', x'FF'
     x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF'
     x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF'
     x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'CA', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF'
     x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF'
     x'FF', x'CA', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF'
     x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF'
     x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF', x'FF');
  
begin  -- behavioral

  playerPixel <= player1((yPixel - p1y)*16 + (xPixel - p1x))  --Assign player 1 pixel
    when (xPixel >= p1x and xPixel <= p1x + 16 and yPixel >= p1y and yPixel <= p1y +32) --when pixel points at player 1
    else (player2((yPixel - p2y)*16 + (xPixel - p2x))         --Assign player 2 pixel
          when (xPixel >= p2x and xPixel <= p2x + 16 and yPixel >= p2y and yPixel <= p2y + 32) --when pixel points at player 2
          else transparent); --else assign transparent
    
end behavioral;
