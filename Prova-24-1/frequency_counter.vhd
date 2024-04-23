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
  signal meas_range_r: std_logic_vector(3 downto 0);
  signal meas_change : boolean := false;  
  signal overflow: boolean := false;
  
  -- Time signals
  signal ms_counter   : integer := 0;
  signal clk_counter  : integer := 0;
  signal time_counter : integer := 0;
  signal counter_size : integer := 0;  
  signal meas_end     : std_logic := '0';

  -- BDC signals
  signal bcd_ten_in : std_logic := '0';
  signal bcd_hun_in : std_logic := '0';  

  signal bcd_one_out: std_logic_vector(3 downto 0) := "0000";
  signal bcd_ten_out: std_logic_vector(3 downto 0) := "0000";
  signal bcd_hun_out: std_logic_vector(3 downto 0) := "0000";

begin

  meas_change <= (meas_range /= meas_range_r);

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
      bcd_out => bcd_ten_out
  );

  bcd_hun_inst: BCD
    port map (
      clk     => bcd_hun_in,
      clear   => clear_ctrl(2),
      enable  => enable_ctrl(2),
      bcd_out => bcd_hun_out
  );

  MEAS_COUNTER: process (clk)
  begin
    if rising_edge(clk) then
      --- Save the last meas button to reset all system on meas change
      meas_range_r <= meas_range;
      if (meas_change = true or meas_end = '1') then
        meas_end <= '0';
        clk_counter <= 0;
        ms_counter <= 0;
      else
      -- 1ms counter
        clk_counter <= clk_counter + 1;
        -- 1ms
        if (clk_counter = 10000) then
          clk_counter <= 0;
          ms_counter <= ms_counter + 1;
        end if;
      -- Verify if meas range was achieved or if overflowed
        if (ms_counter = counter_size or overflow) then
          clk_counter <= 0;
          meas_end <= '1';
        end if;
      end if;
    end if;
  end process;

  MEAS_SELECTION: process (meas_range)
  begin
    -- Select the size of the meas counter
    case( meas_range ) is
      -- 1ms
      when "0001" =>
        counter_size <= 1;
        
      -- 10ms
      when "0010" =>
        counter_size <= 10;
        
      -- 100ms
      when "0100" =>
        counter_size <= 100;
        
      -- 1s
      when "1000" =>
        counter_size <= 1000;
        
      when others =>
        counter_size <= 0;
        
    end case ;
  end process;

  CONTROL: process (clk, signal_input)
  begin
    -- Enable controlled by clk
    if (rising_edge(clk)) then
      bcd_ten_in <= '0';
      bcd_hun_in <= '0';
      clear_ctrl <= "000";
      -- If overflows stop counting
      if (bcd_one_out /= "1001" or bcd_one_out /= "1001" or bcd_one_out /= "1001") then
        enable_ctrl <= "111";
      end if;
      -- If mean changes disable BCDs
      if (meas_change) then
        enable_ctrl <= "000";
        clear_ctrl <= "111";
      end if;
      -- If meas time is achieved restart counting
      if (meas_end = '1' or overflow) then
        clear_ctrl <= "111";
        bcd_one <= bcd_one_out;
        bcd_ten <= bcd_ten_out;
        bcd_hun <= bcd_hun_out;
      end if;
    end if;

    -- Clear controlled by input
    if (rising_edge(signal_input)) then
      -- If unit is 9 and ten and hundred aren't unit clears
      if (bcd_one_out = "1001" and not (bcd_ten_out = "1001" and bcd_hun_out = "1001")) then
        clear_ctrl(0) <= '1';
        bcd_ten_in <= '1';
      end if;
      -- If unit and ten are 9  and hundred isn't ten clears
      if (bcd_one_out = "1001" and bcd_ten_out = "1001" and bcd_hun_out /= "1001") then
        clear_ctrl(1) <= '1';
        bcd_hun_in <= '1';
      end if;
      -- If unit, ten and hundred are 9  restart counter and BCDs
      if (bcd_one_out = "1000" and bcd_ten_out = "1001" and bcd_hun_out = "1001") then
        overflow <= true;
        clear_ctrl <= "000";
        enable_ctrl <= "000";
      end if;
    end if;

  end process;

end architecture;