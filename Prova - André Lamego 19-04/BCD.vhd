library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity BCD is
  port (
    clk     : in std_logic;
    clear   : in std_logic;
    enable   : in std_logic;
    bcd_out : out std_logic_vector(3 downto 0)  := "0000"  
  );
end entity;

architecture rtl of BCD is
  signal bcd_counter : integer := 0;  
begin

  bcd_out <= std_logic_vector(to_unsigned(bcd_counter, bcd_out'length));

  process (clk, clear)
  begin
    if clear = '1' then
      bcd_counter <= 0;
    elsif rising_edge(clk) then
      if (enable = '1') then
        bcd_counter <=  bcd_counter + 1;
      end if;
    end if;
  end process;

end architecture;
