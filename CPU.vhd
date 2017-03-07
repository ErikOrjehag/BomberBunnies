-------------------------------------------------------------------------------
-- CPU
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
entity CPU is
  port (
    clk         : in std_logic;                      -- system clock (100 MHz)
    rst	        : in std_logic;
  );                
end VGA_MOTOR;

-- architecture
architecture behavioral of BomberBunnies is

  type pm_t is array (0 to 2047) of std_logic_vector(7 downto 0);
  signal PM : pm_t;
  
begin  -- behavioral

end behavioral;
