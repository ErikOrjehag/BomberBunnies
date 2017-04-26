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

  -- Program memory
  type pm_t is array (0 to 2047) of std_logic_vector(22 downto 0);  --2047
  constant pm_c : pm_t := (
          -- OP   GRx  M     Addr
    0  => b"00101_0000_00_000000010001", -- Sleep
    1  => b"01000_1100_00_000000000000", -- Read JOY1X
    2  => b"01001_1101_00_000000000000", -- Read JOY1Y
    3  => b"00100_0000_00_000000010010", -- Jump

    16 => b"00000_0000_00_000000000001",
    17 => b"00000_0000_00_000000000111",
    18 => b"00000_0000_00_000000000000",

    others => (others => '0')
  );

  signal PM : pm_t := pm_c;


begin  -- pMem
  pData <= PM(to_integer(pAddr));

end Behavioral;


