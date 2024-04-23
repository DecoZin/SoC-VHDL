library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity ALU is
  port (
    A    : in std_logic_vector (3 downto 0);
    B    : in std_logic_vector (3 downto 0);
    S    : in std_logic_vector (2 downto 0);
    F    : out std_logic_vector (3 downto 0);
    Cin  : in std_logic;
    Cout : out std_logic;
    OVR  : out std_logic
  );
end ALU;

architecture rtl of ALU is
constant CLEAR : std_logic_vector(2 downto 0) := "000";
constant B_minus_A : std_logic_vector(2 downto 0) := "001";
constant A_minus_B : std_logic_vector(2 downto 0) := "010";
constant A_plus_B : std_logic_vector(2 downto 0) := "011";
constant A_xor_B : std_logic_vector(2 downto 0) := "100";
constant A_or_B : std_logic_vector(2 downto 0) := "101";
constant A_and_B : std_logic_vector(2 downto 0) := "110";
constant PRESET : std_logic_vector(2 downto 0) := "111";

signal signed_A: signed(A'high downto A'low) := signed(A);
signal signed_B: signed(B'high downto B'low) := signed(B);

begin

  process (S)
  begin

    case( S ) is
    
      when CLEAR =>
        F <= "0000";

      when B_minus_A =>
      if Cin = '1' then
        F <= std_logic_vector(signed_B - signed_A);
      end if;

      when A_minus_B =>
      if Cin = '1' then
        F <= std_logic_vector(signed_A - signed_B);
      end if;

      when A_plus_B =>
      if Cin = '0' then
        F <= std_logic_vector(signed_A + signed_B);
      end if;

      when A_xor_B =>
        F(0) <= A(0) xor B(0);
        F(1) <= A(0) xor B(1);
        F(2) <= A(0) xor B(2);
        F(3) <= A(0) xor B(3);

      when A_or_B =>
        F(0) <= A(0) or B(0);
        F(1) <= A(0) or B(1);
        F(2) <= A(0) or B(2);
        F(3) <= A(0) or B(3);

      when A_and_B =>
        F(0) <= A(0) and B(0);
        F(1) <= A(0) and B(1);
        F(2) <= A(0) and B(2);
        F(3) <= A(0) and B(3);

      when PRESET =>
        F <= "1111";
    
      when others =>
        F <= "0000";
    
    end case ;
    
  end process;
  

end architecture;