-------------------------------------------------------------------------------
-- MAP_MEMORY
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
entity MAP_MEMORY is
  port (
    clk                 : in std_logic;                      -- system clock (100 MHz)
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
    
end MAP_MEMORY;

-- architecture
architecture behavioral of MAP_MEMORY is

  constant pixelSize : integer := 2;
  signal mapIndex : integer := 0;
  signal tilePointerInteger : integer := 0;
  
  type map_t is array (0 to 194) of std_logic_vector(7 downto 0);
  signal karta : map_t :=
    (x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01",
     x"01", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"01",
     x"01", x"00", x"01", x"00", x"01", x"00", x"01", x"00", x"01", x"00", x"01", x"00", x"01", x"00", x"01",
     x"01", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"01",
     x"01", x"00", x"01", x"00", x"01", x"00", x"01", x"00", x"01", x"00", x"01", x"00", x"01", x"00", x"01",
     x"01", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"01",
     x"01", x"00", x"01", x"00", x"01", x"00", x"01", x"00", x"01", x"00", x"01", x"00", x"01", x"02", x"01",
     x"01", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"02", x"02", x"02", x"01",
     x"01", x"00", x"01", x"00", x"01", x"00", x"01", x"00", x"01", x"00", x"01", x"02", x"01", x"02", x"01",
     x"01", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"02", x"02", x"02", x"01",
     x"01", x"00", x"01", x"00", x"01", x"00", x"01", x"00", x"01", x"00", x"01", x"02", x"01", x"02", x"01",
     x"01", x"03", x"03", x"04", x"04", x"00", x"00", x"00", x"00", x"02", x"02", x"02", x"02", x"02", x"01",
     x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01");
begin  -- behavioral

  tilePointerInteger <= to_integer(unsigned(tilePointer));
  
  process(clk)
  begin
    if rising_edge(clk) then
      if readMap = '1' then
        tileTypeRead <= karta(tilePointerInteger);
      end if;
      if writeMap = '1' then
        karta(tilePointerInteger) <= tileTypeWrite;
      end if;

      if xPixel < 16*15*pixelSize and yPixel < 16*13*pixelSize then
        mapIndex <= to_integer(xPixel) / (16*pixelSize) + (to_integer(yPixel) / (16*pixelSize)) * 15;
        tileIndex <= to_integer(unsigned(karta(mapIndex)));
        tilePixelIndex <= (to_integer(xPixel)/pixelSize) mod 16 + ((to_integer(yPixel)/pixelSize) mod 16 * 16);
        pixelOut <= pixelIn;
      else
        pixelOut <= x"00";
      end if;
    end if;
  end process;

  
end behavioral;
