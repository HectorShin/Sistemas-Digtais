library ieee;
use ieee.numeric_bit.all;

entity fulladder is
    port (
      a, b, cin: in bit;
      s, cout: out bit
    );
   end entity;

architecture structural of fulladder is
    signal axorb: bit;
    begin
        axorb <= a xor b;
        s <= axorb xor cin;
        cout <= (axorb and cin) or (a and b);
    end architecture;

library ieee;
use ieee.numeric_bit.all;

entity alu1bit is
    port (
        a, b, less, cin: in bit;
        result, cout, set, overflow: out bit;
        ainvert, binvert: in bit;
        operation: in bit_vector(1 downto 0)
    );
end entity;

architecture alu1bit_arch of alu1bit is
    component fulladder 
        port (
            a, b, cin: in bit;
            s, cout: out bit
        );
    end component;
    signal a_in, b_in, sum : bit;
    begin
        fa : fulladder port map (a_in, b_in, cin, sum, cout);
        a_in <= a when ainvert = '0' else
                not(a) when ainvert = '1';
        b_in <= b when binvert = '0' else
                not(b) when binvert = '1';
        set <= sum;
        with operation select
            result <= a_in and b_in when "00",
                      a_in or b_in when "01",
                      sum when "10",
                      b when "11",
                      '0' when others;
        overflow <= '1' when a_in = b_in and sum = not(a_in) else
                    '0';
    end architecture;

library ieee;
use ieee.numeric_bit.all;

entity alu is
    generic (
        size: natural := 64
    );
    port (
        A, B: in bit_vector(size-1 downto 0);
        F: out bit_vector(size-1 downto 0);
        S: in bit_vector(3 downto 0);
        Z: out bit;
        Ov: out bit;
        Co: out bit
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
    signal zeros : bit_vector(size-1 downto 0);
    begin
        alu_for : for i in size-1 downto 0 generate
            alu_if : if i = 0 generate
                lsb_alu : alu1bit port map (A(i), B(i), '0', S(2), result(i), couts(i), sum(i), open, S(3), S(2), S(1 downto 0));
            elsif i = size-1 generate
                msb_alu : alu1bit port map (A(i), B(i), '0', couts(i-1), result(i), Co, sum(i), Ov, S(3), S(2), S(1 downto 0));
            elsif i > 0 and i < size-1 generate
                othersb_alu : alu1bit port map (A(i), B(i), '0', couts(i-1), result(i), couts(i), sum(i), open, S(3), S(2), S(1 downto 0));
            end generate;
        end generate;
        F <= result;
        zeros <= (others => '0');
        Z <= '1' when result = zeros else
             '0';
    end architecture;