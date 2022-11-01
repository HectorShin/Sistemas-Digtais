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

entity somador is
    generic (
        size : natural := 10 
    );
    port (
        a, b : in bit_vector(size-1 downto 0);
        cin: in bit;
        S : out bit_vector (size-1 downto 0);
        cout : out bit
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
            FA_i : fulladder port map(a(i), b(i), temp(i), S(i),temp(i+1));
        end generate;
    end architecture;

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
    component somador
        generic (
            size : natural := 10
        );
        port (
            a, b : in bit_vector(size-1 downto 0);
            cin: in bit;
            S : out bit_vector (size-1 downto 0);
            cout : out bit
        );
    end component;
    signal s_and, s_or, s_a_tratado, s_b_tratado, s_fadd, s_nor, comparador,  s_comparador : bit_vector(size-1 downto 0);
    signal resultado : bit_vector(size-1 downto 0);
    signal zero : bit_vector(size-1 downto 0);
    signal s_cin, s_cout: bit;
    begin
        s_a_tratado <= not(A) when S = "1100" else
                       A;
        s_b_tratado <= not(B) when S = "0110" or S = "1100" or S = "0111" else
                       B;
        s_cin <= '1' when S = "0110" or S = "1100" or S = "0111" else
                 '0';
        soma : somador generic map(size) port map(s_a_tratado, s_b_tratado, s_cin, s_fadd, s_cout);
        zero <= (others=>'0');
        s_and <= s_a_tratado and s_b_tratado;
        s_or <= s_a_tratado or s_b_tratado;
        s_nor <= s_a_tratado and s_b_tratado;
        Co <= s_cout;
        F <= resultado;
        Z <= '1' when resultado = zero else '0';
        --comparador_for: for i in size-2 downto 0 loop
        --    comparador(i) <= '1' when A(i) = '1' and s_b_tratado(i) = '0' else
        --                     '0';
        --end generate;
        --comparador(size-1) <= '0';
        --s_comparador <= bit_vector(to_unsigned(1, size)) when (comparador = zero or (A(size-1) = '1' and s_b_tratado(size-1) = '0')) else
        --                (others => '0');
        s_comparador <= bit_vector(to_unsigned(1, size)) when (to_integer(signed(A)) < to_integer(signed(B))) else
                        (others => '0');
        with S select
            resultado <= s_and when "0000",
                         s_or when "0001",
                         s_fadd when "0010",
                         s_fadd when "0110",
                         s_comparador when "0111",
                         s_nor when "1100",
                         zero when others;
        Ov <= '1' when (s_a_tratado(size-1) = s_b_tratado(size-1) and s_fadd(size-1) = not(s_a_tratado(size-1))) else
              '0';
    end architecture;