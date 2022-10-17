library ieee;
use ieee.numeric_bit.all;

entity ram is
	generic(
		addressSize : natural := 4;
		wordSize : natural := 8
	);
	port(
		ck, wr : in bit;
		addr : in bit_vector(addressSize-1 downto 0);
		data_i : in bit_vector(wordSize-1 downto 0);
		data_o : out bit_vector(wordSize-1 downto 0)
	);
end ram;

architecture ram_func of ram is
	constant tamanho : natural := 2**addressSize;
	type mem_t is array(0 to tamanho-1) of bit_vector(wordSize-1 downto 0);
	signal mem : mem_t;
begin
	behavior : process (ck , wr , addr , data_i) is
	begin
		if wr = '1' then
			if ck'event and ck = '1' then
				mem(to_integer(unsigned(addr))) <= data_i;
			end if;
		elsif wr = '0'then
			data_o <= mem(to_integer(unsigned(addr)));
		end if;
	end process;
end architecture;

			
				
	
	