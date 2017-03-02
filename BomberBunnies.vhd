-------------------------------------------------------------------------------
-- BOMBER BUNNIES
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
entity BomberBunnies is
  port (
    clk : in std_logic;
    data : in std_logic_vector(7 downto 0);
    vgaRed : out std_logic_vector(2 downto 0);
    vgaGreen : out std_logic_vector(2 downto 0);
    vgaBlue : out std_logic_vector(2 downto 1);

    );                -- system clock (100 MHz)
end BomberBunnies;

-- architecture
architecture behavioral of BomberBunnies is
  type ram_t is array (0 to 2047) of std_logic_vector(7 downto 0);
  signal tile_mem : ram_t := ( x"FF", x"FF");  -- tile memory
  
begin  -- behavioral

  

end behavioral;
