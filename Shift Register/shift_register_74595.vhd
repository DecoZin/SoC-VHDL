library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity shift_register_74595 is
  port (
    SHCP  : in std_logic;
    STCP  : in std_logic;
    OE    : in std_logic;
    MR    : in std_logic;
    DS    : in std_logic;
    Q7S   : out std_logic;
    Qn    : out std_logic_vector(7 downto 0)
    
  );
end entity;

architecture rtl of shift_register_74595 is

  signal registers : std_logic_vector(7 downto 0) := "00000000";

begin
 Qn <= registers;
  process (SHCP, STCP, MR)
  begin
    if (MR = '0') then
      registers <= "00000000";
      if (OE ='0') then
        if (rising_edge(STCP)) then
          Q7S <= '0';
          Qn  <= "00000000";
        else
          Q7S <= '0';
        end if;
      else
        Q7S <= '0';
        Qn  <= "ZZZZZZZZ"; -- High Impedance
      end if;
    elsif (rising_edge(SHCP) and OE = '0') then
      Q7S <= registers(6);
      if (rising_edge(STCP)) then
        registers <= registers(6 downto 0) & DS;
      end if;
    elsif  (rising_edge(STCP)) then
      registers <= registers(6 downto 0) & DS;
    end if;
  end process;

end architecture;