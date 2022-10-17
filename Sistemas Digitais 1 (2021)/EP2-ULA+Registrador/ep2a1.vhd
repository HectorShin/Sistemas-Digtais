library ieee;
use ieee.numeric_bit.all;
entity fa is
  port (
    a,b,cin : in bit;
    s,cout : out bit
    );
end entity fa;
architecture func_fa of fa is
begin
  s <= (a xor b) xor cin;
  cout <= (a and b) or (cin and a) or (cin and b);
end architecture;

library ieee;
use ieee.numeric_bit.all;
entity somador is
    generic (
        size : natural :=8
    );
    port (
        A , B : in bit_vector (size-1 downto 0);
        cin : in bit;
        S : out bit_vector (size-1 downto 0);
        Cout : out bit
    );
end entity somador;

architecture func_somador of somador is
    component fa
            port(
                a,b,cin :in bit; 
                s,cout: out bit
            );
    end component;
    signal temp:bit_vector(size downto 0);
begin
    temp(0) <= cin;
    Cout <= temp(size);
    FAA: for i in 0 to size-1 generate
        FA_i : fa port map(temp(i),a(i),b(i),S(i),temp(i+1));
    end generate;
end architecture;

library ieee;
use ieee.numeric_bit.all;

entity alu is
    generic (
        size : natural :=8
    );
    port (
        A, B : in bit_vector(size-1 downto 0);
        F : out bit_vector(size-1 downto 0);
        S : in bit_vector(2 downto 0);
        Z : out bit;
        Ov : out bit;
        Co : out bit
    );
end entity alu;

architecture func_alu of alu is
    component somador
        generic (
        size : natural :=8
    );
    port (
        A,B: in bit_vector (size-1 downto 0);
        cin: in bit;
        S  : out bit_vector (size-1 downto 0);
        Cout: out bit
    );
    end component;
    signal s_and, s_or , s_not, s_b_tratado, s_fadd : bit_vector(size-1 downto 0);
    signal resultado : bit_vector(size-1 downto 0);
    signal s_inv  : bit_vector(size-1 downto 0);
    signal zero : bit_vector(size-1 downto 0);
    signal s_cin, s_cout: bit;
    begin
        s_b_tratado <= B when S = "001" else
					   not(B);
        s_cin <= '1' when S="100" else
                 '0';
        soma : somador generic map(size) port map(A, s_b_tratado, s_cin, s_fadd, s_cout);
        gen: for i in 0 to size-1 generate
          s_inv(i) <= A(size-1-i);
        end generate;
        zero <= (others=>'0');
        s_and <= A and B;
        s_or <= A or B;
        s_not <= not(A);
        Co <= s_cout when (S = "001" or S="100") else
              '0';
        F <= resultado;
        Z <= '1' when resultado = zero else '0';
        with S select
            resultado <= A when "000",
                         s_fadd when "001",
                         s_and when "010",
                         s_or when "011",
                         s_fadd when "100",
                         s_not when "101",
                         s_inv when "110",
                         B when "111",
                         zero when others;
        Ov <= '1' when (A(size-1) = B(size-1) and s_fadd(size-1) = not(A(size-1)) and S = "001") or (A(size-1) = not(B(size-1)) and s_fadd(size-1) = not(A(size-1)) and S = "100") else '0';
    end architecture;