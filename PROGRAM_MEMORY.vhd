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
       -- OP    GRx  M  Adr
0 => b"00101_0000_01_000000000000", -- sleep
   1 => b"00000_0000_00_000000000001", -- 1
   2 => b"00000_0001_01_000000000000", -- load, gr1
   3 => b"00000_0000_00_000000010010", -- 18
   4 => b"00000_0010_01_000000000000", -- load, gr2
   5 => b"00000_0000_00_000000000100", -- 4
   6 => b"10000_0001_00_000000000000", -- tpoint, gr1
   7 => b"01110_0010_00_000000000000", -- twrite, gr2
   8 => b"00100_0000_01_000000000000", -- jump
   9 => b"00000_0000_00_000000101010", -- CONTROL
  10 => b"00100_0000_01_000000000000", -- jump
  11 => b"00000_0000_00_000000001110", -- BUTTON
  12 => b"00100_0000_01_000000000000", -- jump
  13 => b"00000_0000_00_000000001000", -- MAIN
  14 => b"10101_0000_01_000000000000", -- btn1
  15 => b"00000_0000_00_000000010100", -- BTN1
  16 => b"11010_0000_01_000000000000", -- btn2
  17 => b"00000_0000_00_000000011110", -- BTN2
  18 => b"00100_0000_01_000000000000", -- jump
  19 => b"00000_0000_00_000000001100", -- BUTTON_R
  20 => b"00001_1100_10_000001101101", -- store, gr12, XPOS1
  21 => b"00001_1101_10_000001101110", -- store, gr13, YPOS1
  22 => b"00000_0011_00_000001101001", -- load, gr3, WALL
  23 => b"00000_0010_00_000001101100", -- load, gr2, EGG
  24 => b"01000_0011_01_000000000000", -- mul, gr3
  25 => b"00000_0000_00_000000000010", -- 2
  26 => b"10000_0011_00_000000000000", -- tpoint, gr3
  27 => b"01110_0010_00_000000000000", -- twrite, gr2
  28 => b"00100_0000_01_000000000000", -- jump
  29 => b"00000_0000_00_000000010000", -- BTN1_R
  30 => b"00001_1110_10_000001101111", -- store, gr14, XPOS2
  31 => b"00001_1111_10_000001110000", -- store, gr15, YPOS2
  32 => b"00000_0011_00_000001101001", -- load, gr3, WALL
  33 => b"00000_0010_00_000001101100", -- load, gr2, EGG
  34 => b"01000_0011_01_000000000000", -- mul, gr3
  35 => b"00000_0000_00_000000000010", -- 2
  36 => b"00010_0011_00_000001101111", -- add, gr3, XPOS2
  37 => b"10000_0011_00_000000000000", -- tpoint, gr3
  38 => b"01110_0010_00_000000000000", -- twrite, gr2
  39 => b"00100_0000_01_000000000000", -- jump
  40 => b"00000_0000_00_000000010010", -- BTN2_R
  41 => b"00000_0000_00_000000000000", -- 0
  42 => b"10001_0000_01_000000000000", -- joy1r
  43 => b"00000_0000_00_000000111100", -- P1R
  44 => b"10011_0000_01_000000000000", -- joy1l
  45 => b"00000_0000_00_000001010001", -- P1L
  46 => b"10010_0000_01_000000000000", -- joy1u
  47 => b"00000_0000_00_000001001110", -- P1U
  48 => b"10100_0000_01_000000000000", -- joy1d
  49 => b"00000_0000_00_000001010101", -- P1D
  50 => b"10110_0000_01_000000000000", -- joy2r
  51 => b"00000_0000_00_000001011000", -- P2R
  52 => b"11000_0000_01_000000000000", -- joy2l
  53 => b"00000_0000_00_000001100000", -- P2L
  54 => b"10111_0000_01_000000000000", -- joy2u
  55 => b"00000_0000_00_000001011100", -- P2U
  56 => b"11001_0000_01_000000000000", -- joy2d
  57 => b"00000_0000_00_000001100100", -- P2D
  58 => b"00100_0000_01_000000000000", -- jump
  59 => b"00000_0000_00_000000001010", -- CONTROL_R
  60 => b"00001_1101_10_000001110001", -- store, gr13, MOVE
  61 => b"00000_0010_00_000001110001", -- load, gr2, MOVE
  62 => b"00001_1100_10_000001110001", -- store, gr12, MOVE
  63 => b"01000_0010_01_000000000000", -- mul, gr2
  64 => b"00000_0000_00_000000001111", -- 15
  65 => b"00010_0010_00_000001110001", -- add, gr2, MOVE
  66 => b"00010_0010_01_000000000000", -- add, gr2
  67 => b"00000_0000_00_000000000001", -- 1
  68 => b"10000_0010_00_000000000000", -- tpoint, gr2
  69 => b"01111_0011_00_000000000000", -- tread, gr3
  70 => b"00011_0011_01_000000000000", -- sub, gr3
  71 => b"00000_0000_00_000000000000", -- 0
  72 => b"00111_0000_01_000000000000", -- bne
  73 => b"00000_0000_00_000000101110", -- J1
  74 => b"00010_1100_01_000000000000", -- add, gr12
  75 => b"00000_0000_00_000000000001", -- 1
  76 => b"00100_0000_01_000000000000", -- jump
  77 => b"00000_0000_00_000000101110", -- J1
  78 => b"00011_1101_00_000001101001", -- sub, gr13, WALL
  79 => b"00100_0000_01_000000000000", -- jump
  80 => b"00000_0000_00_000000110010", -- J2
  81 => b"00011_1100_01_000000000000", -- sub, gr12
  82 => b"00000_0000_00_000000000001", -- 1
  83 => b"00100_0000_01_000000000000", -- jump
  84 => b"00000_0000_00_000000101110", -- J1
  85 => b"00010_1101_00_000001101001", -- add, gr13, WALL
  86 => b"00100_0000_01_000000000000", -- jump
  87 => b"00000_0000_00_000000110010", -- J2
  88 => b"00010_1110_01_000000000000", -- add, gr14
  89 => b"00000_0000_00_000000000001", -- 1
  90 => b"00100_0000_01_000000000000", -- jump
  91 => b"00000_0000_00_000000110110", -- J3
  92 => b"00011_1111_01_000000000000", -- sub, gr15
  93 => b"00000_0000_00_000000000001", -- 1
  94 => b"00100_0000_01_000000000000", -- jump
  95 => b"00000_0000_00_000000001010", -- CONTROL_R
  96 => b"00011_1110_01_000000000000", -- sub, gr14
  97 => b"00000_0000_00_000000000001", -- 1
  98 => b"00100_0000_01_000000000000", -- jump
  99 => b"00000_0000_00_000000110110", -- J3
 100 => b"00010_1111_01_000000000000", -- add, gr15
 101 => b"00000_0000_00_000000000001", -- 1
 102 => b"00100_0000_01_000000000000", -- jump
 103 => b"00000_0000_00_000000001010", -- CONTROL_R
 104 => b"00000_0000_00_000000000000", -- 0
 105 => b"00000_0000_00_000000000001", -- 1
 106 => b"00000_0000_00_000000000010", -- 2
 107 => b"00000_0000_00_000000000011", -- 3
 108 => b"00000_0000_00_000000000100", -- 4
 109 => b"00000_0000_00_000000000000", -- 0
 110 => b"00000_0000_00_000000000000", -- 0
 111 => b"00000_0000_00_000000000000", -- 0
 112 => b"00000_0000_00_000000000000", -- 0
 113 => b"00000_0000_00_000000000000", -- 0
 114 => b"00000_0000_00_000000000000", -- 0
 115 => b"00000_0000_00_000000000000", -- 0





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


