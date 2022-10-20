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
use ieee numeric_bit.all;

entity somador is
    generic (
        size : natural := 10
    );
    port (
        a, b : in bit_vector(size-1 downto 0);
        cin: in bit;
        cout : out bit;
    );
end entity;

architecture somador_Arch of somador is
    component fulladder
        port (
            a, b, cin: in bit;
            s, cout: out bit
        );
    end component;
    signal temp : bit_vector(size downto 0);
    begin
        temp(0) <= cin;
        Cout <= temp(size);
        FAA: for i in 0 to size-1 generate
            FA_i : fa port map(a(i), b(i), temp(i), S(i),temp(i+1));
        end generate;
    end architecture;

library ieee;
use ieee.numeric_bit.all

entity alu is
    generic (
        size: natural := 10
    );
    port (
        A , B: in bit_vector(size-1 downto 0); -- inputs
        F: out bit_vector(size-1 downto 0); -- outputs
        S: in bit_vector(3 downto 0); -- op selection
        Z: out bit; -- zero flag
        Ov : out bit; -- overflw flag
        Co: out bit -- caryry out
    );
end entity alu;

architecture alu_arch of alu is
    signal s_and, s_or, s_b_tratado, s_fadd, s_nor, comparador, s_comparador: bit_vector(size-1 downto 0);
    signal resultado : bit_vector(size-1 downto 0);
    signal zero : bit_vector(size-1 downto 0);
    signal s_cin, s_cout: bit;
    begin
        s_b_tratado <= B when S = "0010" else
                        not(B) when S = "0110";
        s_cin <= '1' when S = "0110" else
                 '0';
        soma : somador generic map(size) port map(A, s_b_tratado, s_cin, s_fadd, s_cout);
        zero <= (others=>'0');
        s_and <= A and B;
        s_or <= A or B;
        s_nor <= not s_or;
        Co <= s_cout when (S = "0010" or S="0110") else
                '0';
        F <= resultado;
        Z <= '1' when resultado = zero else '0';
        for i = size-2 downto 0 generate
            comparador(i) <= '1' when A(i) = '1' and B(i) = '0'; else
                             '0';
        end generate;
        s_comparaador <= '1' when (comparador = not zero or (A(size) = '1' and B(size) = '0')) else
                         '0';
        with S select
            resultado <= s_and when "0000",
                         s_or when "0001",
                         s_fadd when "0010",
                         s_fadd when "0110",
        Ov <= '1' when (A(size-1) = B(size-1) and s_fadd(size-1) = not(A(size-1)) and S = "001") or (A(size-1) = not(B(size-1)) and s_fadd(size-1) = not(A(size-1)) and S = "100") else '0';
    end architecture;
    