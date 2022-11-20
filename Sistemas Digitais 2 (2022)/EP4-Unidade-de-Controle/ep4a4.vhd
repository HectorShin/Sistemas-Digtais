library ieee;
use ieee.numeric_bit.all;

entity controlunit is
    port (
        reg2loc: out bit;
        uncondBranch: out bit;
        branch: out bit;
        memRead: out bit;
        memToReg: out bit;
        aluOp: out bit_vector(1 downto 0);
        memWrite: out bit;
        aluSrc: out bit;
        regWrite: out bit;
        opcode: in bit_vector(10 downto 0)
    );
end entity;

architecture controlunit_arch of controlunit is
    signal ldur, stur, cbz, b, r: bit;
    begin
        ldur <= '1' when opcode = "11111000010" else
                '0';
        stur <= '1' when opcode = "11111000000" else
                '0';
        cbz <= '1' when opcode(10 downto 3) = "10110100" else
               '0';
        b <= '1' when opcode(10 downto 5) = "000101" else
             '0';
        r <= '1' when opcode = "10001011000" or opcode = "11001011000" or opcode = "10001010000" or opcode = "10101010000" else
             '0';
        reg2loc <= '1' when stur = '1' or cbz = '1' else
                   '0' when r = '1';
        uncondBranch <= '1' when b = '1' else
                        '0' when ldur = '1' or stur = '1' or cbz = '1' or r = '1';
        branch <= '1' when cbz = '1' else
                  '0' when ldur = '1' or stur = '1' or b = '1' or r = '1';
        memRead <= '1' when ldur = '1' else
                   '0' when stur = '1' or cbz = '1' or b = '1' or r = '1';
        memToReg <= '1' when ldur = '1' else
                    '0' when stur = '1' or cbz = '1' or b = '1' or r = '1';
        aluOp <= "00" when ldur = '1' or stur = '1' else
                 "01" when cbz = '1' else
                 "10" when r = '1';
        memWrite <= '1' when stur = '1' else
                    '0' when ldur = '1' or cbz = '1' or b = '1' or r = '1';
        aluSrc <= '1' when ldur = '1' or stur = '1' else
                  '0' when cbz = '1' or b = '1' or r = '1';
        regWrite <= '1' when ldur = '1' or r = '1' else
                    '0' when stur = '1' or cbz = '1' or b = '1';
    end architecture;