library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity frequency_counter_tb is
end entity;

architecture behavior of frequency_counter_tb is

  component frequency_counter is
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
  end component;

  constant clk_period : time := 100 ns;
  constant signal_input_period : time := 200 us;
  signal clk_generator : boolean := true;
  
  signal clk   : std_logic := '0'; -- 10 MHz
  signal signal_input : std_logic := '0'; -- 5 kHz - periodo 200us
                                          -- 1ms conta até 5
                                          -- 10ms conta até 50
                                          -- 100ms conta até 500
                                          -- 1s conta até 5000
  signal meas_range   : std_logic_vector(3 downto 0) := "0001"; --1ms
  signal bcd_one : std_logic_vector(3 downto 0);
  signal bcd_ten : std_logic_vector(3 downto 0);
  signal bcd_hun : std_logic_vector(3 downto 0);
  
begin

  frequency_counter_inst: frequency_counter
    port map (
      clk => clk, 
      signal_input  => signal_input, 
      meas_range    => meas_range, 
      bcd_one => bcd_one,
      bcd_ten => bcd_ten,
      bcd_hun => bcd_hun
  );

  CLOCK_GENERATOR: process
  begin
    while (clk_generator) loop
      clk <= '0';
      wait for clk_period/2;
      clk <= '1';
      wait for clk_period/2;
    end loop;
    wait;
  end process;

  SIGNAL_GENERATOR: process
  begin
    while (clk_generator) loop
      signal_input <= '0';
      wait for signal_input_period/2;
      signal_input <= '1';
      wait for signal_input_period/2;
    end loop;
    wait;
  end process;

  STIMULUS: process
  begin
    wait for clk_period;
    meas_range <= "0001"; -- 1ms range
    wait for clk_period*20000; -- Wait 2ms
    meas_range <= "0010"; -- 10ms range
    wait for clk_period*200000; -- Wait 20ms
    meas_range <= "0100"; -- 100ms range
    wait for clk_period*2000000; -- Wait 200ms
    meas_range <= "1000"; -- 1000ms range
    wait for clk_period*20000000; -- Wait 2000ms
    wait;
  end process;

end architecture;