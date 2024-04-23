library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity if_else_decoder is
  port (
    en   : in std_logic;
    input : in std_logic_vector(2 downto 0);
    output : out std_logic_vector(7 downto 0)
  );
end entity;

architecture rtl of if_else_decoder is

begin

  process (en, input)
  begin
    if en = '0' then
      output <= "00000000";
    else
      if input = "000" then
        output <= "00000001";
      elsif input = "001" then
        output <= "00000010";
      elsif input = "010" then
        output <= "00000100";
      elsif input = "011" then
        output <= "00001000";
      elsif input = "100" then
        output <= "00010000";
      elsif input = "101" then
        output <= "00100000";
      elsif input = "110" then
        output <= "01000000";  
      elsif input = "111" then
        output <= "10000000"; 
      else
        output <= "00000000";
      end if;  
    end if;
  end process;

end architecture;