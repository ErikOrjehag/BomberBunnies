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
  signal uPM : upm_t := (
    -- AR 0110
 --  ALU   TB   FB  S P LC  SEQ  uADR
    "0000 0100 0001 0 0 00 0000 000000000",  -- Hämtfas
    "0000 0011 0010 0 1 00 0000 000000000",
    
    "0000 0000 0000 0 0 00 0010 000000000",  -- Start
    
    "0000 0010 0001 0 0 00 0001 000000000",  -- Direktadressering
    
    "0000 0100 0001 0 1 00 0001 000000000",  -- Immediate
    
    "0000 0010 0001 0 0 00 0000 000000000",  -- Indirekt adressering
    "0000 0011 0001 0 0 00 0001 000000000",
    
    "0000 0110 0000 0 0 00 0000 000000000",  -- Indexerad adressering
    "1000 0101 0000 0 0 00 0000 000000000",
    "0000 0110 0001 0 0 00 0001 000000000",
    
    
    "0000 0011 0101 0 0 00 0011 000000000",  -- LOAD (GRx, M, ADR)
    
    "0000 0101 0011 0 0 00 0011 000000000",  -- STORE (GRx, M, ADR)
    
    "0001 0101 0000 0 0 00 0000 000000000",  -- ADD (GRx, M, ADR)
    "0100 0011 0000 0 0 00 0000 000000000",
    "0000 0110 0101 0 0 00 0011 000000000",
    
    "0001 0101 0000 0 0 00 0000 000000000",  -- SUB (GRx, M, ADR)
    "0101 0011 0000 0 0 00 0000 000000000",
    "0000 0110 0101 0 0 00 0011 000000000"
    
  );

  -- GRx
  type grx_t is array (0 to 15) of std_logic_vector(21 downto 0);
  signal GRx : grx_t;
  signal GRx_x  : std_logic_vector(2 downto 0);

  -- k1
  type k1_t is array (0 to 31) of std_logic_vector(9 downto 0);
  signal k1 : k1_t := (
    
    "0000000011",                       -- Direktadressering (rad 003)
    "0000000100",                       -- Immediate (rad 004)
    "0000000101",                       -- Indirekt adressering (rad 005)
    "0000000111"                        -- Indexerad adressering (rad 007)
);

  -- k2
  type k2_t is array (0 to 3) of std_logic_vector(9 downto 0);
  signal k2 : k2_t := (

    "0000001010",                       -- LOAD (rad 00A)
    "0000001011",                       -- STORE (rad 00B)
    "0000001100",                       -- ADD (rad 00C)
    "0000001111",                       -- SUB (rad 00F)
    "0000000000",
    "0000000000",
    "0000000000",
    "0000000000",
    "0000000000",
    "0000000000",
    "0000000000",
    "0000000000",
    "0000000000",
    "0000000000",
    "0000000000",
    "0000000000"
);

  -- uPM signals
  signal upm_instr : std_logic_vector(28 downto 0);
  
  signal upm_alu : std_logic_vector(3 downto 0);
  signal upm_tb : std_logic_vector(3 downto 0);
  signal upm_fb : std_logic_vector(3 downto 0);
  signal upm_s : std_logic_vector(0 downto 0);
  signal upm_p : std_logic_vector(0 downto 0);
  signal upm_lc : std_logic_vector(1 downto 0);
  signal upm_seq : std_logic_vector(3 downto 0);
  signal upm_uaddr : std_logic_vector(8 downto 0);

  -- IR signals
  signal ir_addr : std_logic_vector(11 downto 0);
  signal ir_m : std_logic_vector(1 downto 0);
  signal ir_grx : std_logic_vector(2 downto 0);
  signal ir_op : std_logic_vector(4 downto 0);
  
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

  -- uPM signals
  upm_instr <= uPM(uPC);
  
  upm_alu   <= upm_instr(28 downto 25);
  upm_tb    <= upm_instr(24 downto 21);
  upm_fb    <= upm_instr(20 downto 17);
  upm_s     <= upm_instr(16 downto 16);
  upm_p     <= upm_instr(15 downto 15);
  upm_lc    <= upm_instr(14 downto 13);
  upm_seq   <= upm_instr(12 downto 9);
  upm_uaddr <= upm_instr(8  downto 0);
  
  -- IR signals
  ir_addr   <= IR(11 downto 0);
  ir_m      <= IR(13 downto 12);
  ir_grx    <= IR(16 downto 14);
  ir_op     <= IR(21 downto 17);
  
  -- TB
  GRx_x <= ir_grx when upm_s = '1' else "0" & ir_m;
  
  buss <= buss                    when tb = "0000" else (others => 'Z');
  buss <= PM(to_unsigned(ASR))    when tb = "0001" else (others => 'Z');
  buss <= IR                      when tb = "0010" else (others => 'Z');
  buss <= "0000000000" & PC       when tb = "0011" else (others => 'Z');
  buss <= AR                      when tb = "0100" else (others => 'Z');
  buss <= buss                           when tb = "0101" else (others => 'Z');  --ledig
  buss <= GRx(to_unsigned(GRx_x))        when tb = "0110" else (others => 'Z');
  buss <= buss                           when tb = "0111" else (others => 'Z');  --ledig
  buss <= x"000" & "00" & tileIndex      when tb = "1000" else (others => 'Z');
  buss <= x"000" & "00" & tilePointer    when tb = "1001" else (others => 'Z');
  buss <= x"00000" & joy1x when tb = "1010" else (others => 'Z');
  buss <= x"00000" & joy1y when tb = "1011" else (others => 'Z');
  buss <= "000000000000000000000" & btn1 when tb = "1100" else (others => 'Z');
  buss <= "00000000000000000000" & joy2x when tb = "1101" else (others => 'Z');
  buss <= "00000000000000000000" & joy2y when tb = "1110" else (others => 'Z');
  buss <= "000000000000000000000" & btn1 when tb = "1111" else (others => 'Z');
  
  
  process(clk)
  begin

    -- TB
    case uPM(24 downto 21) is
      when "0000" => null;
      when "0001" => ;
      when "0010" => ;
      when "0011" => ;
      when "0100" => ;
      when "0101" => null;
      when "0110" => buss <= GRx(to_unsigned(IR(16 downto 14) when uPM(uPC)(16) = '1' else IR(13 downto 12)));  -- GRx(IR(GRx/M))------(S-flag)
      when "0111" => null;
      when "1000" => buss ;
      when "1001" => 
      when "1010" => ;
      when "1011" => buss <= ;
      when "1100" => buss <= ;
      when "1101" => buss <= ;
      when "1110" => buss <= ;
      when "1111" => buss <= ;
      when others => null;
    end case;


    
    if rising_edge(clk) then
      -- FB
      case uPM(20 downto 17) is
        when "0001" => ASR <= buss(11 downto 0);
        when "0010" => IR <= buss;
        when "0011" => PM(to_unsigned(ASR)) <= buss;
        when "0100" => PC <= buss(11 downto 0);
        when "0101" => GRx(to_unsigned(IR(16 downto 14) when uPM(uPC)(16) = '1' else IR(13 downto 12))) <= buss;  -- GRx(IR(GRx/M))------(S-flag)
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

      -- ALU
      case uPM(uPC)(28 downto 25) is
        when "0000" => null;
        when "0001" => AR <= buss;
        when "0010" => AR <= not buss;
        when "0011" => AR <= (others => '0');
        when "0100" => AR <= AR + buss;
        when "0101" => AR <= AR - buss;
        when "0110" => null;
        when "0111" => null;
        when "1000" => null;
        when "1001" => null;
        when "1010" => null;
        when "1011" => null;
        when "1100" => null;
        when "1101" => null;
        when "1110" => null;
        when "1111" => null;
        when others => null;
      end case;
      
      -- P
      case uPM(uPC)(15) is
        when "0" => null;
        when "1" => PC = PC + 1;
        when others => null;
      end if;

      -- LC
      case uPM(uPC)(14 downto 13) is
        when "00" => null;
        when "01" => LC <= LC - 1;
        when "10" => LC <= buss(7 downto 0);
        when "11" => LC <= uPC(8 downto 0);  -- uAddr
        when others => null;
      end case;

      -- SEQ
      case uPM(uPC)(12 downto 9) is
        when "0000" => uPC = uPC + 1;
--        when "0001" => uPC = ;          -- k1...
        when others => null;
      end case;

    end if;

  end process;
  

end behavioral;
