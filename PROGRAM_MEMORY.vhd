library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PROGRAM_MEMORY is
  
  port (
    clk : in std_logic;
    pAddr : in  unsigned(11 downto 0);
    PM_out : out std_logic_vector(22 downto 0);
    PM_in : in std_logic_vector(22 downto 0);
    PM_write : in std_logic
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

   0 => b"00000_0000_01_000000000000", -- load, gr0
   1 => b"00000_0000_00_000000000000", -- 0
   2 => b"00010_0000_01_000000000000", -- add, gr0
   3 => b"00000_0000_00_000000000001", -- 1
   4 => b"00001_0000_10_000000001000", -- store, gr0, DATA
   5 => b"00000_1101_00_000000001000", -- load, gr13, DATA
   6 => b"00100_0000_01_000000000000", -- jump
   7 => b"00000_0000_00_000000000010", -- LOOP
   8 => b"00000_0000_00_000000000000", -- 0

   
    others => (others => '0')
  );

  signal PM : pm_t := pm_c;


begin  -- pMem

  PM_out <= PM(to_integer(pAddr));

  process (clk)
  begin
    if rising_edge(clk) then
      if PM_write = '1' then
        PM(to_integer(pAddr)) <= PM_in;
      end if;
    end if;
  end process;
  
 -- PM(to_integer(pAddr)) <= PM_in when PM_write = '1' else PM(to_integer(pAddr));

end Behavioral;


