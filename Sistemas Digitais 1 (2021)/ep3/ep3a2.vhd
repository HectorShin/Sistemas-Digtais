library ieee;
use ieee.numeric_bit.all;
use std.textio.all;

entity rom_arquivo is
	port(
		addr : in bit_vector(3 downto 0);
		data : out bit_vector(7 downto 0)
	);
end rom_arquivo;

architecture rom_arquivo_func of rom_arquivo is
	type mem_t is array (0 to 15) of bit_vector(7 downto 0);
	impure function init_mem(nome_arquivo_conteudo_rom : in string) return mem_t is
		file arquivo : text open read_mode is nome_arquivo_conteudo_rom;
		variable linha : line;
		variable temp_bv : bit_vector(7 downto 0);
		variable temp_mem : mem_t;
		begin	
			for i in mem_t'range loop
				readline(arquivo,linha);
				read(linha,temp_bv);
				temp_mem(i) := temp_bv;
			end loop;
			return temp_mem;
		end;
	signal mem: mem_t := init_mem("conteudo_rom_ativ_02_carga.dat");
begin
	data <= mem(to_integer(unsigned(addr)));
end architecture;

	