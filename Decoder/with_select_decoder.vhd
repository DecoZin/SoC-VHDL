library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity with_select_decoder is
  port (
    en   : in std_logic;
    input : in std_logic_vector(2 downto 0);
    output : out std_logic_vector(7 downto 0)
  );
end entity;

architecture rtl of with_select_decoder is
signal en_in : std_logic_vector(3 downto 0) := en & input;

begin

  with en_in select
  output <= "00000000" when "0000",
  "00000001" when "1000",
  "00000010" when "1001",
  "00000100" when "1010",
  "00001000" when "1011",
  "00010000" when "1100",
  "00100000" when "1101",
  "01000000" when "1110",
  "10000000" when "1111",
  "00000000" when others;

end architecture;