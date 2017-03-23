-------------------------------------------------------------------------------
-- TILE_PIXEL
-------------------------------------------------------------------------------
-- Rolf Sievert
-- Erik �rjehag
-- Gustav Svennas
-------------------------------------------------------------------------------

library IEEE;                           -- basic IEEE library
use IEEE.STD_LOGIC_1164.ALL;            -- IEEE library for the unsigned type
use IEEE.NUMERIC_STD.ALL;               -- and various arithmetic operations

-- entity
entity TILE_PIXEL is
  port (
    --clk         : in std_logic;                         -- system clock (100 MHz)
    xPixel      : in unsigned(9 downto 0);              -- Horizontal pixel counter
    yPixel	: in unsigned(9 downto 0);		-- Vertical pixel counter
    tilePixel   : in std_logic_vector(7 downto 0);      -- input from TILE_MEMORY
    pixel       : out std_logic_vector(7 downto 0);     -- output to VGA_MOTOR
    xTile       : out unsigned(9 downto 0);             -- Horizontal pixel counter
    yTile	: out unsigned(9 downto 0);		-- Vertical pixel counter
    xMap        : out unsigned(9 downto 0);             -- Horizontal pixel counter
    yMap	: out unsigned(9 downto 0);		-- Vertical pixel counter
  );

end TILE_PIXEL;

architecture behavioral of TILE_PIXEL is

begin  -- behavioral  process(clk)
  xMap <= xPixel / 16;
  yMap <= yPixel / 16;
  xTile <= xPixel mod 16;
  yTile <= yPixel mod 16;

  pixel <= tilePixel;

end behavioral;
