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
  constant joy1x : std_logic_vector       := "01000";
  constant joy1y : std_logic_vector       := "01001";
  constant btn1 : std_logic_vector        := "01010";
  constant joy2x : std_logic_vector       := "01011";
  constant joy2y : std_logic_vector       := "01100";
  constant btn2 : std_logic_vector        := "01101";
  constant tileWrite : std_logic_vector   := "01110";
  constant tileRead : std_logic_vector    := "01111";
  constant tilePointer : std_logic_vector := "10000";

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
          -- OP   GRx  M     Addr
    0  => sleep & gr0  & b"00_000000010001",  -- Sleep
    1  => joy1x & gr12 & b"00_000000000000",
    4  => jump  & gr0  & b"00_000000010010",  -- Jump

    16 => b"00000_0000_00_000000000001",
    17 => b"00000_0000_00_000000000111",
    18 => b"00000_0000_00_000000000000",

    --0  => b"00101_0000_00_000000010001", -- Sleep
    --1  => b"01000_1100_00_000000000000", -- Read JOY1X
    --2  => b"01001_1101_00_000000000000", -- Read JOY1Y
    --3  => b"00100_0000_00_000000010010", -- Jump

    --16 => b"00000_0000_00_000000000001",
    --17 => b"00000_0000_00_000000000111",
    --18 => b"00000_0000_00_000000000000",

    others => (others => '0')
  );

  signal PM : pm_t := pm_c;


begin  -- pMem
  pData <= PM(to_integer(pAddr));

end Behavioral;


