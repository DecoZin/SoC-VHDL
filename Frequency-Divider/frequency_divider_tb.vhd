library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity frequency_divider_tb is
end frequency_divider_tb;

architecture behavior of frequency_divider_tb is

  component frequency_divider is
    port (
      clk   : in std_logic;
      ctrl : in std_logic_vector(3 downto 0);
      pulse : out std_logic
    );
  end component;

  signal CLK: std_logic := '0';
  signal CTRL: std_logic_vector(3 downto 0);
  signal PULSE: std_logic;
  constant CLK_PERIOD: time := 10 ns; 
  signal CLK_GENERATOR: boolean := true;

begin

  frequency_inst: frequency_divider
    port map (
      clk   => clk,
      ctrl => ctrl,
      pulse => pulse
    );

  CLK_PROCESS: process
  begin
    while (CLK_GENERATOR) loop
      CLK <= '0';
    wait for CLK_PERIOD/2;
    CLK <= '1';
    wait for CLK_PERIOD/2;
    end loop;
    wait;
  end process;

  STIMULUS: process
  begin
    wait for CLK_PERIOD * 1;
    CTRL <= "0000";
    wait for CLK_PERIOD * 3;
    CTRL <= "0001";
    wait for CLK_PERIOD * 5;
    CTRL <= "0010";
    wait for CLK_PERIOD * 9;
    CTRL <= "0011";
    wait for CLK_PERIOD * 17;
    CTRL <= "0100";
    wait for CLK_PERIOD * 33;
    CTRL <= "0101";
    wait for CLK_PERIOD * 65;
    CLK_GENERATOR <= false;
    wait;
  end process;
end architecture;