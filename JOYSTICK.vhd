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
    slowClock   : in  std_logic;          -- 67 kHz clock
    clkout      : out std_logic;          -- clock to slow clock
    jstk1x      : out std_logic_vector(9 downto 0) := (others => '0');
    jstk1y      : out std_logic_vector(9 downto 0) := (others => '0');
    btn1        : out std_logic;
    jstk2x      : out std_logic_vector(9 downto 0) := (others => '0');
    jstk2y      : out std_logic_vector(9 downto 0) := (others => '0');
    btn2        : out std_logic;

    -- ????? Some ports on joystick, others?
    sndRec      : in  STD_LOGIC;                        -- Send receive, initializes data read/write
    DIN         : in  STD_LOGIC_VECTOR (7 downto 0);   	-- Data that is to be sent to the slave
    MISO        : in  STD_LOGIC;			-- Master input slave output
    MOSI        : out  STD_LOGIC;			-- Master out slave in
    SCLK        : out  STD_LOGIC;			-- Serial clock, slowClock??
    BUSY        : out  STD_LOGIC;			-- Busy if sending/receiving data
    DOUT        : out  STD_LOGIC_VECTOR (7 downto 0)	-- Data read from the slave
    );

end JOYSTICK;

architecture Behavioral of JOYSTICK is

  component SLOW_CLOCK
    port (
      clk    : in  std_logic;           -- system clock
      rst    : in  std_logic;           -- rst
      clkout : out std_logic);          -- 67 kHz clock

--===================================================================================
-- 			Signals and Constants
--===================================================================================

  -- FSM States
  type state_type is (Idle, Init, RxTx, Done);

  -- Present state, Next State
  signal STATE, NSTATE : state_type;

  signal bitCount : STD_LOGIC_VECTOR(3 downto 0) := X"0";       -- Number bits read/written
  signal rSR : STD_LOGIC_VECTOR(7 downto 0) := X"00";		-- Read shift register
  signal wSR : STD_LOGIC_VECTOR(7 downto 0) := X"00";		-- Write shift register

  signal CE : STD_LOGIC := '0';		       			-- Clock enable, controls serial
                                                                -- clock signal sent to slave

--===================================================================================
--              		Implementation
--===================================================================================
begin  -- Behavioral

  -- Serial clock output, allow if clock enable asserted
  SCLK <= CLK when (CE = '1') else '0';
  -- Master out slave in, value always stored in MSB of write shift register
  MOSI <= wSR(7);
  -- Connect data output bus to read shift register
  DOUT <= rSR;
	
  ---------------------------------------
  -- Write Shift Register
  -- slave reads on rising edges,
  -- change output data on falling edges
  ---------------------------------------
  process(CLK, RST) begin
    if(RST = '1') then
      wSR <= X"00";
    elsif falling_edge(CLK) then
      -- Enable shift during RxTx state only
      case(STATE) is
        when Idle =>
          wSR <= DIN;
      
        when Init =>
          wSR <= wSR;
      
        when RxTx =>
          if(CE = '1') then
            wSR <= wSR(6 downto 0) & '0';
          end if;
      
        when Done =>
          wSR <= wSR;
      
      end case;
    end if;
  end process;




  ---------------------------------------
  -- Read Shift Register
  -- master reads on rising edges,
  -- slave changes data on falling edges
  ---------------------------------------
  process(CLK, RST) begin
    if(RST = '1') then
      rSR <= X"00";
    elsif rising_edge(CLK) then
      -- Enable shift during RxTx state only
      case(STATE) is
        when Idle =>
          rSR <= rSR;
      
        when Init =>
          rSR <= rSR;
      
        when RxTx =>
          if(CE = '1') then
            rSR <= rSR(6 downto 0) & MISO;
          end if;
									
        when Done =>
          rSR <= rSR;
      
      end case;
    end if;
  end process;

  --------------------------------
  -- State Register
  --------------------------------
  STATE_REGISTER: process(CLK, RST) begin
    if (RST = '1') then
      STATE <= Idle;
    elsif falling_edge(CLK) then
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

    elsif falling_edge(CLK) then
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
        if sndRec = '1' then
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
