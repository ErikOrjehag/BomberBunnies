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
    0  => b"00010_110_00_000000010000", -- Add +1 to GR6
    3  => b"00101_000_00_000000010001", -- Sleep
    5  => b"00100_000_00_000000010010", -- Jump to 0

    16 => b"00000_000_00_000000000000",
    17 => b"00000_000_00_111111111000",
    18 => b"00000_000_00_000000000000",

    others => (others => '0')
  );

  signal PM : pm_t := pm_c;


begin  -- pMem
  pData <= PM(to_integer(pAddr));

end Behavioral;
