library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity frequency_divider is
  port (
    clk   : in std_logic;
    ctrl : in std_logic_vector(3 downto 0);
    pulse : out std_logic
  );
end entity;

architecture rtl of frequency_divider is

  signal counter : integer := 0;
  signal limit   : integer;

begin

  limit <= 2 ** to_integer(unsigned(ctrl));

  process (clk)
  begin
    if rising_edge(clk) then
      if (counter = limit) then
        counter <= 0;
        pulse <= '1';
      else
        counter <= counter + 1;
        pulse <= '0';
      end if;
    end if;
  end process;

end architecture;