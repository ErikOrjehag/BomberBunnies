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
    tileTypeWrite       : out std_logic_vector(7 downto 0) := (others => '0');
    readMap             : out std_logic := '0';
    writeMap            : out std_logic := '0';
    p1x                 : out std_logic_vector(3 downto 0);
    p1y                 : out std_logic_vector(3 downto 0);
    p2x                 : out std_logic_vector(3 downto 0);
    p2y                 : out std_logic_vector(3 downto 0)
  );
end CPU;

-- architecture
architecture behavioral of CPU is
  
  -- program memory component
  component PROGRAM_MEMORY
    port (
         pAddr : in unsigned(11 downto 0);
         PM_out : out std_logic_vector(22 downto 0);
         PM_in : in std_logic_vector(22 downto 0);
         PM_write : in std_logic
         );
 
  end component;

  -- Micro memory component
  component MICRO_MEMORY
    port (
      uAddr : in  unsigned(8 downto 0);
      uData : out std_logic_vector(29 downto 0));
  end component;

  signal PM_in : std_logic_vector(22 downto 0);
  signal PM_out : std_logic_vector(22 downto 0);
  signal PM_write : std_logic := '0';
  signal uPM : std_logic_vector(29 downto 0);

  -- Bus
  signal buss : std_logic_vector(22 downto 0) := (others => '0');

  -- GRx
  type grx_t is array (0 to 15) of std_logic_vector(22 downto 0);
  signal GRx : grx_t := (
    "00000000000000000001000", -- 0    (tillfälligt = 8)
    "00000000000000010000000", -- 1    (tillfälligt = 128)
    "00000000000000000000010", -- 2    (tillfälligt = 2)
    "00000000000000000000010", -- 3
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
    "00000000000000000000100"  -- p2y
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
  type k1_t is array (0 to 31) of std_logic_vector(8 downto 0);  --31
  signal k1 : k1_t := (
    
    "000001010",  -- (00000) LOAD (rad 00A)
    "000001011",  -- (00001) STORE (rad 00B)
    "000001101",  -- (00010) ADD (rad 00C)
    "000010000",  -- (00011) SUB (rad 00F)
    "000010011",  -- (00100) JUMP (rad 18)
    "000010100",  -- (00101) SLEEP (ITR) (rad 19)
    "000011001",  -- (00110) BEQ
    "000011011",  -- (00111) BNE
    "000011101",  -- (01000) MUL
    "000011101",  -- (01001) tom
    "000011110",  -- (01010) tom
    "000011111",  -- (01011) tom
    "000100000",  -- (01100) tom
    "000100001",  -- (01101) tom
    "000100010",  -- (01110) tileWriter
    "000100100",  -- (01111) tileRead
    "000100110",  -- (10000) tilePointer
    "000100111",  -- (10001) JOY1R
    "000101001",  -- (10010) JOY1U
    "000101011",  -- (10011) JOY1L
    "000101101",  -- (10100) JOY1D
    "000101111",  -- (10101) PRESS1
    "000110001",  -- (10110) JOY2R
    "000110011",  -- (10111) JOY2U
    "000110101",  -- (11000) JOY2L
    "000110111",  -- (11001) JOY2D
    "000111001",  -- (11010) PRESS2
    "000111010",  -- (11011) ADDPM
    "000000000",  -- (11100) 
    "000000000",  -- (11101) 
    "000000000",  -- (11110) 
    "000000000"   -- (11111)
);

  -- uPM signals
  signal upm_instr : std_logic_vector(29 downto 0);
  
  signal upm_alu : std_logic_vector(3 downto 0);
  signal upm_tb : std_logic_vector(3 downto 0);
  signal upm_fb : std_logic_vector(3 downto 0);
  signal upm_s : std_logic_vector(0 downto 0);
  signal upm_p : std_logic_vector(0 downto 0);
  signal upm_lc : std_logic_vector(1 downto 0);
  signal upm_seq : std_logic_vector(4 downto 0);
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

  -- Joystick flags
  signal j1r : std_logic := '0';
  signal j1u : std_logic := '0';
  signal j1l : std_logic := '0';
  signal j1d : std_logic := '0';
  signal b1 : std_logic := '0';
  signal j2r : std_logic := '0';
  signal j2u : std_logic := '0';
  signal j2l : std_logic := '0';
  signal j2d : std_logic := '0';
  signal b2 : std_logic := '0';

  signal mul : std_logic_vector(23 downto 0);

begin  -- behavioral
  
  -- Update joystick flags
  j1r <= '1' when (joy1x = "01") else '0';
  j1u <= '1' when (joy1y = "01") else '0';
  j1l <= '1' when (joy1x = "10") else '0';
  j1d <= '1' when (joy1y = "10") else '0';
  b1 <= '1' when (btn1 = '1') else '0';
  j2r <= '1' when (joy2x = "01") else '0';
  j2u <= '1' when (joy2y = "01") else '0';
  j2l <= '1' when (joy2x = "10") else '0';
  j2d <= '1' when (joy2y = "10") else '0';
  b2 <= '1' when (btn2 = '1') else '0';
  
  -- Player positions
  p1x <= GRx(12)(3 downto 0);
  p1y <= GRx(13)(3 downto 0);
  p2x <= GRx(14)(3 downto 0);
  p2y <= GRx(15)(3 downto 0);

  -- uPM signals
  upm_instr <= uPM;
  
  upm_alu   <= upm_instr(29 downto 26);
  upm_tb    <= upm_instr(25 downto 22);
  upm_fb    <= upm_instr(21 downto 18);
  upm_s     <= upm_instr(17 downto 17);
  upm_p     <= upm_instr(16 downto 16);
  upm_lc    <= upm_instr(15 downto 14);
  upm_seq   <= upm_instr(13 downto 9);
  upm_uaddr <= upm_instr(8  downto 0);
  
  -- IR signals
  ir_addr   <= IR(11 downto 0);
  ir_m      <= IR(13 downto 12);
  ir_grx    <= IR(17 downto 14);
  ir_op     <= IR(22 downto 18);
  
  -- TB
  GRx_x <= to_integer(unsigned(ir_grx)) when (upm_s = "0") else to_integer(unsigned(ir_m));

  readMap <= '1' when upm_tb = "1000" else '0';
  
  with upm_tb select buss <=
    "00000000000" & std_logic_vector(ASR)       when "0001", 
    IR                                          when "0010",
    PM_out                                      when "0011",
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

      if not (upm_fb = "0011") then
        PM_write <= '0';
      end if;

      if not (upm_fb = "1000") then
        writeMap <= '0';
      end if;
      
      -- FB
      case upm_fb is
        when "0000" => null;
        when "0001" => ASR <= unsigned(buss(11 downto 0));
        when "0010" => IR <= buss;
        when "0011" =>
          PM_in <= buss;
          PM_write <= '1';
        when "0100" => PC <= buss(11 downto 0);
        when "0101" => GRx(GRx_x) <= buss;
        when "0110" => null;            --AR
--        when "0111" => tileTypeRead <= buss(7 downto 0);
        when "1000" =>
          tileTypeWrite <= buss(7 downto 0);
          writeMap <= '1';
        when "1001" => tilePointer <= buss(7 downto 0);
--        when "1010" => null;            --joy1x
--        when "1011" => null;            --joy1y
--        when "1100" => null;            --btn1
--        when "1101" => null;            --joy2x
--        when "1110" => null;            --joy2y
--        when "1111" => null;            --btn2
        when others => null;
      end case;

      mul <= std_logic_vector(unsigned(AR) * unsigned(buss(11 downto 0)));
--cannot index after conversion, converts here so it can be indexed in ALU
      
      -- ALU
      case upm_alu is
        when "0000" => null;            --noop
        when "0001" => AR <= buss(11 downto 0);
        when "0010" => AR <= not buss(11 downto 0);
        when "0011" => AR <= (others => '0');
        when "0100" => AR <= std_logic_vector(unsigned(AR) + unsigned(buss(11 downto 0)));      --add
        when "0101" => AR <= std_logic_vector(unsigned(AR) - unsigned(buss(11 downto 0)));      --sub
        when "0110" => AR <= AR and buss(11 downto 0);
        when "0111" => AR <= AR or buss(11 downto 0);
        when "1000" => AR <= std_logic_vector(unsigned(AR) + unsigned(buss(11 downto 0)));      --no flags
        when "1001" => AR <= std_logic_vector(shift_left(unsigned(AR), 1));                     --shift left
        when "1010" => AR <= mul(11 downto 0);      --mul
        when "1011" => null; --AR <= std_logic_vector(unsigned(AR) / unsigned(buss(11 downto 0)));      --div
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

      --if not (upm_seq = "00101") then
      --  writeMap <= '0';
      --end if;

      --if not (upm_seq = "00110") then
      --  readMap <= '0';
      --end if;
      
      -- SEQ
      case upm_seq is
        when "00000" => uPC <= uPC + 1;
        when "00001" => uPC <= unsigned(k1(to_integer(unsigned(ir_op))));
        when "00010" => uPC <= unsigned(k2(to_integer(unsigned(ir_m))));
        when "00011" => uPC <= (others => '0');
        when "00100" => uPC <= unsigned(upm_uaddr);
        --when "00101" =>
        --  writeMap <= '1';
        --  uPC <= uPC + 1;
        --when "00110" =>
        --  readMap <= '1';
        --  uPC <= uPC + 1;
        when "00111" => null;            --ledig
        when "01000" =>
          if Z = '1' then
            uPC <= unsigned(upm_uaddr);
          end if;
        when "01001" =>
          if N = '1' then
            uPC <= unsigned(upm_uaddr);
          end if;
        when "01010" =>
          if C = '1' then
            uPC <= unsigned(upm_uaddr);
          end if;
        when "01011" => 
          if O = '1' then
            uPC <= unsigned(upm_uaddr);
          end if;
        when "01100" =>
          if L = '1' then
            uPC <= unsigned(upm_uaddr);
          else
            uPC <= uPC + 1;
          end if;
        when "01101" => null;            --ledig
        when "01110" => null;            --ledig
        when "01111" => null;            -- HALT
        when "10000" =>
          if j1r = '1' then
            uPC <= unsigned(upm_uaddr);
          else
            uPC <= uPC + 1;
          end if;
        when "10001" =>
          if j1u = '1' then
            uPC <= unsigned(upm_uaddr);
          else
            uPC <= uPC + 1;
          end if;
        when "10010" =>
          if j1l = '1' then
            uPC <= unsigned(upm_uaddr);
          else
            uPC <= uPC + 1;
          end if;
        when "10011" =>
          if j1d = '1' then
            uPC <= unsigned(upm_uaddr);
          else
            uPC <= uPC + 1;
          end if;
        when "10100" =>
          if b1 = '1' then
            uPC <= unsigned(upm_uaddr);
          else
            uPC <= uPC + 1;
          end if;
        when "10101" =>
          if j2r = '1' then
            uPC <= unsigned(upm_uaddr);
          else
            uPC <= uPC + 1;
          end if;
        when "10110" =>
          if j2u = '1' then
            uPC <= unsigned(upm_uaddr);
          else
            uPC <= uPC + 1;
          end if;
        when "10111" =>
          if j2l = '1' then
            uPC <= unsigned(upm_uaddr);
          else
            uPC <= uPC + 1;
          end if;
        when "11000" =>
          if j2d = '1' then
            uPC <= unsigned(upm_uaddr);
          else
            uPC <= uPC + 1;
          end if;
        when "11001" =>
          if b2 = '1' then
            uPC <= unsigned(upm_uaddr);
          else
            uPC <= uPC + 1;
          end if;
        when others => null;
      end case;
    end if;
  end process;

  -- Program memory component connection (PM)
  U1 : PROGRAM_MEMORY port map (clk => clk, pAddr => ASR, PM_out => PM_out, PM_in => PM_in, PM_write => PM_write);
  

  -- Micro memory component connection (uPM)
  U2 : MICRO_MEMORY port map (uAddr => uPC, uData => uPM);

end behavioral;
