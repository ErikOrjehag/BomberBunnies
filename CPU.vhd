-------------------------------------------------------------------------------
-- CPU
-------------------------------------------------------------------------------
-- Rolf Sievert
-- Erik Örjehag
-- Gustav Svennas
-------------------------------------------------------------------------------


-- FIX WRITING TO PM FROM BOTH BUS AND PROGRAM_MEMORY!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


-- library declaration
library IEEE;                           -- basic IEEE library
use IEEE.STD_LOGIC_1164.ALL;            -- IEEE library for the unsigned type
use IEEE.NUMERIC_STD.ALL;               -- and various arithmetic operations


-- entity
entity CPU is
  port (
    clk                 : in std_logic;                      -- system clock (100 MHz)
    rst	                : in std_logic;
    joy1x               : in std_logic_vector(1 downto 0) := (others => '0');
    joy1y               : in std_logic_vector(1 downto 0) := (others => '0');
    btn1                : in std_logic;
    joy2x               : in std_logic_vector(1 downto 0) := (others => '0');
    joy2y               : in std_logic_vector(1 downto 0) := (others => '0');
    btn2                : in std_logic;
    tilePointer         : buffer std_logic_vector(7 downto 0) := (others => '0');
    tileTypeRead        : in std_logic_vector(7 downto 0);
    tileTypeWrite       : out std_logic_vector(7 downto 0);
    readMap             : out std_logic;
    writeMap            : out std_logic;
    p1x                 : out std_logic_vector(9 downto 0);
    p1y                 : out std_logic_vector(9 downto 0);
    p2x                 : out std_logic_vector(9 downto 0);
    p2y                 : out std_logic_vector(9 downto 0)
  );
end CPU;

