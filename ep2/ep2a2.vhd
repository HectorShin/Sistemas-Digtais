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
    type register_file is array(0 to regn-1) of bit_vector(wordSize-1 downto 0);
    signal registers : register_file;
    begin
        register_file: for i in regn-1 downto 0 generate
            last_register_if: if i = 31 generate
                last_register_inst: reg 
                    generic map(wordSize)
                    port map(clock, reset, '0', d);
            end generate;  
            others_registers: if i > 0 generate
                others_registers_inst: reg
                    generic map(wordSize)
                    port map(clock, reset, regWrite, registers(i));
            end generate;
        end generate;
    end architecture;
