-------------------------------------------------------------------------------
-- CPU
-------------------------------------------------------------------------------
-- Rolf Sievert
-- Erik Örjehag
-- Gustav Svennas
-------------------------------------------------------------------------------


-- library declaration
library IEEE;                           -- basic IEEE library
use IEEE.STD_LOGIC_1164.ALL;            -- IEEE library for the unsigned type
use IEEE.NUMERIC_STD.ALL;               -- and various arithmetic operations


-- entity
entity CPU is
  port (
    clk         : in std_logic;                      -- system clock (100 MHz)
    rst	        : in std_logic;
    tilePointer : buffer std_logic_vector(7 downto 0) := (others => '0');
    tileIndex   : buffer std_logic_vector(7 downto 0);
    readTile    : out std_logic;
    writeTile   : out std_logic;
    joy1x       : in std_logic_vector(1 downto 0) := (others => '0');
    joy1y       : in std_logic_vector(1 downto 0) := (others => '0');
    btn1        : in std_logic;
    joy2x       : in std_logic_vector(1 downto 0) := (others => '0');
    joy2y       : in std_logic_vector(1 downto 0) := (others => '0');
    btn2        : in std_logic;
    p1x         : out std_logic_vector(7 downto 0);
    p1y         : out std_logic_vector(7 downto 0);
    p2x         : out std_logic_vector(7 downto 0);
    p2y         : out std_logic_vector(7 downto 0);
  );
end CPU;

-- architecture
architecture behavioral of CPU is

  -- Bus
  signal buss : std_logic_vector(21 downto 0) := (others => '0');
  
  -- Program memory
  type pm_t is array (0 to 4095) of std_logic_vector(21 downto 0);
  signal PM : pm_t;

  -- Micro memory
  type upm_t is array (0 to 511) of std_logic_vector(28 downto 0);
  signal uPM : upm_t;

  -- GRx
  type grx_t is array (0 to 15) of std_logic_vector(21 downto 0);
  signal GRx : grx_t;

  -- k1
  type k1_t is array (0 to 31) of std_logic_vector(9 downto 0);
  signal k1 : k1_t;

  -- k2
  type k2_t is array (0 to 3) of std_logic_vector(9 downto 0);
  signal k2 : k2_t;
  
  -- Registers
  signal IR : std_logic_vector(21 downto 0) := (others => '0');
  signal AR : std_logic_vector(21 downto 0) := (others => '0');
  signal PC : std_logic_vector(11 downto 0) := (others => '0');
  signal ASR : std_logic_vector(11 downto 0) := (others => '0');
  signal LC : std_logic_vector(7 downto 0) := (others => '0');
  signal uPC : std_logic_vector(9 downto 0) := (others => '0');
  signal O : std_logic := '0';
  signal C : std_logic := '0';
  signal N : std_logic := '0';
  signal Z : std_logic := '0';
  signal L : std_logic := '0';

begin  -- behavioral

  -- Player positions
  p1x <= GRx(12);
  p1y <= GRx(13);
  p2x <= GRx(14);
  p2y <= GRx(15);

  process(clk)
  begin
    if rising_edge(clk) then

      -- TB
      case uPM(24 downto 21) is
        when "0001" => buss <= "0000000000" & ASR;
        when "0010" => buss <= IR;
        when "0011" => buss <= PM(to_unsigned(ASR));
        when "0100" => buss <= "0000000000" & PC;
        when "0101" => buss <= GRx(to_unsigned(IR(16 downto 14) when uPM(uPC)(16) = '1' else IR(13 downto 12)));  -- GRx(IR(GRx/M))
        when "0110" => null;
        when "0111" => null;
        when "1000" => buss <= "00000000000000" & tileIndex;
        when "1001" => buss <= "00000000000000" & tilePointer;
        when "1010" => buss <= "00000000000000000000" & joy1x;
        when "1011" => buss <= "00000000000000000000" & joy1y;
        when "1100" => buss <= "000000000000000000000" & btn1;
        when "1101" => buss <= "00000000000000000000" & joy2x;
        when "1110" => buss <= "00000000000000000000" & joy2y;
        when "1111" => buss <= "000000000000000000000" & btn1;
        when others => null;
      end case;

      -- FB
      case uPM(20 downto 17) is
        when "0001" => ASR <= buss(11 downto 0);
        when "0010" => IR <= buss;
        when "0011" => PM(to_unsigned(ASR)) <= buss;
        when "0100" => PC <= buss(11 downto 0);
        when "0101" => GRx(to_unsigned(IR(16 downto 14) when uPM(uPC)(16) = '1' else IR(13 downto 12))) <= buss;  -- GRx(IR(GRx/M))
        when "0110" => null;
        when "0111" => null;
        when "1000" => tileIndex <= buss(7 downto 0);
        when "1001" => tilePointer <= buss(7 downto 0);
        when "1010" => null;
        when "1011" => null;
        when "1100" => null;
        when "1101" => null;
        when "1110" => null;
        when "1111" => null;
        when others => null;
      end case;

      -- P
      if uPM(uPC)(15) = '1' then
        PC = PC + 1;
      end if;

      -- LC
      case uPM(uPC)(14 downto 13) is
        when "01" => LC <= LC - 1;
        when "10" => LC <= buss(7 downto 0);
        when "11" => LC <= uPC(8 downto 0);  -- uAddr
        when others => null;
      end case;

      -- SEQ
      case uPM(uPC)(12 downto 9) is
        when "0000" => uPC = uPC + 1;
--        when "0001" => uPC = ;          -- k1...
      end case;

    end if;

  end process;
  

end behavioral;