-- architecture
architecture behavioral of CPU is

  -- program memory component
  component PROGRAM_MEMORY
    port (
      pAddr : in  unsigned(11 downto 0);
      pData : inout std_logic_vector(21 downto 0));
  end component;

  -- Micro memory component
  component MICRO_MEMORY
    port (
      uAddr : in  unsigned(8 downto 0);
      uData : out std_logic_vector(28 downto 0));
  end component;

  signal PM : std_logic_vector(21 downto 0);
  signal uPM : std_logic_vector(28 downto 0);

  -- Bus
  signal buss : std_logic_vector(21 downto 0) := (others => '0');

  -- GRx
  type grx_t is array (0 to 7) of std_logic_vector(21 downto 0);
  signal GRx : grx_t := (
    "0000000000000000000000",
    "0000000000000000000000",
    "0000000000000000000000",
    "0000000000000000000000",
    "0000000000000000000000",
    "0000000000000000000000",
    "0000000000000000001000",
    "0000000000000000001100"
  );
  signal GRx_x  : integer := 0;

  -- k2
  type k2_t is array (0 to 3) of std_logic_vector(8 downto 0);
  signal k2 : k2_t := (
    
    "000000011",                       -- (00) Direktadressering (rad 003)
    "000000100",                       -- (01) Immediate (rad 004)
    "000000101",                       -- (10) Indirekt adressering (rad 005)
    "000000111"                        -- (11) Indexerad adressering (rad 007)
);

  -- k1
  type k1_t is array (0 to 15) of std_logic_vector(8 downto 0);  --31
  signal k1 : k1_t := (

    "000001010",                       -- (0000) LOAD (rad 00A)
    "000001011",                       -- (0001) STORE (rad 00B)
    "000001100",                       -- (0010) ADD (rad 00C)
    "000001111",                       -- (0011) SUB (rad 00F)
    "000000000",
    "000000000",
    "000000000",
    "000000000",
    "000000000",
    "000000000",
    "000000000",
    "000000000",
    "000000000",
    "000000000",
    "000000000",
    "000000000"
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
  signal ASR : unsigned(11 downto 0) := (others => '0');
  signal LC : std_logic_vector(8 downto 0) := (others => '0');  --fit uAddr
  signal uPC : unsigned(8 downto 0) := (others => '0');

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
  upm_instr <= uPM;
  
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
  GRx_x <= to_integer(unsigned(ir_grx)) when (upm_s = "1") else to_integer(unsigned(ir_m));

  -- select when?
  buss <= buss                                  when upm_tb = "0000" else (others => 'Z');
  buss <= "0000000000" & std_logic_vector(ASR)  when upm_tb = "0001" else (others => 'Z');
  buss <= IR                                    when upm_tb = "0010" else (others => 'Z');
  --buss <= PM                                    when upm_tb = "0011" else (others => 'Z');
  buss <= "0000000000" & PC                     when upm_tb = "0100" else (others => 'Z');
  buss <= GRx(GRx_x)                            when upm_tb = "0101" else (others => 'Z');
  buss <= AR                                    when upm_tb = "0110" else (others => 'Z');
  buss <= buss                                  when upm_tb = "0111" else (others => 'Z');  --ledig
  buss <= x"000" & "00" & tileTypeRead          when upm_tb = "1000" else (others => 'Z');
  buss <= x"000" & "00" & tilePointer           when upm_tb = "1001" else (others => 'Z');
  buss <= x"00000" & joy1x                      when upm_tb = "1010" else (others => 'Z');
  buss <= x"00000" & joy1y                      when upm_tb = "1011" else (others => 'Z');
  buss <= x"00000" & "0" & btn1                 when upm_tb = "1100" else (others => 'Z');
  buss <= x"00000" & joy2x                      when upm_tb = "1101" else (others => 'Z');
  buss <= x"00000" & joy2y                      when upm_tb = "1110" else (others => 'Z');
  buss <= x"00000" & "0" & btn1                 when upm_tb = "1111" else (others => 'Z');

  process(clk)
  begin
    if rising_edge(clk) then

      -- FB
      case upm_fb is
        when "0000" => null;
        when "0001" => ASR <= unsigned(buss(11 downto 0));
        when "0010" => IR <= buss;
        when "0011" => PM <= buss;
        when "0100" => PC <= buss(11 downto 0);
        when "0101" => GRx(GRx_x) <= buss;
        when "0110" => null;            --AR
        when "0111" => null;            --ledig
        when "1000" => tileTypeWrite <= buss(7 downto 0);
        when "1001" => tilePointer <= buss(7 downto 0);
        when "1010" => null;            --joy1x
        when "1011" => null;            --joy1y
        when "1100" => null;            --btn1
        when "1101" => null;            --joy2x
        when "1110" => null;            --joy2y
        when "1111" => null;            --btn2
        when others => null;
      end case;

      -- ALU
      case upm_alu is
        when "0000" => null;            --noop
        when "0001" => AR <= buss;
        when "0010" => AR <= not buss;
        when "0011" => AR <= (others => '0');
        when "0100" => AR <= std_logic_vector(unsigned(AR) + unsigned(buss));
        when "0101" => AR <= std_logic_vector(unsigned(AR) - unsigned(buss));
        when "0110" => AR <= AR and buss;
        when "0111" => AR <= AR or buss;
        when "1000" => AR <= std_logic_vector(unsigned(AR) + unsigned(buss));  --no flags
        when "1001" => AR <= std_logic_vector(shift_left(unsigned(AR), 1));
        when "1010" => null;            --ledig
        when "1011" => null;            --ledig
        when "1100" => null;            --ledig
        when "1101" => AR <= std_logic_vector(shift_right(unsigned(AR), 1));
        when "1110" =>  null;           --ledig
        when "1111" =>  null;           --ledig
        when others => null;
      end case;

      if not(upm_alu = "1000") then
        O <= '0';
        C <= '0';
        N <= AR(21);
        if AR = "0000000000000000000000" then
          Z <= '1';
        else
          Z <= '0';
        end if;
        L <= '0';
      end if;
  
      -- P
      case upm_p is
        when "0" => null;
        when "1" => PC <= std_logic_vector(unsigned(PC) + 1);
        when others => null;
      end case;

      -- LC
      case upm_lc is
        when "00" => null;
        when "01" => LC <= std_logic_vector(unsigned(LC) - 1);
        when "10" => LC <= "0" & buss(7 downto 0);
        when "11" => LC <= upm_uaddr;
        when others => null;
      end case;

      -- SEQ
      case upm_seq is
        when "0000" => uPC <= uPC + 1;
        when "0001" => uPC <= unsigned(k1(to_integer(unsigned(ir_op))));
        when "0010" => uPC <= unsigned(k2(to_integer(unsigned(ir_m))));
        when "0011" => uPC <= (others => '0');
        when "0100" => uPC <= unsigned(upm_uaddr);
        when "0101" => null;            --ledig
        when "0110" => null;            --ledig
        when "0111" => null;            --ledig
        when "1000" =>
          if Z = '1' then
            uPC <= unsigned(upm_uaddr);
          end if;
        when "1001" =>
          if N = '1' then
            uPC <= unsigned(upm_uaddr);
          end if;
        when "1010" =>
          if C = '1' then
            uPC <= unsigned(upm_uaddr);
          end if;
        when "1011" => 
          if O = '1' then
            uPC <= unsigned(upm_uaddr);
          end if;
        when "1100" =>
          if L = '1' then
            uPC <= unsigned(upm_uaddr);
          end if;
        when "1101" => null;            --ledig
        when "1110" => null;            --ledig
        when "1111" => null;            -- HALT
        when others => null;
      end case;
      
    end if;                             -- rising_edge(clk)
  end process;

  -- Program memory component connection (PM)
  U1 : PROGRAM_MEMORY port map (pAddr => ASR, pData => PM);
  

  -- Micro memory component connection (uPM)
  U2 : MICRO_MEMORY port map (uAddr => uPC, uData => uPM);

end behavioral;
