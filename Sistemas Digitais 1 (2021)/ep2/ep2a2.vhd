library ieee;
use ieee.numeric_bit.all;

entity d_register is
	generic(
		width : natural := 4;
		reset_value : natural := 0
	);
	port(
		clock , reset , load : in bit;
		d : in bit_vector(width-1 downto 0);
		q : out bit_vector(width-1 downto 0)
	);
end d_register;

architecture comportamento of d_register is
begin
	p0: process (clock , reset , load , d) is
	begin
		if (reset = '1') then
			q <= bit_vector(to_unsigned(reset_value,width));
		elsif (load = '1') then
			if (clock'event) and (clock ='1') then
				q <= d;
			end if;
		end if;
	end process;
end architecture;

				