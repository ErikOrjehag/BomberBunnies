-------------------------------------------------------------------------------
-- VGA_MOTOR
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
entity VGA_MOTOR is
  port (
    clk		        : in std_logic;                         -- system clock
    rst	                : in std_logic;
    playerPixel         : in std_logic_vector(7 downto 0);   -- pixel from player
    tilePixel           : in std_logic_vector(7 downto 0);   -- Tile pixel data
    xPixel              : buffer unsigned(9 downto 0) := "0000000000";         -- Horizontal pixel counter
    yPixel	        : buffer unsigned(9 downto 0) := "0000000000";		-- Vertical pixel counter
    vgaRed              : out std_logic_vector(2 downto 0) := "000";
    vgaGreen            : out std_logic_vector(2 downto 0) := "000";
    vgaBlue             : out std_logic_vector(2 downto 1) := "00";
    hSync               : out std_logic;
    vSync               : out std_logic);
end VGA_MOTOR;

-- architecture
architecture behavioral of VGA_MOTOR is
  signal	clkDiv	        : unsigned(1 downto 0);		-- Clock divisor, to generate 25 MHz signal
  signal	clk25		: std_logic;			-- One pulse width 25 MHz signal
  signal	tileAddr	: unsigned(10 downto 0);	-- Tile address
  signal        blank           : std_logic;                    -- blanking signal
  constant      transparent     : std_logic_vector(7 downto 0) := "10010000";
  signal        pixel           : std_logic_vector(7 downto 0);  -- output to screen
begin

  -- Divide system clock (100 MHz) by 4
  process(clk)
  begin
    if rising_edge(clk) then
      if rst='1' then
	clkDiv <= (others => '0');
      else
	clkDiv <= clkDiv + 1;
      end if;
    end if;
  end process;
	

  -- 25 MHz clock (one system clock pulse width)
  clk25 <= '1' when (clkDiv = 3) else '0';	

  
  -- Horizontal pixel counter
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        xPixel <= (others => '0');
      elsif clk25 = '1' then
        if xPixel = 799 then
          xPixel <= (others => '0');
        else
          xPixel <= xPixel + 1;
        end if;
      end if;
    end if;
  end process;
  
  -- Horizontal sync
  hSync <= '0' when (xPixel >= 656 and xPixel < 752) else '1';
  
  -- Vertical pixel counter
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        yPixel <= (others => '0');
      elsif clk25 = '1' then  
        if xPixel = 799 then
          if yPixel = 520 then
            yPixel <= (others => '0');
          else
            yPixel <= yPixel + 1;
          end if;
        end if;
      end if;
    end if;
  end process;
	

  -- Vertical sync
  vSync <= '0' when (yPixel >= 490 and yPixel < 492) else '1';

  -- Video blanking signal
  blank <= '1' when (xPixel >= 640 or yPixel >= 480) else '0';


  -- Assign pixel to tile or sprite
  pixel <= (others => '0') when blank = '1' else
           playerPixel when not(playerPixel = transparent) else
           tilePixel;
  
  -- VGA generation
  vgaRed(2) 	<= pixel(7);
  vgaRed(1) 	<= pixel(6);
  vgaRed(0) 	<= pixel(5);
  vgaGreen(2)   <= pixel(4);
  vgaGreen(1)   <= pixel(3);
  vgaGreen(0)   <= pixel(2);
  vgaBlue(2) 	<= pixel(1);
  vgaBlue(1) 	<= pixel(0);

end behavioral;
