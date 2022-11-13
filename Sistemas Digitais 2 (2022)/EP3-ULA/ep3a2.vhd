library ieee;
use ieee.numeric_bit.all;

entity alu is
    generic (
        size: natural := 10
    );
    port (
        A , B: in bit_vector(size-1 downto 0); -- inputs
        F: out bit_vector(size-1 downto 0); -- outputs
        S: in bit_vector(3 downto 0); -- op selection
        Z: out bit; -- zero flag
        Ov : out bit; -- overflow flag
        Co: out bit -- carry out
    );
end entity alu;

architecture alu_arch of alu is
    component alu1bit
        port (
            a, b, less, cin: in bit;
            result, cout, set, overflow: out bit;
            ainvert, binvert: in bit;
            operation: in bit_vector(1 downto 0)
        );
    end component;
    signal couts, sum, result : bit_vector(size-1 downto 0);
    signal slt : bit;
    signal zeros : bit_vector(size-1 downto 0);
    begin
        alu_for : for i in size-1 downto 0 generate
            alu_if : if i = 0 generate
                lsb_alu : alu1bit port map (A(i), B(i), slt, S(2), result(i), couts(i), sum(i), open, S(3), S(2), S(1 downto 0));
            elsif i = size-1 generate
                msb_alu : alu1bit port map (A(i), B(i), '0', couts(i-1), result(i), Co, sum(i), Ov, S(3), S(2), S(1 downto 0));
            elsif i > 0 and i < size-1 generate
                othersb_alu : alu1bit port map (A(i), B(i), '0', couts(i-1), result(i), couts(i), sum(i), open, S(3), S(2), S(1 downto 0));
            end generate;
        end generate;
        slt <= sum(size-1);
        F <= result;
        zeros <= (others => '0');
        Z <= '1' when result = zeros else
             '0';
    end architecture;