--------------------------------------------------------------------------------
-- JOYSTICK
-- TEAM REG


-- library declaration
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;            -- basic IEEE library
use IEEE.NUMERIC_STD.ALL;               -- IEEE library for the unsigned type
                                        -- and various arithmetic operations
entity JOYSTICK is
  
  port (
    clk         : in  std_logic;          -- system clock
    rst         : in  std_logic;

    -- Outputs
    joyX      : out std_logic_vector(9 downto 0);
    joyY      : out std_logic_vector(9 downto 0);
    btn       : out std_logic;

    -- Joystick pins
    MISO        : in  STD_LOGIC;			-- Master input slave output
    MOSI        : out  STD_LOGIC := '0';		-- Master out slave in
    SCLK        : out  STD_LOGIC := '0';			-- Serial clock
    SS          : out  STD_LOGIC := '1';		-- Busy if sending/receiving data
  );

end JOYSTICK;

architecture Behavioral of JOYSTICK is

  component SLOW_CLOCK
    port (
      clk    : in  std_logic;           -- system clock
      rst    : in  std_logic;           -- rst
      clkout : buffer std_logic);          -- 67 kHz clock
  end component;

--===================================================================================
-- 			Signals and Constants
--===================================================================================

  -- FSM States
  type state_type is (Idle, Init, RxTx, Done);  -- RxTx = recieve, transmit

  -- Present state, Next State
  signal STATE, NSTATE : state_type;

  signal bitCount : unsigned(3 downto 0) := (others => '0');    -- Number bits read/written
  signal rSR : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');	-- Read shift register

  signal CE : STD_LOGIC := '0';		       			-- Clock enable, controls serial
                                                                -- clock signal sent to slave
  signal slowClock : std_logic:= '0';          -- 67 kHz clock

  signal lowX : std_logic_vector(7 downto 0) := (others => '0');
  signal lowY : std_logic_vector(7 downto 0) := (others => '0');
  signal byteCount : unsigned(2 downto 0) := (others => '0');

  signal sndRec : STD_LOGIC := '1';                        -- Send receive, initializes data read/write
  
--===================================================================================
--              		Implementation
--===================================================================================
begin  -- Behavioral

  -- Serial clock output, allow if clock enable asserted
  SCLK <= slowClock when (CE = '1') else '0';

  ---------------------------------------
  -- Read Shift Register
  -- master reads on rising edges,
  -- slave changes data on falling edges
  ---------------------------------------
  process (clk, rst) begin
    if rst   = '1' then
      rSR <= X"00";
    elsif rising_edge(clk) then
      -- Enable shift during RxTx state only
      case(STATE) is
        when Idle =>
          rSR <= rSR;
        when Init =>
          rSR <= rSR;
        when RxTx =>
          if CE = '1' then
            rSR <= rSR(6 downto 0) & MISO;
          end if;									
        when Done =>
          rSR <= rSR;
          
      end case;
    end if;
  end process;

  --------------------------
  -- When Done send to CPU
  --------------------------
  process(clk, rst) begin
    if rst = '1' then
      byteCount <= (others => '0');
    elsif rising_edge(clk) then
      if STATE = Done then
        case byteCount is
          when "000" =>
            lowX <= rSR;
          when "001" =>
            joyX <= rSR(1 downto 0) & lowX;
          when "010" =>
            lowY <= rSR;
          when "011" =>
            joyY <= rSR(1 downto 0) & lowY;
          when "100" =>
            btn <= rSR(1);
          when others => null;
        end case;

        if byteCount = "100" then
          byteCount <= (others => '0');
        else
          byteCount <= byteCount + 1;
        end if;
      end if;
    end if;
  end process;

  --------------------------------
  -- State Register
  --------------------------------
  STATE_REGISTER: process(clk, rst) begin
    if rst = '1' then
      STATE <= Idle;
    elsif rising_edge(clk) then         -- Ska vara falling
      STATE <= NSTATE;
    end if;
  end process;

  
  --------------------------------
  -- Output Logic/Assignment
  --------------------------------
  OUTPUT_LOGIC: process (CLK, RST)
  begin
    if(RST = '1') then  -- Reset/clear values
      CE <= '0';        -- Disable serial clock
      BUSY <= '0';      -- not busy in Idle state
      bitCount <= X"0"; -- Clear #bits read/written

    elsif rising_edge(CLK) then         -- ska vara falling
      case (STATE) is
        when Idle =>
          CE <= '0';			-- Disable serial clock
          BUSY <= '0';			-- Not busy in Idle state
          bitCount <= X"0";		-- Clear #bits read/written
          
        when Init =>
          BUSY <= '1';			-- Output a busy signal
          bitCount <= X"0";		-- Have not read/written anything yet
          CE <= '0';			-- Disable serial clock
          
        when RxTx =>
          BUSY <= '1';			-- Output busy signal
          bitCount <= bitCount + 1;	-- Begin counting bits received/written
                                        -- Have written all bits to slave so prevent another falling edge
          if(bitCount >= X"8") then
            CE <= '0';
                                        -- Have not written all data, normal operation
          else
            CE <= '1';
          end if;
            
        when Done =>
          CE <= '0';		      	-- Disable serial clock
          BUSY <= '1';		        -- Still busy
          bitCount <= X"0";		-- Clear #bits read/written
          
      end case;
						
    end if;
  end process;

  --------------------------------
  --  Next State Logic
  --------------------------------
  NEXT_STATE_LOGIC: process (sndRec, bitCount, STATE)
  begin
                                        -- Define default state to avoid latches
    NSTATE <= Idle;
    
    case (STATE) is
      when Idle =>
        if sndRec= '1' then
          NSTATE <= Init;
        else
          NSTATE <= Idle;
        end if;
        
      when Init =>
        NSTATE <= RxTx;

      when RxTx =>                      -- Read last bit so data transmission is finished
        if(bitCount = X"8") then
          NSTATE <= Done;

                                        -- Data transmission is not finished
        else
          NSTATE <= RxTx;
        end if;

      when Done =>
        NSTATE <= Idle;
      when others =>
        NSTATE <= Idle;
    end case;      
  end process;

  U1 : SLOW_CLOCK port map (
    clk    => clk,
    rst    => rst,
    clkout => slowClock);
  

end Behavioral;
