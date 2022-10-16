library ieee;
use ieee.numeric_bit.all;
use ieee.math_real.ceil;
use ieee.math_real.log2;

entity calc_tb is
end calc_tb;

architecture tb of calc_tb is
    component calc is
        port(
            clock: in bit;
            reset: in bit;
            instruction: in bit_vector(15 downto 0);
            overflow: out bit;
            q1: out bit_vector(15 downto 0)
        );
    end component;
    signal ck : bit;
    signal reset_in : bit;
    signal instruction_in : bit_vector(15 downto 0);
    signal overflow_out : bit;
    signal q1_out : bit_vector(15 downto 0);

    -- Gerando clock
    constant periodoClock : time := 1 ns;
    begin
        ck <= not ck after periodoClock/2;

        -- Device Umder Test
        DUT: calc port map(ck, reset_in, instruction_in, overflow_out, q1_out);

        p0: process is
        begin
            instruction_in <= "0101001111111111";
            wait for 1 ns;
            instruction_in <= "1111101111111110";
            wait for 1 ns;
            assert q1_out = "0000000000010100" report "erro";
            wait;
        end process;

    end architecture;