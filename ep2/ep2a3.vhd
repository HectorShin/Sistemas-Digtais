library ieee;
use ieee.numeric_bit.all;

entity fa is
    port (
        op1, op2, cin : in bit;
        s, cout : out bit
    );
end fa;

architecture behavior of fa is
    begin
        s <= (op1 xor op2) xor cin;
        cout <= (op1 and op2) or (op1 and cin) or (op2 and cin);
    end architecture;


library ieee;
use ieee.numeric_bit.all;

entity somador is
    generic (
        op_size : natural := 5
    );
    port (
        op1, op2: in bit_vector(op_size-1 downto 0);
        cin: in bit;
        s, couts : out bit_vector(op_size-1 downto 0)
    );
end somador;

architecture behavior of somador is
    component fa is
        port (
            op1, op2, cin : in bit;
            s, cout : out bit
        );
    end component;
    signal couts_o: bit_vector(op_size-1 downto 0);
    begin
        fas: for i in op_size-1 downto 0 generate
            lsb: if (i = 0) generate
                fa_lsb: fa port map(op1(i), op2(i), cin, s(i), couts_o(i));
            elsif (i > 0) generate
                fa_msb: fa port map(op1(i), op2(i), couts_o(i-1), s(i), couts_o(i));
            end generate;
        end generate;
        couts <= couts_o;
    end architecture;

    
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
    type register_data is array(0 to regn-1) of bit_vector(wordSize-1 downto 0);
    signal registers : register_data;
    begin
        p0: process(clock, reset)
        begin
            if (reset = '1') then
                for i in regn-1 downto 0 loop
                    registers(i) <= (others => '0');
                end loop;
            elsif (clock'event) and (clock = '1') then
                if (regWrite = '1') and (to_integer(unsigned(wr)) /= regn-1) then
                    registers(to_integer(unsigned(wr))) <= d;
                end if;
            end if;
        end process;
        q1 <= registers(to_integer(unsigned(rr1)));
        q2 <= registers(to_integer(unsigned(rr2)));
    end architecture;


library ieee;
use ieee.numeric_bit.all;
use ieee.math_real.ceil;
use ieee.math_real.log2;

entity calc is
    port(
        clock: in bit;
        reset: in bit;
        instruction: in bit_vector(15 downto 0);
        overflow: out bit;
        q1: out bit_vector(15 downto 0)
    );
end calc;

architecture calc_arch of calc is
    component regfile is
        generic(
            regn: natural := 32; -- nesse caso sao 32 registradores
            wordSize: natural := 64 -- nesse caso vale 16 bits
        );
        port(
            clock: in bit;
            reset: in bit;
            regWrite: in bit;
            rr1, rr2, wr: in bit_vector(natural(ceil(log2(real(regn))))-1 downto 0);
            d: in bit_vector(wordSize-1 downto 0);
            q1, q2: out bit_vector(wordSize-1 downto 0)
        );
    end component;
    component somador is
        generic (
            op_size : natural := 16 -- nesse caso vale 16 bits
        );
        port (
            op1, op2 : in bit_vector(op_size-1 downto 0);
            cin: in bit;
            s, couts : out bit_vector(op_size-1 downto 0)
        );
        end component;
    signal op1_reg : bit_vector(4 downto 0); -- registrador em que fica armazenado o operando 1
    signal op2_reg : bit_vector(4 downto 0); -- registrador em que fica armazenado o operando 2
    signal dest_reg : bit_vector(4 downto 0); -- registrador em que fica armazenado o resultado
    signal s_out : bit_vector(15 downto 0); -- resultado da soma
    signal op1_value : bit_vector(15 downto 0); -- valor do operando 1
    signal op2_value_register : bit_vector(15 downto 0); -- valor do operando 2 se opcode for 1
    signal op2_value_immediate : bit_vector(15 downto 0); -- valor do operando 2 se opcode for 0
    signal op2_value : bit_vector(15 downto 0); -- valor do operando 2
    signal couts_o : bit_vector(15 downto 0); -- vetor de carry out
    begin
        registers_file : regfile generic map(32, 16) port map(clock, reset, '1', op1_reg, op2_reg, dest_reg, s_out, op1_value, op2_value_register);
        sum: somador generic map(16) port map(op1_value, op2_value, '0', s_out, couts_o);
        op1_reg <= instruction(9 downto 5); 
        op2_reg <= instruction(14 downto 10);
        dest_reg <= instruction(4 downto 0);
        op2_value_immediate <= "00000000000" & op2_reg when op2_reg(4) = '0' else
                               "11111111111" & op2_reg when op2_reg(4) = '1' else
                                (others => '0');
        op2_value <= op2_value_register when instruction(15) = '1' else
                     op2_value_immediate when instruction(15) = '0' else
                     (others => '0');
        q1 <= s_out;
        overflow <= '1' when op1_value(15) = op2_value(15) and s_out(15) = not op1_value(15);
    end architecture;