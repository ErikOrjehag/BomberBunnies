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
    clk         : in std_logic;                      -- system clock (100 MHz)
    rst	        : in std_logic;
    xPixel      : in std_logic_vector(9 downto 0);         -- Horizontal pixel counter
    yPixel	: in std_logic_vector(9 downto 0);	   -- Vertical pixel counter
    p1x         : in std_logic_vector(7 downto 0);  -- Number of pixels on board 16x16x15
    p1y         : in std_logic_vector(7 downto 0);  -- Number of pixels on board 16x16x13
    p2x         : in std_logic_vector(7 downto 0);  -- Number of pixels on board 16x16x15
    p2y         : in std_logic_vector(7 downto 0);  -- Number of pixels on board 16x16x13
    playerPixel : out std_logic_vector(7 downto 0));   -- pixel from player 
end SPRITE_MEMORY;

-- architecture
architecture behavioral of SPRITE_MEMORY is
  constant transparent     : std_logic_vector(7 downto 0) := "10010000";
  signal player1Index : integer;
  signal player1XCount : integer;
  signal player1YCount : integer;
  signal player1True : std_logic := '0';
  
  -- Tile memory type
  type sprite_t is array (0 to 255) of std_logic_vector(7 downto 0);

  constant player1 : sprite_t :=
    (x"90", x"90", x"90", x"90", x"90", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
     x"90", x"90", x"90", x"90", x"90", x"FF", x"90", x"FF", x"FF", x"FF", x"FF", x"CA", x"FF", x"FF", x"FF", x"FF",
     x"90", x"90", x"90", x"90", x"90", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
     x"90", x"90", x"90", x"90", x"90", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
     x"90", x"90", x"90", x"90", x"90", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
     x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
     x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
     x"FF", x"FF", x"FF", x"FF", x"CA", x"CA", x"CA", x"FF", x"FF", x"90", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
     x"FF", x"FF", x"FF", x"FF", x"CA", x"90", x"CA", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
     x"FF", x"FF", x"FF", x"FF", x"CA", x"CA", x"CA", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
     x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"CA", x"FF", x"FF", x"FF",
     x"FF", x"FF", x"CA", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
     x"CA", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"CA", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
     x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
     x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"CA", x"FF", x"FF",
     x"FF", x"FF", x"FF", x"CA", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
     x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
     x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"CA", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
     x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
     x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"CA", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
     x"FF", x"FF", x"FF", x"90", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
     x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
     x"90", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
     x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
     x"FF", x"FF", x"FF", x"FF", x"90", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"90", x"FF", x"FF", x"FF",
     x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
     x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
     x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"CA", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
     x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
     x"FF", x"CA", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
     x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
     x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF");

  constant player2 : sprite_t :=
    (x"90", x"90", x"90", x"90", x"90", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
     x"90", x"90", x"90", x"90", x"90", x"FF", x"90", x"FF", x"FF", x"FF", x"FF", x"CA", x"FF", x"FF", x"FF", x"FF",
     x"90", x"90", x"90", x"90", x"90", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
     x"90", x"90", x"90", x"90", x"90", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
     x"90", x"90", x"90", x"90", x"90", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
     x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
     x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
     x"FF", x"FF", x"FF", x"FF", x"CA", x"CA", x"CA", x"FF", x"FF", x"90", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
     x"FF", x"FF", x"FF", x"FF", x"CA", x"90", x"CA", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
     x"FF", x"FF", x"FF", x"FF", x"CA", x"CA", x"CA", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
     x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"CA", x"FF", x"FF", x"FF",
     x"FF", x"FF", x"CA", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
     x"CA", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"CA", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
     x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
     x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"CA", x"FF", x"FF",
     x"FF", x"FF", x"FF", x"CA", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
     x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
     x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"CA", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
     x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
     x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"CA", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
     x"FF", x"FF", x"FF", x"90", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
     x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
     x"90", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
     x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
     x"FF", x"FF", x"FF", x"FF", x"90", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"90", x"FF", x"FF", x"FF",
     x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
     x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
     x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"CA", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
     x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
     x"FF", x"CA", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
     x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
     x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF");
  
begin  -- behavioral
  --process(clk)
  --begin
  --  if (xPixel >= p1x and xPixel < p1x + 16 and yPixel >= p1y and yPixel < p1y + 16) then
  --    playerPixel <= player1(unsigned(yPixel - p1y) + unsigned(xPixel - p1x));
  --  elsif (xPixel >= p2x and xPixel < p2x + "10000" and yPixel >= p2y and yPixel < p2y + "10000") then 
  --    playerPixel <= player2(player2Index);
  --  else
  --    playerPixel <= transparent;
  --  end if;
  --end process;

  process(clk)
  begin
    if rising_edge(clk) then
      if xPixel >= p1x and player1XCount < 16 then
        player1XCount = player1XCount + 1;
        player1Index = player1Index + 1;
      end if;
    end if;
  end process;

  
  playerPixel <=
    --player1((yPixel - p1y) + (xPixel - p1x)) when (xPixel >= p1x and xPixel < p1x + "10000" and yPixel >= p1y and yPixel < p1y + "10000") else --when pixel points at player 1
    player2(player2Index) when (xPixel >= p2x and xPixel < p2x + "10000" and yPixel >= p2y and yPixel < p2y + "10000");      --when pixel points at player 2
    --else transparent;                                                                                                                   --else assign transparent
    
end behavioral;
