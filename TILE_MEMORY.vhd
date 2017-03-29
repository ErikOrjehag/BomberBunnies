-- library declaration
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;            -- basic IEEE library
use IEEE.NUMERIC_STD.ALL;

entity TILE_MEMORY is
  port (
    clk                    : in std_logic;
    tilePixelIndex         : in integer;
    tileIndex              : in integer;
    pixel                  : out std_logic_vector(7 downto 0));
end TILE_MEMORY;

architecture behavioral of TILE_MEMORY is
  -- Tile memory type
  type ram_t is array (0 to 1279) of std_logic_vector(7 downto 0);

  signal index : integer := 0;
  
  -- Grass
  -- Wall
  -- DestructiveWall
  -- Eggbomb
  -- Explosion

  -- Tile memory
  signal memory : ram_t :=
               ( x"74",x"34",x"74",x"34",x"34",x"34",x"34",x"34",x"34",x"34",x"34",x"34",x"34",x"54",x"34",x"34", --grass
                 x"34",x"34",x"74",x"34",x"34",x"54",x"34",x"34",x"34",x"34",x"54",x"34",x"34",x"54",x"14",x"54",
                 x"54",x"34",x"14",x"14",x"14",x"54",x"34",x"34",x"34",x"34",x"54",x"14",x"34",x"54",x"34",x"34",
                 x"54",x"14",x"34",x"14",x"34",x"54",x"34",x"34",x"14",x"34",x"34",x"34",x"14",x"34",x"34",x"34",
                 x"34",x"14",x"14",x"34",x"34",x"34",x"34",x"34",x"34",x"54",x"34",x"34",x"74",x"34",x"34",x"54",
                 x"34",x"34",x"34",x"34",x"54",x"34",x"34",x"54",x"14",x"54",x"34",x"34",x"34",x"74",x"14",x"54",
                 x"54",x"34",x"74",x"34",x"34",x"34",x"74",x"34",x"34",x"34",x"54",x"34",x"34",x"34",x"34",x"34",
                 x"34",x"34",x"34",x"74",x"34",x"34",x"34",x"34",x"34",x"34",x"34",x"34",x"74",x"74",x"34",x"34",
                 x"34",x"34",x"74",x"74",x"34",x"34",x"54",x"54",x"34",x"34",x"34",x"34",x"34",x"34",x"34",x"34",
                 x"34",x"34",x"34",x"74",x"34",x"34",x"34",x"34",x"34",x"34",x"54",x"34",x"34",x"54",x"54",x"54",
                 x"34",x"34",x"34",x"34",x"54",x"34",x"34",x"34",x"34",x"54",x"34",x"34",x"34",x"34",x"34",x"34",
                 x"34",x"34",x"34",x"34",x"54",x"34",x"34",x"34",x"34",x"54",x"34",x"34",x"34",x"34",x"34",x"34",
                 x"54",x"34",x"54",x"34",x"34",x"34",x"34",x"54",x"34",x"54",x"34",x"34",x"34",x"34",x"54",x"54",
                 x"34",x"34",x"34",x"54",x"34",x"34",x"34",x"34",x"34",x"34",x"34",x"74",x"54",x"34",x"54",x"34",
                 x"34",x"34",x"34",x"34",x"34",x"14",x"34",x"34",x"54",x"34",x"34",x"34",x"74",x"34",x"34",x"34",
                 x"34",x"54",x"34",x"54",x"34",x"54",x"34",x"34",x"34",x"34",x"34",x"34",x"74",x"74",x"54",x"34",
                 
                 x"49",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",
                 x"49",x"6D",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"DA",
                 x"49",x"6D",x"91",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"DA",x"DA",
                 x"49",x"6D",x"91",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"DA",x"DA",
                 x"49",x"6D",x"91",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"DA",x"DA",
                 x"49",x"6D",x"91",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"DA",x"DA",
                 x"49",x"6D",x"91",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"DA",x"DA",
                 x"49",x"6D",x"91",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"DA",x"DA",
                 x"49",x"6D",x"91",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"DA",x"DA",
                 x"49",x"6D",x"91",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"DA",x"DA",
                 x"49",x"6D",x"91",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"DA",x"DA",
                 x"49",x"6D",x"91",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"DA",x"DA",
                 x"49",x"6D",x"91",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"DA",x"DA",
                 x"49",x"6D",x"91",x"91",x"91",x"91",x"91",x"91",x"91",x"91",x"91",x"91",x"91",x"91",x"DA",x"DA",
                 x"49",x"6D",x"6D",x"6D",x"6D",x"6D",x"6D",x"6D",x"6D",x"6D",x"6D",x"6D",x"6D",x"6D",x"6D",x"DA",
                 x"49",x"49",x"49",x"49",x"49",x"49",x"49",x"49",x"49",x"49",x"49",x"49",x"49",x"49",x"49",x"49",
                 
                 --x"6D",x"6D",x"6D",x"6D",x"6D",x"6D",x"6D",x"6D",x"6D",x"6D",x"6D",x"6D",x"6D",x"6D",x"6D",x"6D",   -- Wall(SteelCross)
                 --x"6D",x"24",x"6D",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"6D",x"24",x"6D",
                 --x"6D",x"6D",x"24",x"6D",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"6D",x"24",x"6D",x"6D",
                 --x"6D",x"B6",x"6D",x"24",x"6D",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"6D",x"24",x"6D",x"B6",x"6D",
                 --x"6D",x"B6",x"B6",x"6D",x"24",x"6D",x"B6",x"B6",x"B6",x"B6",x"6D",x"24",x"6D",x"B6",x"B6",x"6D",
                 --x"6D",x"B6",x"B6",x"B6",x"6D",x"24",x"6D",x"B6",x"B6",x"6D",x"24",x"6D",x"B6",x"B6",x"B6",x"6D",
                 --x"6D",x"B6",x"B6",x"B6",x"B6",x"6D",x"24",x"6D",x"6D",x"24",x"6D",x"B6",x"B6",x"B6",x"B6",x"6D",
                 --x"6D",x"B6",x"B6",x"B6",x"B6",x"B6",x"6D",x"24",x"24",x"6D",x"B6",x"B6",x"B6",x"B6",x"B6",x"6D",
                 --x"6D",x"B6",x"B6",x"B6",x"B6",x"B6",x"6D",x"24",x"24",x"6D",x"B6",x"B6",x"B6",x"B6",x"B6",x"6D",
                 --x"6D",x"B6",x"B6",x"B6",x"B6",x"6D",x"24",x"6D",x"6D",x"24",x"6D",x"B6",x"B6",x"B6",x"B6",x"6D",
                 --x"6D",x"B6",x"B6",x"B6",x"6D",x"24",x"6D",x"B6",x"B6",x"6D",x"24",x"6D",x"B6",x"B6",x"B6",x"6D",
                 --x"6D",x"B6",x"B6",x"6D",x"24",x"6D",x"B6",x"B6",x"B6",x"B6",x"6D",x"24",x"6D",x"B6",x"B6",x"6D",
                 --x"6D",x"B6",x"6D",x"24",x"6D",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"6D",x"24",x"6D",x"B6",x"6D",
                 --x"6D",x"6D",x"24",x"6D",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"6D",x"24",x"6D",x"6D",
                 --x"6D",x"24",x"6D",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"6D",x"24",x"6D",
                 --x"6D",x"6D",x"6D",x"6D",x"6D",x"6D",x"6D",x"6D",x"6D",x"6D",x"6D",x"6D",x"6D",x"6D",x"6D",x"6D",

                 x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",   -- DestructiveWall(YellowBrick)
                 x"D4",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"D4",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"D4",
                 x"D4",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"D4",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"D4",
                 x"D4",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"D4",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"D4",
                 x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",
                 x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"D4",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"D4",
                 x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"D4",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"D4",
                 x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",
                 x"FC",x"FC",x"FC",x"D4",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"D4",x"FC",x"FC",x"FC",
                 x"FC",x"FC",x"FC",x"D4",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"D4",x"FC",x"FC",x"FC",
                 x"FC",x"FC",x"FC",x"D4",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"D4",x"FC",x"FC",x"FC",
                 x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",
                 x"D4",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"D4",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",
                 x"D4",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"D4",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",
                 x"D4",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"D4",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",
                 x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",

                 x"A4",x"A4",x"A4",x"C4",x"E0",x"C4",x"E0",x"E0",x"C4",x"C4",x"E0",x"E0",x"A4",x"A4",x"E0",x"E0",   -- Explosion
                 x"A4",x"E0",x"C4",x"E0",x"E0",x"E0",x"C4",x"E0",x"E0",x"E0",x"E0",x"C4",x"E0",x"E0",x"E0",x"C4",
                 x"A4",x"E0",x"E0",x"E0",x"C4",x"C4",x"E0",x"E0",x"C4",x"E0",x"C4",x"E0",x"E0",x"E0",x"C4",x"C4",
                 x"E0",x"C4",x"E0",x"C4",x"E0",x"E8",x"E0",x"E8",x"E8",x"E8",x"E8",x"F8",x"E8",x"E0",x"E0",x"C4",
                 x"C4",x"E0",x"E0",x"E8",x"E8",x"F4",x"F8",x"F4",x"F4",x"E8",x"F4",x"E8",x"E8",x"E0",x"E8",x"E0",
                 x"C4",x"C4",x"E8",x"F8",x"FC",x"F4",x"FC",x"E8",x"FC",x"FC",x"F4",x"FC",x"F4",x"E8",x"E0",x"C4",
                 x"E0",x"E0",x"C4",x"E8",x"FC",x"F4",x"FD",x"FD",x"FD",x"FD",x"FD",x"F4",x"F4",x"E8",x"C4",x"E0",
                 x"E0",x"C4",x"C4",x"E8",x"F4",x"FC",x"FD",x"FD",x"FF",x"FF",x"FD",x"FC",x"F4",x"E8",x"E0",x"C4",
                 x"C4",x"E0",x"E8",x"F8",x"FC",x"FC",x"FD",x"FF",x"FF",x"FF",x"FC",x"FC",x"E8",x"E8",x"E0",x"C4",
                 x"E0",x"C4",x"E0",x"E8",x"F4",x"F4",x"FD",x"FD",x"FF",x"FF",x"FD",x"FC",x"F4",x"F8",x"E0",x"E0",
                 x"E0",x"C4",x"E8",x"E8",x"F4",x"FC",x"FC",x"FD",x"FD",x"FD",x"FD",x"F4",x"F4",x"E0",x"C4",x"E0",
                 x"E0",x"C4",x"C4",x"F8",x"F4",x"FC",x"F4",x"F4",x"FC",x"FC",x"F4",x"FC",x"F4",x"E8",x"E0",x"C4",
                 x"E0",x"C4",x"C4",x"E8",x"E8",x"E8",x"FC",x"FC",x"FC",x"F4",x"FC",x"F4",x"F8",x"E8",x"E0",x"E0",
                 x"E0",x"C4",x"E0",x"E8",x"E8",x"E8",x"F4",x"F4",x"E8",x"F4",x"FC",x"E8",x"E8",x"E0",x"E0",x"A4",
                 x"A4",x"E0",x"C4",x"E0",x"E8",x"E8",x"E0",x"E8",x"E8",x"E8",x"E8",x"E0",x"E0",x"E0",x"E0",x"A4",
                 x"A4",x"A4",x"A4",x"C4",x"E0",x"E0",x"E0",x"E0",x"E0",x"C4",x"E0",x"C4",x"E0",x"A4",x"A4",x"A4",

                 x"58",x"58",x"58",x"58",x"58",x"58",x"EF",x"02",x"EF",x"58",x"58",x"58",x"58",x"58",x"54",x"54",   -- Äggmök
                 x"58",x"58",x"58",x"58",x"58",x"02",x"EF",x"EF",x"EF",x"02",x"58",x"58",x"58",x"54",x"54",x"54",
                 x"58",x"58",x"58",x"58",x"0F",x"0F",x"0F",x"0F",x"0F",x"0F",x"0F",x"58",x"54",x"54",x"54",x"58",
                 x"58",x"58",x"58",x"0F",x"E0",x"0F",x"E0",x"0F",x"E0",x"0F",x"E0",x"0F",x"54",x"54",x"58",x"58",
                 x"58",x"58",x"54",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"54",x"58",x"58",x"58",
                 x"58",x"54",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"58",x"58",x"58",
                 x"54",x"54",x"FC",x"F4",x"FC",x"FC",x"FC",x"F4",x"FC",x"FC",x"FC",x"F4",x"FC",x"58",x"58",x"58",
                 x"54",x"54",x"FC",x"F4",x"FC",x"FC",x"FC",x"F4",x"FC",x"FC",x"FC",x"F4",x"FC",x"58",x"58",x"54",
                 x"54",x"58",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"58",x"54",x"54",
                 x"58",x"58",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"54",x"54",x"54",
                 x"58",x"58",x"0F",x"E0",x"0F",x"E0",x"0F",x"E0",x"0F",x"E0",x"0F",x"E0",x"0F",x"54",x"54",x"58",
                 x"58",x"58",x"58",x"0F",x"0F",x"0F",x"0F",x"0F",x"0F",x"0F",x"0F",x"0F",x"54",x"54",x"58",x"58",
                 x"58",x"58",x"54",x"54",x"EF",x"EF",x"EF",x"EF",x"EF",x"EF",x"EF",x"54",x"54",x"58",x"58",x"58",
                 x"58",x"54",x"54",x"54",x"58",x"02",x"EF",x"02",x"EF",x"02",x"54",x"54",x"58",x"58",x"58",x"58",
                 x"54",x"54",x"54",x"58",x"58",x"58",x"58",x"58",x"54",x"54",x"54",x"58",x"58",x"58",x"58",x"58",
                 x"54",x"54",x"58",x"58",x"58",x"58",x"58",x"54",x"54",x"54",x"58",x"58",x"58",x"58",x"58",x"58"
                 );                            

begin

  index <= tileIndex * 16 * 16 + tilePixelIndex;
  pixel <= memory(index);

end behavioral;
