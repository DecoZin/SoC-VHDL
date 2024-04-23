library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity digital_watch_tb is
end entity;

architecture behavior of digital_watch_tb is

  component digital_watch is
    port (
    -- Inputs
    clk     : in std_logic; -- 1 MHz
    button1 : in std_logic;
    button2 : in std_logic;
    -- Outputs
    hours   : out std_logic_vector(4 downto 0);
    minutes : out std_logic_vector(5 downto 0);
    seconds : out std_logic_vector(5 downto 0);
    bip     : out std_logic
  );
  end component;

  -- Inputs
  signal clk     : std_logic := '0'; -- 1 MHz
  signal button1 : std_logic := '0';
  signal button2 : std_logic := '0';

  -- Outputs
  signal hours   : std_logic_vector(4 downto 0);
  signal minutes : std_logic_vector(5 downto 0);
  signal seconds : std_logic_vector(5 downto 0);
  signal bip     : std_logic;

  -- Clock signals
  constant clk_period : time := 1 us;
  signal clk_generator : boolean := true;  

  -- Constants to skip time
  constant clk_to_sec : integer := 1000000;
  constant clk_to_min : integer := 60000000;
  constant clk_to_hour : integer := 3600000000;
      

begin

  watch_inst: digital_watch
    port map (
      clk     => clk,
      button1 => button1,
      button2 => button2,
      hours   => hours,
      minutes => minutes,
      seconds => seconds,
      bip     => bip      
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

  STIMULUS: process
  begin
    wait for clk_period*;

  end process;

end architecture;