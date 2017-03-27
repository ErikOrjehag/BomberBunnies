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
    rst	        : in std_logic;
    xPixel      : in unsigned(9 downto 0);              -- Horizontal pixel counter
    yPixel	: in unsigned(9 downto 0);	        -- Vertical pixel counter
    p1x         : in unsigned(7 downto 0);              -- Number of pixels on board 16x16x15
    p1y         : in unsigned(7 downto 0);              -- Number of pixels on board 16x16x13
    p2x         : in unsigned(7 downto 0);              -- Number of pixels on board 16x16x15
    p2y         : in unsigned(7 downto 0);              -- Number of pixels on board 16x16x13
    playerPixel : out std_logic_vector(7 downto 0));    -- pixel from player 
end SPRITE_MEMORY;

-- architecture
architecture behavioral of SPRITE_MEMORY is

  constant transparent     : std_logic_vector(7 downto 0) := "10010000";

  signal player1Index : integer := 0;
  signal player1XCount : integer := 0;
  signal player1True : std_logic := '0';
  
  signal player2Index : integer := 0;
  signal player2XCount : integer := 0;
  signal player2True : std_logic := '0';
  
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
  process(clk)
  begin
    if rising_edge(clk) then
      if xPixel >= p1x and player1XCount <= 15 and yPixel >= p1y and player1Index <= 16*32-1 then
        
        -- P1
        if player1XCount = 15 then
          player1XCount <= 0;
        else
          player1XCount <= player1XCount + 1;
          player1Index <= player1Index + 1;
        end if;
        
        if player1Index = 16*32-1 then
          player1Index <= 0;
          player1True <= '0';
        else
          player1True <= '1';
        end if;
      end if;
      
      -- P2
      if player2XCount = 15 then
        player2XCount <= 0;
      else
        player2XCount <= player2XCount + 1;
        player2Index <= player2Index + 1;
      end if;
        
      if player2Index = 16*32-1 then
        player2Index <= 0;
        player2True <= '0';
      else
        player2True <= '1';
      end if;
      
      -- Draw closest player ontop
      if p1y > p2y then
        if player1True = '1' then
          playerPixel <= player1(player1Index);
        elsif player2True = '1' then
          playerPixel <= player2(player2Index);
        else
          playerPixel <= transparent;
        end if;
      else
        if player2True = '1' then
          playerPixel <= player2(player2Index);
        elsif player1True = '1' then
          playerPixel <= player1(player1Index);
        else
          playerPixel <= transparent;
        end if;
      end if;
    end if;
  end process;    
end behavioral;
