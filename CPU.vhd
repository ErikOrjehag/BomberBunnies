-------------------------------------------------------------------------------
-- CPU
-------------------------------------------------------------------------------
-- Rolf Sievert
-- Erik �rjehag
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
    p1x         : out std_logic_vector(9 downto 0);
    p1y         : out std_logic_vector(9 downto 0);
    p2x         : out std_logic_vector(9 downto 0);
    p2y         : out std_logic_vector(9 downto 0);
  );
end CPU;

-- architecture
architecture behavioral of CPU is

  -- Bus
  signal buss : std_logic_vector(21 downto 0) := (others => '0');
  
  -- Program memory
  type pm_t is array (0 to 4095) of std_logic_vector(21 downto 0);
  signal PM : pm_t := (
    -- OP  GRx M     Addr
    "00000 100 00 000010001011",
    "00000 101 00 000010000000",
    "00000 110 00 000000100000",
    "00000 111 00 000000100000",
    "00000 000 00 000000000000",
    "00000 000 00 000000000000",
    "00000 000 00 000000000000",
    "00000 000 00 000000000000",
    "00000 000 00 000000000000",
    "00000 000 00 000000000000",
    "00000 000 00 000000000000",
    "00000 000 00 000000000000"
  );

  -- Micro memory
  type upm_t is array (0 to 511) of std_logic_vector(28 downto 0);
  signal uPM : upm_t := (
    -- AR 0110
 --  ALU   TB   FB  S P LC  SEQ  uADR
    "0000 0100 0001 0 0 00 0000 000000000",  -- H�mtfas
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
  type grx_t is array (0 to 7) of std_logic_vector(21 downto 0);
  signal GRx : grx_t := (
    "0000000000000000000000",
    "0000000000000000000000",
    "0000000000000000000000",
    "0000000000000000000000",
    "0000000000000000000000",
    "0000000000000000000000",
    "0000000000000000000000",
    "0000000000000000000000"
  );
  signal GRx_x  : std_logic_vector(2 downto 0);

  -- k1
  type k1_t is array (0 to 31) of std_logic_vector(9 downto 0);
  signal k1 : k1_t := (
    
    "0000000011",                       -- (00) Direktadressering (rad 003)
    "0000000100",                       -- (01) Immediate (rad 004)
    "0000000101",                       -- (10) Indirekt adressering (rad 005)
    "0000000111"                        -- (11) Indexerad adressering (rad 007)
);

  -- k2
  type k2_t is array (0 to 3) of std_logic_vector(9 downto 0);
  signal k2 : k2_t := (

    "0000001010",                       -- (0000) LOAD (rad 00A)
    "0000001011",                       -- (0001) STORE (rad 00B)
    "0000001100",                       -- (0010) ADD (rad 00C)
    "0000001111",                       -- (0011) SUB (rad 00F)
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
  signal LC : std_logic_vector(8 downto 0) := (others => '0');  --fit uAddr
  signal uPC : std_logic_vector(9 downto 0) := (others => '0');

  -- Flags
  signal O : std_logic := '0';
  signal C : std_logic := '0';
  signal N : std_logic := '0';
  signal Z : std_logic := '0';
  signal L : std_logic := '0';

begin  -- behavioral

  -- Player positions
  p1x <= GRx(4)(9 downto 0);
  p1y <= GRx(5)(9 downto 0);
  p2x <= GRx(6)(9 downto 0);
  p2y <= GRx(7)(9 downto 0);

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
  
  buss <= buss                         when tb = "0000" else (others => 'Z');
  buss <= ASR                          when tb = "0001" else (others => 'Z');
  buss <= IR                           when tb = "0010" else (others => 'Z');
  buss <= PM(to_unsigned(ASR))         when tb = "0011" else (others => 'Z');
  buss <= PC                           when tb = "0100" else (others => 'Z');
  buss <= GRx(to_unsigned(GRx_x))      when tb = "0101" else (others => 'Z');
  buss <= AR                           when tb = "0110" else (others => 'Z');
  buss <= buss                         when tb = "0111" else (others => 'Z');  --ledig
  buss <= x"000" & "00" & tileIndex    when tb = "1000" else (others => 'Z');
  buss <= x"000" & "00" & tilePointer  when tb = "1001" else (others => 'Z');
  buss <= x"00000" & joy1x             when tb = "1010" else (others => 'Z');
  buss <= x"00000" & joy1y             when tb = "1011" else (others => 'Z');
  buss <= x"00000" & "0" & btn1        when tb = "1100" else (others => 'Z');
  buss <= x"00000" & joy2x             when tb = "1101" else (others => 'Z');
  buss <= x"00000" & joy2y             when tb = "1110" else (others => 'Z');
  buss <= x"00000" & "0" & btn1        when tb = "1111" else (others => 'Z');

  -- FB
  process(clk)
  begin
    if rising_edge(clk) then
      case upm_fb is
        when "0000" => null;
        when "0001" => ASR <= buss(11 downto 0);
        when "0010" => IR <= buss;
        when "0011" => PM(to_unsigned(ASR)) <= buss;
        when "0100" => PC <= buss(11 downto 0);
        when "0101" => GRx(to_unsigned(GRx_x)) <= buss;
        when "0110" => null;            --AR
        when "0111" => null;            --ledig
        when "1000" => tileIndex <= buss(7 downto 0);
        when "1001" => tilePointer <= buss(7 downto 0);
        when "1010" => null;            --joy1x
        when "1011" => null;            --joy1y
        when "1100" => null;            --btn1
        when "1101" => null;            --joy2x
        when "1110" => null;            --joy2y
        when "1111" => null;            --btn2
        when others => null;
      end case;
    end if;
  end process;

  -- ALU
  process(clk)
  begin
    if rising_edge(clk) then
      case upm_alu is
        when "0000" => null;            --noop
        when "0001" => AR <= buss;
        when "0010" => AR <= not buss;
        when "0011" => AR <= (others => '0');
        when "0100" => AR <= AR + buss;
        when "0101" => AR <= AR - buss;
        when "0110" => AR <= AR and buss;
        when "0111" => AR <= AR or buss;
        when "1000" => AR <= AR + buss;  --no flags
        when "1001" => AR <= AR sll 1;
        when "1010" => null;            --ledig
        when "1011" => null;            --ledig
        when "1100" => null;            --ledig
        when "1101" => AR <= AR srl 1;
        when "1110" =>  null;           --ledig
        when "1111" =>  null;           --ledig
        when others => null;
      end case;

      if upm_alu != "1000" then
        O <= '0';
        C <= '0';
        N <= AR(21);
        Z <= AR = (x"00000" & "00");
        L <= '0';
      end if;
    end if;
  end process;
  
  -- P
  process(clk)
  begin
    if rising_edge(clk) then
      case upm_p is
        when "0" => null;
        when "1" => PC = PC + 1;
        when others => null;
      end case;
    end if;
  end process;

  -- LC
  process(clk)
  begin
    if rising_edge(clk) then
      case upm_lc is
        when "00" => null;
        when "01" => LC <= LC - 1;
        when "10" => LC <= "0" & buss(7 downto 0);
        when "11" => LC <= upm_uaddr;
        when others => null;
      end case;
    end if;
  end process;

  -- SEQ
  process(clk)
  begin
    if rising_edge(clk) then
      case upm_seq is
        when "0000" => uPC <= uPC + 1;
        when "0001" => uPC <= k1(ir_m);
        when "0010" => uPC <= k2(ir_m;
        when "0011" => uPC <= (others => '0');
        when "0100" => uPC <= upm_uaddr;
        when "0101" => null;            --ledig
        when "0110" => null;            --ledig
        when "0111" => null;            --ledig
        when "1000" => uPC <= upm_uaddr when Z = '1' else uPC;
        when "1001" => uPC <= upm_uaddr when N = '1' else uPC;
        when "1010" => uPC <= upm_uaddr when C = '1' else uPC;
        when "1011" => uPC <= upm_uaddr when O = '1' else uPC;
        when "1100" => uPC <= upm_uaddr when L = '1' else uPC;
        when "1101" => null;            --ledig
        when "1110" => null;            --ledig
        when "1111" => null;            -- HALT
        when others => null;
      end case;
    end if;
  end process;

end behavioral;
