library ieee;
use ieee.numeric_bit.all;
use std.textio.all;

entity rom_arquivo_generica is
	generic(
		addressSize : natural := 4;
		wordSize : natural := 8;
		datFileName : string := "rom.dat"
	);
	port(
		addr : in bit_vector(addressSize-1 downto 0);
		data : out bit_vector(wordSize-1 downto 0)
	);
end rom_arquivo_generica;

architecture rom_func of rom_arquivo_generica is
	constant tamanho : natural := 2**addressSize;
	type mem_t is array(0 to tamanho-1) of bit_vector(wordSize-1 downto 0);
	impure function init_mem(nome_arquivo_conteudo_rom : in string) return mem_t is
		file arquivo : text open read_mode is nome_arquivo_conteudo_rom;
		variable linha : line;
		variable temp_bv : bit_vector(wordSize-1 downto 0);
		variable temp_mem : mem_t;
	begin
		for i in mem_t'range loop
			readline(arquivo,linha);
			read(linha,temp_bv);
			temp_mem(i) := temp_bv;
		end loop;
		return temp_mem;
	end;
	constant mem : mem_t := init_mem(datFileName);
begin
	data <= mem(to_integer(unsigned(addr)));
end architecture;
	