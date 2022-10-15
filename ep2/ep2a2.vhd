library ieee;
use ieee.numeric_bit.all;
use ieee.math_real.ceil;
use ieee.math_real.log2;

entity regfile is
    generic(
        regn: natural := 32;
        wordSize: natural := 64
    );
    port(
        clock: in bit;
        reset: in bit;
        regWrite: in bit;
        rr1, rr2, wr: in bit_vector(natural(ceil(log2(real(regn))))-1 downto 0);
        d: in bit_vector(wordSize-1 downto 0);
        q1, q2: out bit_vector(wordSize-1 downto 0)
    );
end regfile;

architecture regfile_arch of regfile is
    component reg is
        generic (
            wordSize: natural := 4
        );
        port (
            clock: in bit;
            reset: in bit;
            load: in bit;
            d: in bit_vector(wordSize-1 downto 0);
            q: out bit_vector(wordSize-1 downto 0)
        );
    end component;
    type register_data is array(0 to regn-1) of bit_vector(wordSize-1 downto 0);
    signal registers_in : register_data;
    signal registers_out : register_data;
    begin
        registers_in(to_integer(unsigned(wr))) <= d;
        q1 <= registers_out(to_integer(unsigned(rr1)));
        q2 <= registers_out(to_integer(unsigned(rr2)));
        register_file: for i in regn-1 downto 0 generate
            last_register_if: if i = regn-1 generate
                last_register_inst: reg 
                    generic map(wordSize)
                    port map(clock, reset, '0', registers_in(i), registers_out(i));
            end generate;
            others_registers: if i >= 0 generate
                others_registers_inst: reg
                    generic map(wordSize)
                    port map(clock, reset, regWrite, registers_in(i), registers_out(i));
            end generate;
        end generate;
    end architecture;
