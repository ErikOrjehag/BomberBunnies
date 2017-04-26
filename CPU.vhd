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
      pData : out std_logic_vector(22 downto 0));
  end component;

  -- Micro memory component
  component MICRO_MEMORY
    port (
      uAddr : in  unsigned(8 downto 0);
      uData : out std_logic_vector(28 downto 0));
  end component;

  signal PM : std_logic_vector(22 downto 0);
  signal uPM : std_logic_vector(28 downto 0);

  -- Bus
  signal buss : std_logic_vector(22 downto 0) := (others => '0');

  -- GRx
  type grx_t is array (0 to 15) of std_logic_vector(22 downto 0);
  signal GRx : grx_t := (
    "00000000000000000000001", -- 0    (tillfällig)
    "00000000000000000001000", -- 1    (tillfällig)
    "00000000000000000000000", -- 2
    "00000000000000000000000", -- 3*
    "00000000000000000000000", -- 4
    "00000000000000000000000", -- 5
    "00000000000000000000000", -- joy1x
    "00000000000000000000000", -- joy1y
    "00000000000000000000000", -- btn1
    "00000000000000000000000", -- joy2x
    "00000000000000000000000", -- joy2y
    "00000000000000000000000", -- btn2
    "00000000000000000000000", -- p1x
    "00000000000000000000000", -- p1y
    "00000000000000000000000", -- p2x
    "00000000000000001000000"  -- p2y
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
  type k1_t is array (0 to 28) of std_logic_vector(8 downto 0);  --31
  signal k1 : k1_t := (
    
    "000001010",  -- (00000) LOAD (rad 00A)
    "000001011",  -- (00001) STORE (rad 00B)
    "000001100",  -- (00010) ADD (rad 00C)
    "000001111",  -- (00011) SUB (rad 00F)
    "000010010",  -- (00100) JUMP (rad 19)
    "000010011",  -- (00101) SLEEP (ITR)
    "000011000",  -- (00110) BEQ
    "000011010",  -- (00111) BNE
    "000011100",  -- (01000) JOY1X
    "000011101",  -- (01001) JOY1Y
    "000011110",  -- (01010) BTN1
    "000011111",  -- (01011) JOY2X
    "000100000",  -- (01100) JOY2Y
    "000100001",  -- (01101) BTN2
    "000100010",  -- (01110) tileWrite
    "000100011",  -- (01111) tileRead
    "000100100",  -- (10000) tilePointer
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
  signal ir_grx : std_logic_vector(3 downto 0);
  signal ir_op : std_logic_vector(4 downto 0);
  
  -- Registers
  signal IR : std_logic_vector(22 downto 0) := (others => '0');
  signal AR : std_logic_vector(11 downto 0) := (others => '0');
--  signal PC : std_logic_vector(11 downto 0) := (0 => '1', 1 => '1', others => '0');
  signal PC : std_logic_vector(11 downto 0) := (others => '0');
  signal ASR : unsigned(11 downto 0) := (others => '0');
  signal LC : std_logic_vector(22 downto 0) := (others => '0');
  signal uPC : unsigned(8 downto 0) := (others => '0');

  -- Flags
  signal O : std_logic := '0';
  signal C : std_logic := '0';
  signal N : std_logic := '0';
  signal Z : std_logic := '0';
  signal L : std_logic := '0';


begin  -- behavioral
  
  -- Player positions
  p1x <= GRx(12)(9 downto 0);
  p1y <= GRx(13)(9 downto 0);
  p2x <= GRx(14)(9 downto 0);
  p2y <= GRx(15)(9 downto 0);

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
  ir_grx    <= IR(17 downto 14);
  ir_op     <= IR(22 downto 18);
  
  -- TB
  GRx_x <= to_integer(unsigned(ir_grx)) when (upm_s = "0") else to_integer(unsigned(ir_m));

  with upm_tb select buss <=
    "00000000000" & std_logic_vector(ASR)       when "0001", 
    IR                                          when "0010",
    PM                                          when "0011",
    "00000000000" & PC                          when "0100",
    GRx(GRx_x)                                  when "0101",
    "00000000000" & AR                          when "0110",
--    x"000" & "000" & tileTypeWrite              when "0111",
    x"000" & "000" & tileTypeRead               when "1000",
--    x"000" & "000" & tilePointer                when "1001",
    x"00000" & "0" & joy1x                        when "1010",
    x"00000" & "0" & joy1y                        when "1011",
    x"00000" & "00" & btn1                      when "1100",
    x"00000" & "0" & joy2x                        when "1101",
    x"00000" & "0" & joy2y                        when "1110",
    x"00000" & "00" & btn1                      when "1111",
    buss                                        when others;

  L <= '0' when LC = (LC'range => '0') else '1';
  
  process(clk)
  begin
    if rising_edge(clk) then

      -- FB
      case upm_fb is
        when "0000" => null;
        when "0001" => ASR <= unsigned(buss(11 downto 0));
        when "0010" => IR <= buss;
        --when "0011" => PM <= buss;
        when "0100" => PC <= buss(11 downto 0);
        when "0101" => GRx(GRx_x) <= buss;
        when "0110" => null;            --AR
--        when "0111" => tileTypeRead <= buss(7 downto 0);
        when "1000" => tileTypeWrite <= buss(7 downto 0);
        when "1001" => tilePointer <= buss(7 downto 0);
--        when "1010" => null;            --joy1x
--        when "1011" => null;            --joy1y
--        when "1100" => null;            --btn1
--        when "1101" => null;            --joy2x
--        when "1110" => null;            --joy2y
--        when "1111" => null;            --btn2
        when others => null;
      end case;

      -- ALU
      case upm_alu is
        when "0000" => null;            --noop
        when "0001" => AR <= buss(11 downto 0);
        when "0010" => AR <= not buss(11 downto 0);
        when "0011" => AR <= (others => '0');
        when "0100" => AR <= std_logic_vector(unsigned(AR) + unsigned(buss(11 downto 0)));
        when "0101" => AR <= std_logic_vector(unsigned(AR) - unsigned(buss(11 downto 0)));
        when "0110" => AR <= AR and buss(11 downto 0);
        when "0111" => AR <= AR or buss(11 downto 0);
        when "1000" => AR <= std_logic_vector(unsigned(AR) + unsigned(buss(11 downto 0)));  --no flags
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
        N <= AR(11);
        if AR = (AR'range => '0') then
          Z <= '1';
        else
          Z <= '0';
        end if;
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
        when "10" => LC <= buss;
        when "11" => LC <= "00000000000000" & upm_uaddr;
        when others => null;
      end case;

      -- SEQ
      case upm_seq is
        when "0000" => uPC <= uPC + 1;
        when "0001" => uPC <= unsigned(k1(to_integer(unsigned(ir_op))));
        when "0010" => uPC <= unsigned(k2(to_integer(unsigned(ir_m))));
        when "0011" => uPC <= (others => '0');
        when "0100" => uPC <= unsigned(upm_uaddr);
        when "0101" => null;            --ledig  (write?)
        when "0110" => null;            --ledig  (read?)
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
          else
            uPC <= uPC + 1;
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
