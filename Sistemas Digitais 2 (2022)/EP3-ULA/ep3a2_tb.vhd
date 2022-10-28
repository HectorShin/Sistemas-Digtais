library ieee;
use ieee.std_logic_1164.all;

entity alu_tb is
end entity;

architecture tb of alu_tb is

  -- Componente a ser testado (Device Under Test -- DUT)
  component alu
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
  end component;

  -- Declaração de sinais para conectar o componente a ser testado (DUT)
  --   valores iniciais para fins de simulacao (GHDL ou ModelSim)
  signal A_in:      bit_vector(3 downto 0) := "0000";
  signal B_in:      bit_vector(3 downto 0) := "0000";
  signal S_in:      bit_vector(3 downto 0) := "0000";
  signal F_out:   bit_vector(3 downto 0) := "0000";
  signal Z_out, Ov_out, Co_out:   bit := '0';

  -- Configurações do clock
  signal keep_simulating: std_logic := '0'; -- delimita o tempo de geração do clock
  constant clockPeriod:   time := 20 ns;    -- clock de 50MHz

begin
  -- Gerador de clock: executa enquanto 'keep_simulating = 1', com o período
  -- especificado. Quando keep_simulating=0, clock é interrompido, bem como a 
  -- simulação de eventos

  -- Conecta DUT (Device Under Test)
  dut: alu
      generic map(4)
      port map(
        A=> A_in,
        B=> B_in,
        F=> F_out,
        S=> S_in,
        Z=> Z_out,
        Ov=> Ov_out,
        Co=> Co_out
      );

  -- geracao dos sinais de entrada (estimulos)
  stimulus: process is
  begin

    ---- valores iniciais ----------------
    A_in <= "1101";
    B_in <= "1000";
    S_in <= "0000"; -- Esperado : F = 1000
    wait for 10 ns;
    assert F = "1000" and Z = '0' and Ov = '1' and Co = '1' report "Esperado: F = 1000 and Z = 0 and Ov = 1 and Co = 1 || Obtido: F = "&bin(F)&" and Z = "&bin(Z)&" and Ov = "&bin(Ov)&" and Co = "&bin(Co)&"";
    S_in <= "0001"; -- Esperado : F = 1101
    wait for 10 ns;
    S_in <= "0010"; -- Esperado : F = 0101 ; Ov = 1
    wait for 10 ns;
    S_in <= "0110"; -- Esperado : F = 0101 ; Ov = 0
    wait for 10 ns;
    S_in <= "0111"; -- Esperado : F = 0000
    wait for 10 ns;
    S_in <= "1100"; -- Esperado : F = 0010
    wait for 10 ns;

    A_in <= "0001"; -- 1
    B_in <= "1010"; -- -6
    S_in <= "0000"; -- Esperado : F = 0000
    wait for 10 ns;
    S_in <= "0001"; -- Esperado : F = 1011
    wait for 10 ns;
    S_in <= "0010"; -- Esperado : F = 1011 ; Ov = 0
    wait for 10 ns;
    S_in <= "0110"; -- Esperado : F = 0110 ; Ov = 0
    wait for 10 ns;
    S_in <= "0111"; -- Esperado : F = 0000 
    wait for 10 ns;
    S_in <= "1100"; -- Esperado : F = 0100
    wait for 10 ns;

    A_in <= "0001"; -- 1
    B_in <= "0110"; -- 6
    S_in <= "0000"; -- Esperado : F = 0000
    wait for 10 ns;
    S_in <= "0001"; -- Esperado : F = 0111
    wait for 10 ns;
    S_in <= "0010"; -- Esperado : F = 0111 ; Ov = 0
    wait for 10 ns;
    S_in <= "0110"; -- Esperado : F = 1011 ; Ov = 0
    wait for 10 ns;
    S_in <= "0111"; -- Esperado : F = 0001
    wait for 10 ns;
    S_in <= "1100"; -- Esperado : F = 1000
    wait for 10 ns;

    A_in <= "1010"; -- -6
    B_in <= "0110"; -- 6
    S_in <= "0000"; -- Esperado : F = 0000
    wait for 10 ns;
    S_in <= "0001"; -- Esperado : F = 0111
    wait for 10 ns;
    S_in <= "0010"; -- Esperado : F = 0111 ; Ov = 0
    wait for 10 ns;
    S_in <= "0110"; -- Esperado : F = 1011 ; Ov = 0
    wait for 10 ns;
    S_in <= "0111"; -- Esperado : F = 0001
    wait for 10 ns;
    S_in <= "1100"; -- Esperado : F = 1000
    wait for 10 ns;

assert false report "Fim das simulacoes" severity note;
    keep_simulating <= '0';

    wait; -- fim da simulação: aguarda indefinidamente (não retirar esta linha)
  end process;

end architecture;