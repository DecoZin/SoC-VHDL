library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity frequency_counter is
  port (
    -- Input
    clk   : in std_logic; -- 10 MHz
    signal_input : in std_logic;
    meas_range   : in std_logic_vector(3 downto 0);
    -- Output
    bcd_one : out std_logic_vector(3 downto 0);
    bcd_ten : out std_logic_vector(3 downto 0);
    bcd_hun : out std_logic_vector(3 downto 0)
  );
end entity;

architecture rtl of frequency_counter is

  component BCD is
    port (
    clk     : in std_logic;
    clear   : in std_logic;
    enable   : in std_logic;
    bcd_out : out std_logic_vector(3 downto 0)
  );
  end component;

  -- Control signals
  signal enable_ctrl : std_logic_vector(2 downto 0) := "111";
  signal clear_ctrl  : std_logic_vector(2 downto 0) := "000";
  
  -- Time signals
  signal ms_counter   : integer := 0;
  signal clk_counter  : integer := 0;
  signal time_counter : integer := 0;
  signal counter_size : integer := 0;  
  signal meas_end     : std_logic := '0';

  -- BDC signals
  signal bcd_ten_in : std_logic := '0';
  signal bcd_hun_in : std_logic := '0';  
  signal overflow   : std_logic := '0';

  signal bcd_one_out: std_logic_vector(3 downto 0);
  signal bcd_ten_out: std_logic_vector(3 downto 0);
  signal bcd_hun_out: std_logic_vector(3 downto 0);

begin

  bcd_one <= bcd_one_out;
  bcd_ten <= bcd_ten_out;
  bcd_hun <= bcd_hun_out;

  bcd_one_inst: BCD
    port map (
      clk     => signal_input,
      clear   => clear_ctrl(0),
      enable  => enable_ctrl(0),
      bcd_out => bcd_one_out
  );

  bcd_ten_inst: BCD
    port map (
      clk     => bcd_ten_in,
      clear   => clear_ctrl(1),
      enable  => enable_ctrl(1),
      bcd_out => bcd_hun_out
  );

  bcd_hun_inst: BCD
    port map (
      clk     => bcd_hun_in,
      clear   => clear_ctrl(2),
      enable  => enable_ctrl(2),
      bcd_out => bcd_hun
  );

  MEAS_COUNTER: process (clk)
  begin
    if rising_edge(clk) then
      clk_counter <= clk_counter + 1;
      -- 1ms
      if (clk_counter = 10000000) then
        clk_counter <= 0;
        ms_counter <= ms_counter + 1;
      end if;
      if (ms_counter = counter_size) then
        meas_end <= '1';
      end if;
    end if;
  end process;

  MEAS_SELECTION: process (meas_range)
  begin
    case( meas_range ) is
      -- 1ms
      when "0001" =>
        counter_size <= 1;
        clear_ctrl <= "111";
        enable_ctrl <= "000";
      -- 10ms
      when "0010" =>
        counter_size <= 10;
        clear_ctrl <= "111";
        enable_ctrl <= "000";
      -- 100ms
      when "0100" =>
        counter_size <= 100;
        clear_ctrl <= "111";
        enable_ctrl <= "000";
      -- 1s
      when "1000" =>
        counter_size <= 1000;
        clear_ctrl <= "111";
        enable_ctrl <= "000";
      when others =>
        counter_size <= 0;
        clear_ctrl <= "111";
        enable_ctrl <= "000";
    end case ;
  end process;

  CONTROL1: process (signal_input)
  begin
    if rising_edge(signal_input) then
      bcd_ten_in <= '0';
      bcd_hun_in <= '0';
      overflow <= '1';
      if (bcd_one_out = "1001") then
        bcd_ten_in <= '1';
      end if;
      if (bcd_ten_out = "1001") then
        bcd_hun_in <= '1';
      end if;
      if (bcd_hun_out = "1001" and bcd_ten_out = "1001" and bcd_one_out = "1001") then
        enable_ctrl <= "000";
      end if;
    end if;
    
  end process;

  CONTROL2: process (clk)
  begin
    if (rising_edge(clk)) then
      clear_ctrl <= "000";
      enable_ctrl <= "111";
      if (bcd_one_out = "1001" and bcd_ten_in = '1') then
        clear_ctrl(0) <= '1';
      end if;
      if (bcd_ten_out = "1001" and bcd_hun_in = '1') then
        clear_ctrl(1) <= '1';
      end if;
      if (bcd_hun_out = "1001" and bcd_ten_out = "1001" and bcd_one_out = "1001" and overflow = '1') then
        enable_ctrl <= "000";
      end if;
      if (meas_end = '1') then
        enable_ctrl <= "000";
      end if;
    end if;
  end process;

end architecture;