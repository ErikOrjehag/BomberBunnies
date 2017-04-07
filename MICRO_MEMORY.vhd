library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

-- uMem interface
entity MICRO_MEMORY is
  port (
    uAddr : in unsigned(8 downto 0);
    uData : out std_logic_vector(28 downto 0));
end MICRO_MEMORY;

architecture Behavioral of MICRO_MEMORY is

-- micro Memory
type u_mem_t is array (0 to 511) of std_logic_vector(28 downto 0);
constant u_mem_c : u_mem_t := (
  -- AR 0110
       --  ALU   TB   FB  S P LC  SEQ  uADR
    0 => b"0000_0100_0001_0_0_00_0000_000000000",  -- H�mtfas
    1 => b"0000_0011_0010_0_1_00_0000_000000000",
    
    2 => b"0000_0000_0000_0_0_00_0010_000000000",  -- Start
    
    3 => b"0000_0010_0001_0_0_00_0001_000000000",  -- Direktadressering
    
    4 => b"0000_0100_0001_0_1_00_0001_000000000",  -- Immediate
    
    5 => b"0000_0010_0001_0_0_00_0000_000000000",  -- Indirekt adressering
    6 => b"0000_0011_0001_0_0_00_0001_000000000",
    
    7 => b"0000_0110_0000_0_0_00_0000_000000000",  -- Indexerad adressering
    8 => b"1000_0101_0000_0_0_00_0000_000000000",
    9 => b"0000_0110_0001_0_0_00_0001_000000000",
    
    
    10 => b"0000_0011_0101_0_0_00_0011_000000000",  -- LOAD (GRx, M, ADR)
    
    11 => b"0000_0101_0011_0_0_00_0011_000000000",  -- STORE (GRx, M, ADR)
    
    12 => b"0001_0101_0000_0_0_00_0000_000000000",  -- ADD (GRx, M, ADR)
    13 => b"0100_0011_0000_0_0_00_0000_000000000",
    14 => b"0000_0110_0101_0_0_00_0011_000000000",
    
    15 => b"0001_0101_0000_0_0_00_0000_000000000",  -- SUB (GRx, M, ADR)
    16 => b"0101_0011_0000_0_0_00_0000_000000000",
    17 => b"0000_0110_0101_0_0_00_0011_000000000",
    others => (others => '0')
  );

signal uMem : u_mem_t := u_mem_c;

begin  -- Behavioral
  uData <= uMem(to_integer(uAddr));

end Behavioral;
