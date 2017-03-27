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
    readWrite           : in std_logic;    -- 0 is read, 1 is write
    tilePointer         : in integer;
    pixelIn             : in std_logic_vector(7 downto 0);
    writeTile           : in std_logic_vector(7 downto 0);
    readTile            : out std_logic_vector(7 downto 0) := X"00";
    pixelOut            : out std_logic_vector(7 downto 0);
    tilePixelIndex      : out integer := 0;
    tileIndex           : out std_logic_vector(7 downto 0) := X"00");
    
end MAP_MEMORY;

-- architecture
architecture behavioral of MAP_MEMORY is

  signal mapIndex : integer := 0;
  
  type map_t is array (0 to 194) of std_logic_vector(7 downto 0);
  signal karta : map_t :=
    (x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
     x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
     x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
     x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
     x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
     x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
     x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
     x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
     x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
     x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
     x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
     x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
     x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00");
begin  -- behavioral
  process(clk)
  begin
    if rising_edge(clk) then
      if readWrite = '0' then
        readTile <= karta(tilePointer);
      else
        karta(tilePointer) <= writeTile;
      end if;
    end if;
  end process;

  mapIndex <= to_integer(xPixel) + to_integer(yPixel) * 16;
  tileIndex <= karta(mapIndex);
  tilePixelIndex <= to_integer(xPixel mod 16) + (to_integer(yPixel mod 16) * 16);
  pixelOut <= pixelIn;

end behavioral;
