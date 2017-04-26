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
    clk         : in  std_logic;          -- 67 kHz clock
    rst         : in  std_logic;

    -- Outputs
    joyX      : out std_logic_vector(9 downto 0) := (others => '0');
    joyY      : out std_logic_vector(9 downto 0) := (others => '0');
    btn       : out std_logic := '0';

    -- Joystick pins
    MISO        : in  STD_LOGIC;			-- Master input slave output
    MOSI        : out STD_LOGIC := '0';		-- Master out slave in
    SCLK        : out STD_LOGIC := '0';			-- Serial clock
    SS          : out std_logic := '1'  -- start sequence
  );

end JOYSTICK;

architecture Behavioral of JOYSTICK is

--===================================================================================
-- 			Signals and Constants
--===================================================================================

  -- FSM States
  type state_type is (Init, RxTx, Done);  -- RxTx = recieve, transmit

  -- Present state, Next State
  signal STATE, NSTATE : state_type;

  signal bitCount : unsigned(5 downto 0) := (others => '0');    -- Number bits read/written
  signal rSR : STD_LOGIC_VECTOR(39 downto 0) := (others => '0');	-- Read shift register

  signal CE : STD_LOGIC := '0';		       			-- Clock enable, controls serial
                                                                -- clock signal sent to slave
  
      
--===================================================================================
--              		Implementation
--===================================================================================
begin  -- Behavioral

  -- Serial clock output, allow if clock enable asserted
  SCLK <= clk when (CE = '1') else '0';

  ---------------------------------------
  -- Read Shift Register
  -- master reads on rising edges,
  -- slave changes data on falling edges
  ---------------------------------------
  process (clk, rst) begin
    if rst = '1' then
      rSR <= (others => '0');
    elsif rising_edge(clk) then
      -- Enable shift during RxTx state only
      case(STATE) is
        when Init =>
          rSR <= rSR;
        when RxTx =>
          if CE = '1' then
            rSR <= rSR(38 downto 0) & MISO;
          end if;									
        when Done =>
          rSR <= rSR;
      end case;
    end if;
  end process;

  --------------------------
  -- When Done send to CPU
  --------------------------
  process(STATE) begin
    if STATE = Done then
      joyX <= rSR(25 downto 24) & rSR(39 downto 32);
      joyY <= rSR(9 downto 8) & rSR(23 downto 16);
      --joyX <= "00" & rSR(39 downto 32);
      --joyY <= "00" & rSR(23 downto 16);
      btn <= rSR(1);
    end if;
  end process;

  --------------------------------
  -- State Register
  --------------------------------
  STATE_REGISTER: process(clk, rst) begin
    if falling_edge(clk) then         -- Ska vara falling
      STATE <= NSTATE;
    end if;
  end process;

  
  --------------------------------
  -- Output Logic/Assignment
  --------------------------------
  OUTPUT_LOGIC: process (clk, rst)
  begin
    if (rst = '1') then  -- Reset/clear values
      CE <= '0';        -- Disable serial clock
      bitCount <= (others => '0'); -- Clear #bits read/written

    elsif falling_edge(clk) then         -- ska vara falling
      case (STATE) is
        when Init =>
          bitCount <= (others => '0');		-- Have not read/written anything yet
          CE <= '0';			-- Disable serial clock
          
        when RxTx =>
          bitCount <= bitCount + 1;	-- Begin counting bits received/written
                                        -- Have written all bits to slave so prevent another falling edge
          if(bitCount >= X"40") then
            CE <= '0';
                                        -- Have not written all data, normal operation
          else
            CE <= '1';
          end if;
            
        when Done =>
          CE <= '0';		      	-- Disable serial clock
          bitCount <= (others => '0');		-- Clear #bits read/written
          
      end case;
						
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- SS Process block
  -----------------------------------------------------------------------------
  SS_PROCESS: process (clk, rst, STATE)
  begin  -- process
    if rst = '1' then
      SS <= '1';
    elsif STATE = Init then
      SS <= '0';
    elsif STATE = Done then
      SS <= '1';
    end if;
    
  end process;
  
  
  --------------------------------
  --  Next State Logic
  --------------------------------
  NEXT_STATE_LOGIC: process (bitCount, STATE)
  begin
                                        -- Define default state to avoid latches
    case (STATE) is        
      when Init =>
        NSTATE <= RxTx;

      when RxTx =>                      -- Read last bit so data transmission is finished
        if(bitCount = "101000") then
          NSTATE <= Done;

                                        -- Data transmission is not finished
        else
          NSTATE <= RxTx;
        end if;

      when Done =>
        NSTATE <= Init;
      when others =>
        NSTATE <= Init;
    end case;      
  end process;
end Behavioral;
