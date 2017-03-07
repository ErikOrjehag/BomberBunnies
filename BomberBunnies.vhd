-------------------------------------------------------------------------------
-- BOMBER BUNNIES
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
    clk         : in std_logic;                      -- system clock (100 MHz)
    rst	        : in std_logic;
    vgaRed      : out std_logic_vector(2 downto 0);
    vgaGreen    : out std_logic_vector(2 downto 0);
    vgaBlue     : out std_logic_vector(2 downto 1);
    Hsync	: out std_logic;
    Vsync	: out std_logic);
    xpixel      : out std_logic;
    ypixel      : out std_logic;
    playerPixel : in std_logic_vector(7 downto 0);   -- pixel from player
    mapPixel   : in std_logic_vector(7 downto 0);   -- Tile pixel data
    pixel       : out std_logic_vector(7 downto 0);  -- output to VGA

    );                
end VGA_MOTOR;

-- architecture
architecture behavioral of BomberBunnies is
  signal	Xpixel	        : unsigned(9 downto 0);         -- Horizontal pixel counter
  signal	Ypixel	        : unsigned(9 downto 0);		-- Vertical pixel counter
  signal	ClkDiv	        : unsigned(1 downto 0);		-- Clock divisor, to generate 25 MHz signal
  signal	Clk25		: std_logic;			-- One pulse width 25 MHz signal
		
  signal	tileAddr	: unsigned(10 downto 0);	-- Tile address

  signal        blank           : std_logic;                    -- blanking signal


  -- Tile memory type
  type ram_t is array (0 to 2047) of std_logic_vector(7 downto 0);

  -- Tile memory
  signal tile_mem : ram_t := ( x"FF", x"FF");  -- tile memory
  
begin  -- behavioral

  -- Clock divisor
  -- Divide system clock (100 MHz) by 4
  process(clk)
  begin
    if rising_edge(clk) then
      if rst='1' then
	ClkDiv <= (others => '0');
      else
	ClkDiv <= ClkDiv + 1;
      end if;
    end if;
  end process;
	
  -- 25 MHz clock (one system clock pulse width)
  Clk25 <= '1' when (ClkDiv = 3) else '0';
	
	
  -- Horizontal pixel counter

  -- ***********************************
  -- *                                 *
  -- *  VHDL for :                     *
  -- *  Xpixel                         *
  -- *                                 *
  -- ***********************************
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        Xpixel <= (others => '0');
      elsif Clk25 = '1' then
        if Xpixel = 799 then
          Xpixel <= (others => '0');
        else
          Xpixel <= Xpixel + 1;
        end if;
      end if;
    end if;
  end process;
  
  -- Horizontal sync

  -- ***********************************
  -- *                                 *
  -- *  VHDL for :                     *
  -- *  Hsync                          *
  -- *                                 *
  -- ***********************************
  Hsync <= '0' when (Xpixel >= 656 and Xpixel < 752) else '1';
  
  -- Vertical pixel counter

  -- ***********************************
  -- *                                 *
  -- *  VHDL for :                     *
  -- *  Ypixel                         *
  -- *                                 *
  -- ***********************************
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        Ypixel <= (others => '0');
      elsif Clk25 = '1' then  
        if Xpixel = 799 then
          if Ypixel = 520 then
            Ypixel <= (others => '0');
          else
            Ypixel <= Ypixel + 1;
          end if;
        end if;
      end if;
    end if;
  end process;
	

  -- Vertical sync

  -- ***********************************
  -- *                                 *
  -- *  VHDL for :                     *
  -- *  Vsync                          *
  -- *                                 *
  -- ***********************************
  Vsync <= '0' when (Ypixel >= 490 and Ypixel < 492) else '1';

  
  -- Video blanking signal

  -- ***********************************
  -- *                                 *
  -- *  VHDL for :                     *
  -- *  Blank                          *
  -- *                                 *
  -- ***********************************
  Blank <= '1' when (Xpixel >= 640 or Ypixel >= 480) else '0';

  -- Tile memory
  process(clk)
  begin
    if rising_edge(clk) then
      if blank = '0' then
        if playerPixel = "01000110" then -- standard transparent color
          pixel <= mapPixel;
        else
          pixel <= playerPixel;
        end if
      else
        pixel <= (others => '0');
      end if;
    end if;
  end process;



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
