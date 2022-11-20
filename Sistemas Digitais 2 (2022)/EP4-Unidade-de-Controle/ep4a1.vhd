library ieee;
use ieee.numeric_bit.all;

entity signExtend is
    port (
        i: in bit_vector(31 downto 0);
        o: out bit_vector(63 downto 0)
    );
end signExtend;

architecture signExtend_arch of signExtend is
    begin
        o <= (63 downto 19 => i(23)) & i(23 downto 5) when i(31 downto 24) = "10110100" else
             (63 downto 26 => i(25)) & i(25 downto 0) when i(31 downto 26) = "000101" else
             (63 downto 9 => i(20)) & i(20 downto 12) when i(31 downto 21) = "11111000010" or i(31 downto 21) = "11111000000" else
             (others => '0');
    end architecture;