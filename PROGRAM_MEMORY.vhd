library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PROGRAM_MEMORY is
  
  port (
    pAddr : in  unsigned(11 downto 0);
    pData : out std_logic_vector(22 downto 0)
    );
  
end PROGRAM_MEMORY;

architecture Behavioral of PROGRAM_MEMORY is

  -- Add names for different operations that are binary?
  -- operations
  constant load : std_logic_vector        := "00000";
  constant store : std_logic_vector       := "00001";
  constant add : std_logic_vector         := "00010";
  constant sub : std_logic_vector         := "00011";
  constant jump : std_logic_vector        := "00100";
  constant sleep : std_logic_vector       := "00101";
  constant beq : std_logic_vector         := "00110";
  constant bne : std_logic_vector         := "00111";
  constant tileWrite : std_logic_vector   := "01110";
  constant tileRead : std_logic_vector    := "01111";
  constant tilePointer : std_logic_vector := "10000";
  constant joy1r : std_logic_vector       := "10001";
  constant joy1u : std_logic_vector       := "10010";
  constant joy1l : std_logic_vector       := "10011";
  constant joy1d : std_logic_vector       := "10100";
  constant btn1 : std_logic_vector        := "10101";
  constant joy2r : std_logic_vector       := "10110";
  constant joy2u : std_logic_vector       := "10111";
  constant joy2l : std_logic_vector       := "11000";
  constant joy2d : std_logic_vector       := "11001";
  constant btn2 : std_logic_vector        := "11010";

  -- GRx
  constant gr0 : std_logic_vector  := "0000";
  constant gr1 : std_logic_vector  := "0001";
  constant gr2 : std_logic_vector  := "0010";
  constant gr3 : std_logic_vector  := "0011";
  constant gr4 : std_logic_vector  := "0100";
  constant gr5 : std_logic_vector  := "0101";
  constant gr6 : std_logic_vector  := "0110";
  constant gr7 : std_logic_vector  := "0111";
  constant gr8 : std_logic_vector  := "1000";
  constant gr9 : std_logic_vector  := "1001";
  constant gr10 : std_logic_vector := "1010";
  constant gr11 : std_logic_vector := "1011";
  constant gr12 : std_logic_vector := "1100";
  constant gr13 : std_logic_vector := "1101";
  constant gr14 : std_logic_vector := "1110";
  constant gr15 : std_logic_vector := "1111";

  -- Program memory
  type pm_t is array (0 to 2047) of std_logic_vector(22 downto 0);  --2047
  constant pm_c : pm_t := (

0 => b"00101_0000_01_000000000000", -- sleep
   1 => b"00000_0000_00_000000000001", -- 1
   2 => b"00000_0001_01_000000000000", -- load gr1
   3 => b"00000_0000_00_000000010010", -- 18
   4 => b"00000_0010_01_000000000000", -- load gr2
   5 => b"00000_0000_00_000000000100", -- 4
   6 => b"10000_0001_00_000000000000", -- tpoint gr1
   7 => b"01110_0010_00_000000000000", -- twrite gr2
   8 => b"10001_0000_01_000000000000", -- joy1r
   9 => b"00000_0000_00_000000011010",
  10 => b"10011_0000_01_000000000000", -- joy1l
  11 => b"00000_0000_00_000000100010",
  12 => b"10010_0000_01_000000000000", -- joy1u
  13 => b"00000_0000_00_000000011110",
  14 => b"10100_0000_01_000000000000", -- joy1d
  15 => b"00000_0000_00_000000100110",
  16 => b"10110_0000_01_000000000000", -- joy2r
  17 => b"00000_0000_00_000000101010",
  18 => b"11000_0000_01_000000000000", -- joy2l
  19 => b"00000_0000_00_000000110010",
  20 => b"10111_0000_01_000000000000", -- joy2u
  21 => b"00000_0000_00_000000101110",
  22 => b"11001_0000_01_000000000000", -- joy2d
  23 => b"00000_0000_00_000000110110",
  24 => b"00100_0000_01_000000000000", -- jump
  25 => b"00000_0000_00_000000001000",
  26 => b"00010_1100_01_000000000000", -- add gr12
  27 => b"00000_0000_00_000000000001", -- 1
  28 => b"00100_0000_01_000000000000", -- jump
  29 => b"00000_0000_00_000000001100",
  30 => b"00011_1101_01_000000000000", -- sub gr13
  31 => b"00000_0000_00_000000000001", -- 1
  32 => b"00100_0000_01_000000000000", -- jump
  33 => b"00000_0000_00_000000010000",
  34 => b"00011_1100_01_000000000000", -- sub gr12
  35 => b"00000_0000_00_000000000001", -- 1
  36 => b"00100_0000_01_000000000000", -- jump
  37 => b"00000_0000_00_000000001100",
  38 => b"00010_1101_01_000000000000", -- add gr13
  39 => b"00000_0000_00_000000000001", -- 1
  40 => b"00100_0000_01_000000000000", -- jump
  41 => b"00000_0000_00_000000010000",
  42 => b"00010_1110_01_000000000000", -- add gr14
  43 => b"00000_0000_00_000000000001", -- 1
  44 => b"00100_0000_01_000000000000", -- jump
  45 => b"00000_0000_00_000000010100",
  46 => b"00011_1111_01_000000000000", -- sub gr15
  47 => b"00000_0000_00_000000000001", -- 1
  48 => b"00100_0000_01_000000000000", -- jump
  49 => b"00000_0000_00_000000001000",
  50 => b"00011_1110_01_000000000000", -- sub gr14
  51 => b"00000_0000_00_000000000001", -- 1
  52 => b"00100_0000_01_000000000000", -- jump
  53 => b"00000_0000_00_000000010100",
  54 => b"00010_1111_01_000000000000", -- add gr15
  55 => b"00000_0000_00_000000000001", -- 1
  56 => b"00100_0000_01_000000000000", -- jump
  57 => b"00000_0000_00_000000001000",
    others => (others => '0')
  );

  signal PM : pm_t := pm_c;


begin  -- pMem
  pData <= PM(to_integer(pAddr));

end Behavioral;


