--library ieee;
--use ieee.numeric_bit.all;
--
--entity fulladder is
--    port (
--      a, b, cin: in bit;
--      s, cout: out bit
--    );
--   end entity;
--
--architecture structural of fulladder is
--    signal axorb: bit;
--    begin
--        axorb <= a xor b;
--        s <= axorb xor cin;
--        cout <= (axorb and cin) or (a and b);
--    end architecture;

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
                      less when "11",
                      '0' when others;
        overflow <= '1' when a_in = b_in and sum = not(a_in) else
                    '0';
    end architecture; 