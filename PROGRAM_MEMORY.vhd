library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PROGRAM_MEMORY is
  
  port (
    pAddr : in  unsigned(11 downto 0);
    pData : out std_logic_vector(21 downto 0)
    );
  
end PROGRAM_MEMORY;

architecture Behavioral of PROGRAM_MEMORY is

  -- Program memory
  type pm_t is array (0 to 2047) of std_logic_vector(21 downto 0);  --2047
  constant pm_c : pm_t := (
          -- OP  GRx M     Addr
    0  => b"00010_110_01_000000000000",  -- Add +1 to GR6
    2  => b"00000_000_00_000000001001",
    3  => b"00101_000_01_000000000000",  -- Sleep
    4  => b"00000_000_00_111111111000",
    5  => b"00100_000_01_000000000000", -- Jump to 0
    6  => b"00000_000_00_000000000000",
    7  => b"00000_000_00_000000000000",
    8  => b"00000_000_00_000000000000",
    9  => b"00000_000_00_000000000000",
    10 => b"00000_000_00_000000000000",
    11 => b"00000_000_00_000000000000",
    12 => b"00000_000_00_000000000000",
    13 => b"00000_000_00_000000000000",
    14 => b"00000_000_00_000000000000",
    15 => b"00000_000_00_000000000000",
    others => (others => '0')
  );

  signal PM : pm_t := pm_c;


begin  -- pMem
  pData <= PM(to_integer(pAddr));

end Behavioral;
