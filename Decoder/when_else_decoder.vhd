library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity when_else_decoder is
  port (
    en   : in std_logic;
    input : in std_logic_vector(2 downto 0);
    output : out std_logic_vector(7 downto 0)
  );
end entity;

architecture rtl of when_else_decoder is

begin

  output <= "00000000" when en & input = "0000" else
  "00000001" when en & input = "1000" else
  "00000010" when en & input = "1001" else
  "00000100" when en & input = "1010" else
  "00001000" when en & input = "1011" else
  "00010000" when en & input = "1100" else
  "00100000" when en & input = "1101" else
  "01000000" when en & input = "1110" else
  "10000000" when en & input = "1111" else
  "00000000";
    
end architecture;