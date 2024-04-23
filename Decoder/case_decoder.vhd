library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity case_decoder is
  port (
    en   : in std_logic;
    input : in std_logic_vector(2 downto 0);
    output : out std_logic_vector(7 downto 0)
  );
end entity;

architecture rtl of case_decoder is
signal en_in : std_logic_vector(3 downto 0) := en & input;

begin

  process (en, input)
  begin
    case( en_in ) is
    
      when "0000" => 
        output <= "00000000";
      when "1000" => 
        output <= "00000001";
      when "1001" => 
        output <= "00000010";
      when "1010" => 
        output <= "00000100";
      when "1011" => 
        output <= "00001000";
      when "1100" => 
        output <= "00010000";
      when "1101" => 
        output <= "00100000";
      when "1110" => 
        output <= "01000000";
      when "1111" => 
        output <= "10000000";
      when others =>
        output <= "00000000";
    end case ;
  end process;

end architecture;