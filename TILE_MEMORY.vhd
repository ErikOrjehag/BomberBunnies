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
               ( x"74",x"34",x"74",x"34",x"34",x"34",x"34",x"34",x"34",x"34",x"34",x"34",x"34",x"54",x"34",x"34",   -- Grass
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
                 
                 --x"49",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",-- Grå vägg
                 --x"49",x"6D",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"DA",
                 --x"49",x"6D",x"91",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"DA",x"DA",
                 --x"49",x"6D",x"91",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"DA",x"DA",
                 --x"49",x"6D",x"91",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"DA",x"DA",
                 --x"49",x"6D",x"91",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"DA",x"DA",
                 --x"49",x"6D",x"91",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"DA",x"DA",
                 --x"49",x"6D",x"91",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"DA",x"DA",
                 --x"49",x"6D",x"91",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"DA",x"DA",
                 --x"49",x"6D",x"91",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"DA",x"DA",
                 --x"49",x"6D",x"91",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"DA",x"DA",
                 --x"49",x"6D",x"91",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"DA",x"DA",
                 --x"49",x"6D",x"91",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"B6",x"DA",x"DA",
                 --x"49",x"6D",x"91",x"91",x"91",x"91",x"91",x"91",x"91",x"91",x"91",x"91",x"91",x"91",x"DA",x"DA",
                 --x"49",x"6D",x"6D",x"6D",x"6D",x"6D",x"6D",x"6D",x"6D",x"6D",x"6D",x"6D",x"6D",x"6D",x"6D",x"DA",
                 --x"49",x"49",x"49",x"49",x"49",x"49",x"49",x"49",x"49",x"49",x"49",x"49",x"49",x"49",x"49",x"49",

                 --x"88",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE", -- Gul vägg med blod
                 --x"88",x"CC",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"E0",x"FE",x"FE",x"FD",
                 --x"88",x"CC",x"F4",x"FC",x"FC",x"E4",x"FC",x"FC",x"FC",x"FC",x"E4",x"E4",x"E4",x"FC",x"FD",x"FD",
                 --x"88",x"CC",x"F4",x"FC",x"E4",x"E4",x"E4",x"FC",x"FC",x"E4",x"FC",x"E4",x"FC",x"FC",x"FD",x"FD",
                 --x"88",x"CC",x"F4",x"FC",x"E4",x"FC",x"E4",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FD",x"FD",
                 --x"88",x"CC",x"F4",x"FC",x"FC",x"FC",x"FC",x"E4",x"FC",x"FC",x"FC",x"FC",x"E4",x"FC",x"FD",x"FD",
                 --x"88",x"CC",x"F4",x"FC",x"FC",x"FC",x"FC",x"E4",x"FC",x"FC",x"E4",x"E4",x"FC",x"E4",x"FD",x"FD",
                 --x"88",x"CC",x"F4",x"FC",x"E4",x"FC",x"FC",x"E4",x"E4",x"E4",x"E4",x"FC",x"FC",x"FC",x"FD",x"FD",
                 --x"88",x"CC",x"F4",x"FC",x"FC",x"FC",x"FC",x"E4",x"E4",x"E4",x"FC",x"FC",x"FC",x"FC",x"FD",x"FD",
                 --x"88",x"CC",x"F4",x"FC",x"FC",x"E4",x"FC",x"FC",x"E4",x"E4",x"E4",x"FC",x"FC",x"FC",x"FD",x"FD",
                 --x"88",x"CC",x"F4",x"FC",x"FC",x"FC",x"FC",x"E4",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FD",x"FD",
                 --x"88",x"CC",x"F4",x"FC",x"FC",x"FC",x"E4",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FD",x"FD",
                 --x"88",x"CC",x"F4",x"FC",x"E4",x"E4",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FD",x"FD",
                 --x"88",x"CC",x"F4",x"A4",x"F4",x"F4",x"F4",x"F4",x"F4",x"F4",x"F4",x"F4",x"F4",x"F4",x"FD",x"FD",
                 --x"88",x"CC",x"CC",x"A4",x"A4",x"CC",x"CC",x"CC",x"CC",x"CC",x"CC",x"CC",x"CC",x"CC",x"CC",x"FD",
                 --x"88",x"88",x"A4",x"88",x"88",x"88",x"88",x"88",x"88",x"88",x"88",x"88",x"88",x"88",x"88",x"88",

                 x"88",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE", -- Gul vägg
                 x"88",x"CC",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",
                 x"88",x"CC",x"F4",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FE",x"FE",
                 x"88",x"CC",x"F4",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FE",x"FE",
                 x"88",x"CC",x"F4",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FE",x"FE",
                 x"88",x"CC",x"F4",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FE",x"FE",
                 x"88",x"CC",x"F4",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FE",x"FE",
                 x"88",x"CC",x"F4",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FE",x"FE",
                 x"88",x"CC",x"F4",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FE",x"FE",
                 x"88",x"CC",x"F4",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FE",x"FE",
                 x"88",x"CC",x"F4",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FE",x"FE",
                 x"88",x"CC",x"F4",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FE",x"FE",
                 x"88",x"CC",x"F4",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FE",x"FE",
                 x"88",x"CC",x"F4",x"F4",x"F4",x"F4",x"F4",x"F4",x"F4",x"F4",x"F4",x"F4",x"F4",x"F4",x"FE",x"FE",
                 x"88",x"CC",x"CC",x"CC",x"CC",x"CC",x"CC",x"CC",x"CC",x"CC",x"CC",x"CC",x"CC",x"CC",x"CC",x"FE",
                 x"88",x"88",x"88",x"88",x"88",x"88",x"88",x"88",x"88",x"88",x"88",x"88",x"88",x"88",x"88",x"88",

                 x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"D4",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"D4",   -- YellowBrick
                 x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"D4",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"D4",
                 x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"D4",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"D4",
                 x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",x"D4",
                 x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"D4",x"FC",x"FC",x"FC",x"D4",x"FC",x"FC",x"FC",x"FC",x"FC",
                 x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"D4",x"FC",x"FC",x"FC",x"D4",x"FC",x"FC",x"FC",x"FC",x"FC",
                 x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"D4",x"FC",x"FC",x"FC",x"D4",x"FC",x"FC",x"FC",x"FC",x"FC",
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

                 x"74",x"34",x"74",x"34",x"34",x"34",x"34",x"34",x"34",x"34",x"34",x"34",x"34",x"54",x"34",x"34",   -- Ägg
                 x"34",x"34",x"74",x"34",x"34",x"54",x"34",x"34",x"34",x"34",x"54",x"34",x"34",x"54",x"14",x"54",
                 x"54",x"34",x"14",x"14",x"14",x"54",x"FC",x"FC",x"FC",x"FC",x"54",x"14",x"34",x"54",x"34",x"34",
                 x"54",x"14",x"34",x"14",x"34",x"FC",x"FC",x"03",x"03",x"FC",x"FC",x"34",x"14",x"34",x"34",x"34",
                 x"34",x"14",x"14",x"34",x"03",x"03",x"03",x"03",x"03",x"03",x"03",x"03",x"74",x"34",x"34",x"54",
                 x"34",x"34",x"34",x"34",x"E0",x"03",x"E0",x"03",x"03",x"E0",x"03",x"E0",x"34",x"74",x"14",x"54",
                 x"54",x"34",x"74",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"34",x"34",x"34",
                 x"34",x"34",x"34",x"FC",x"F0",x"FC",x"FC",x"F0",x"F0",x"FC",x"FC",x"F0",x"FC",x"34",x"34",x"34",
                 x"34",x"34",x"74",x"FC",x"F0",x"FC",x"FC",x"F0",x"F0",x"FC",x"FC",x"F0",x"FC",x"74",x"34",x"34",
                 x"34",x"34",x"34",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"54",x"54",x"54",
                 x"34",x"34",x"34",x"34",x"E0",x"03",x"E0",x"03",x"03",x"E0",x"03",x"E0",x"34",x"34",x"34",x"34",
                 x"34",x"34",x"34",x"34",x"03",x"03",x"03",x"03",x"03",x"03",x"03",x"03",x"34",x"34",x"34",x"34",
                 x"54",x"34",x"54",x"34",x"34",x"FC",x"FC",x"03",x"03",x"FC",x"FC",x"34",x"34",x"34",x"54",x"54",
                 x"34",x"34",x"34",x"54",x"34",x"34",x"FC",x"FC",x"FC",x"FC",x"34",x"74",x"54",x"34",x"54",x"34",
                 x"34",x"34",x"34",x"34",x"34",x"14",x"34",x"34",x"54",x"34",x"34",x"34",x"74",x"34",x"34",x"34",
                 x"34",x"54",x"34",x"54",x"34",x"54",x"34",x"34",x"34",x"34",x"34",x"34",x"74",x"74",x"54",x"34"

                 --x"74",x"34",x"74",x"34",x"34",x"34",x"34",x"34",x"34",x"34",x"34",x"34",x"34",x"34",x"34",x"34",   -- Död kanin
                 --x"34",x"34",x"34",x"34",x"34",x"54",x"34",x"34",x"34",x"34",x"54",x"34",x"34",x"54",x"14",x"54",
                 --x"54",x"34",x"14",x"14",x"14",x"54",x"34",x"34",x"34",x"34",x"54",x"14",x"34",x"54",x"34",x"34",
                 --x"54",x"14",x"34",x"B6",x"FF",x"FF",x"34",x"34",x"34",x"34",x"FF",x"FF",x"FF",x"34",x"34",x"34",
                 --x"34",x"14",x"FF",x"FF",x"FF",x"FF",x"FF",x"34",x"34",x"FF",x"FF",x"FF",x"FF",x"B6",x"34",x"54",
                 --x"34",x"34",x"FF",x"FF",x"34",x"34",x"FF",x"FF",x"FF",x"FF",x"34",x"34",x"FF",x"FF",x"14",x"54",
                 --x"54",x"FF",x"B6",x"34",x"34",x"FF",x"FF",x"FF",x"B6",x"FF",x"FF",x"34",x"34",x"FF",x"B6",x"34",
                 --x"34",x"FF",x"34",x"34",x"FF",x"FF",x"34",x"FF",x"FF",x"34",x"FF",x"FF",x"E0",x"34",x"FF",x"34",
                 --x"34",x"34",x"74",x"E0",x"B6",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"B6",x"E0",x"74",x"34",x"34",
                 --x"34",x"34",x"E0",x"E0",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"E0",x"E0",x"54",x"E0",
                 --x"34",x"34",x"E0",x"E0",x"FF",x"FF",x"E0",x"FF",x"FF",x"E0",x"FF",x"FF",x"E0",x"E0",x"34",x"34",
                 --x"34",x"E0",x"E0",x"E0",x"E0",x"FF",x"E0",x"E0",x"E0",x"E0",x"FF",x"E0",x"E0",x"34",x"34",x"E0",
                 --x"54",x"34",x"E0",x"E0",x"E0",x"E0",x"FF",x"B6",x"FF",x"FF",x"E0",x"E0",x"34",x"34",x"54",x"54",
                 --x"34",x"34",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"34",x"54",x"34",
                 --x"34",x"34",x"34",x"34",x"E0",x"E0",x"E0",x"E0",x"E0",x"34",x"E0",x"34",x"74",x"E0",x"E0",x"34",
                 --x"E0",x"54",x"34",x"54",x"34",x"54",x"34",x"34",x"34",x"34",x"34",x"E0",x"74",x"74",x"54",x"34"

                 );                            

begin

  index <= tileIndex * 16 * 16 + tilePixelIndex;
  pixel <= memory(index);

end behavioral;
