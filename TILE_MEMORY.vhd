  -- Tile memory type
  type ram_t is array (0 to 2047) of std_logic_vector(7 downto 0);

  -- Tile memory
  signal tile_mem : ram_t := ( x"FF", x"FF");  -- tile memory
