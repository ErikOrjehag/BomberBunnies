-- library declaration
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;            -- basic IEEE library
use IEEE.NUMERIC_STD.ALL;

entity TILE_MEMORY is
  port ( clk                    : in std_logic;
         pixelXPos              : in std_logic_vector(3 downto 0);
         pixelYPos              : in std_logic_vector(3 downto 0);
         tileIndex              : in std_logic_vector(7 downto 0);
         pixel                  : out std_logic_vector(7 downto 0);
         rst                    : in std_logic;
end TILE_MEMORY;

architecture Behavioral of TILE_MEMORY is
  -- Tile memory type
  type ram_t is array (0 to 1279) of std_logic_vector(7 downto 0);

  -- Tile memory
  signal memory : ram_t :=
               (
                 );                             -- input tile memory here

begin

  process(clk)
    begin
      if rising_edge(clk) then
        
      end if;

end Behavioral ;
