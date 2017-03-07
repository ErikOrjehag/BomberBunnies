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
    clk         : in std_logic;                      -- system clock (100 MHz)
    rst	        : in std_logic;
    xPos        : in unsigned;
    yPos        : in unsigned;

    
  );                
end MAP_MEMORY;

-- architecture
architecture behavioral of MAP_MEMORY is

  type map_t is array (0 upto 194) of std_logic_vector(7 downto 0);
  signal map : map_t;
  
begin  -- behavioral

end behavioral;
