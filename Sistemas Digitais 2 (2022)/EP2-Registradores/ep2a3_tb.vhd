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
            instruction_in <= "0000101111100010"; -- Soma imediato 2 com X31 (sempre vale 0) e armazena em X2
            wait for 1 ns;
            instruction_in <= "0000011111100001"; -- Soma imediato 1 com X31 (sempre vale 0) e armazena em X1
            wait for 1 ns;
            instruction_in <= "1000100000100000"; -- Soma X1 com X2 e armazena em X0
			wait for 1 ns;
			instruction_in <= "0000000000000011"; -- Soma 0 com X0 (que vale 3) e armazena em X3
			wait for 0.75 ns;
			instruction_in <= "1111110000100100"; -- Soma X31 (sempre vale 0) com X1 (que vale 1) e armazena em X4
			wait for 0.25 ns;
			instruction_in <= "1000100001000101"; -- Soma X2 com X2 (que vale 2) e armazena em X5
			wait for 1 ns;
			instruction_in <= "0001000000111110";
			wait for 1 ns;
			reset_in <= '1';
			wait for 0.75 ns;
			reset_in <= '0';
			wait for 0.25 ns;
			instruction_in <= "0000001111011111";
			wait for 1 ns;
			instruction_in <= "0000101111100010";
			wait for 1 ns;
			instruction_in <= "0111111111100001";
			wait for 1 ns;
			instruction_in <= "1000100000100011";
			wait for 1 ns;
			instruction_in <= "0000000001111111";
            wait;
        end process;

    end architecture;
