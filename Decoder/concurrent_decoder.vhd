library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity concurrent_decoder is
  port (
    en   : in std_logic;
    input : in std_logic_vector(2 downto 0);
    output : out std_logic_vector(7 downto 0)
  );
end entity;

architecture rtl of concurrent_decoder is

begin

  output(0) <= en and  (not input(0) and not input(1) and not input(2));
  output(1) <= en and  (not input(0) and not input(1) and  input(2));
  output(2) <= en and  (not input(0) and input(1) and not input(2));
  output(3) <= en and  (not input(0) and input(1) and input(2));
  output(4) <= en and  (input(0) and not input(1) and not input(2));
  output(5) <= en and  (input(0) and not input(1) and input(2));
  output(6) <= en and  (input(0) and input(1) and not input(2));
  output(7) <= en and  (input(0) and input(1) and input(2));

end architecture;