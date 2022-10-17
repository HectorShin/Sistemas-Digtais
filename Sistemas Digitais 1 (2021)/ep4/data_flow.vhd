library ieee;
use ieee.numeric_bit.all;

entity data_flow is
	generic(
		addr_s : natural := 16; -- address size in bits
		word_s : natural := 32 -- word size in bits
	);
	port(
		clock , reset : in bit;
		--Memory interface
		memA_addr , memB_addr : out bit_vector(addr_s-1 downto 0);
					memB_wrd  : out bit_vector(word_s-1 downto 0);
		memA_rdd , memB_rdd   : in bit_vector(word_s-1 downto 0);
		--Control Unit Interface
		pc_en , ir_en , sp_en : in bit;
		pc_src , mem_a_addr_src , mem_b_mem_src : in bit;
		mem_b_addr_src , mem_b_wrd_src , alu_a_src , alu_b_src : in bit_vector(1 downto 0);
		alu_shfimm_src , alu_mem_src : in bit;
		alu_op : in bit_vector(2 downto 0);
		instruction : out bit_vector(7 downto 0)
	);
end entity;

architecture structural of data_flow is
	component d_register
	generic(
		width : natural := 4;
		reset_value : natural := 0
	);
	port(
		clock , reset , load : in bit;
		d : in bit_vector(width-1 downto 0);
		q : out bit_vector(width-1 downto 0)
	);
	end component;
	component alu
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
	end component;
	signal pc_o : bit_vector(word_s-1 downto 0);
	signal sp_o : bit_vector(word_s-1 downto 0);
	signal alu_a : bit_vector(word_s-1 downto 0);
	signal alu_b : bit_vector(word_s-1 downto 0);
	signal alu_o : bit_vector(word_s-1 downto 0);
	signal Z , Ov , Co : bit;
	signal ir_signExt : bit_vector(word_s-8 downto 0);
	signal zero : bit_vector (word_s-1 downto 0);
	signal pc : bit_vector(word_s-1 downto 0);
	signal memb_mem : bit_vector (word_s-1 downto 0);
	signal imm_shft : bit_vector(word_s-1 downto 0);
	signal alu_mem : bit_vector(word_s-1 downto 0);
	signal ir : bit_vector(7 downto 0);
	signal ir_i : bit_vector(7 downto 0);
	signal aux : bit_vector(word_s-8 downto 0);
	constant reset_v : natural := (2**addr_s);
	
begin
	pc_register : d_register generic map(word_s , 0) port map(clock , reset , pc_en , pc , pc_o);
	sp_register : d_register generic map(word_s , reset_v-8) port map(clock , reset , sp_en , alu_o , sp_o);
	ir_register : d_register generic map(8 , 0) port map(clock, reset , ir_en , ir_i , ir);
	ula : alu generic map(word_s) port map(alu_a , alu_b , alu_o , alu_op , Z , Ov , Co);
	ir_i <= memA_rdd(7 downto 0);
	ir_signExt <= (others => '0') when ir(6) = '0' else
				  aux;
	aux <= (others => '1');
	zero <= (others => '0');
	instruction <= ir;
	with pc_src select
		pc <= alu_o when '0',
			  memA_rdd when '1',
			  zero when others;
	with mem_a_addr_src select
		memA_addr <= pc_o(addr_s-1 downto 0) when '1',
					 sp_o(addr_s-1 downto 0) when '0',
					 zero(addr_s-1 downto 0) when others;
	with mem_b_addr_src select
		memB_addr <= sp_o(addr_s-1 downto 0) when "00",
					 memA_rdd(addr_s-1 downto 0) when "01",
					 alu_o(addr_s-1 downto 0) when "10",
					 alu_o(addr_s-1 downto 0) when "11",
					 zero(addr_s-1 downto 0) when others;
	with mem_b_wrd_src select
		memB_wrd <= alu_o when "00",
					memb_mem when "01",
					sp_o when "10",
					ir_signExt & ir(6 downto 0) when "11",--signExt(ir[6:0]) when "11",
					zero when others;
	with mem_b_mem_src select
		memb_mem <= memA_rdd when '0',
					memB_rdd when '1',
					zero when others;
	with alu_a_src select
		alu_a <= pc_o when "00",
				 sp_o when "01",
				 memA_rdd when "10",
				 memA_rdd when "11",
				 zero when others;
	with alu_b_src select
		alu_b <= imm_shft when "00",
				 alu_mem when "01",
				 zero(word_s-1 downto 10) & ir(4 downto 0) & zero(4 downto 0) when "10",--ir[4:0]<<5 when "10",
				 zero(word_s-1 downto 7) & not(ir(4)) & ir(3 downto 0) & zero(1 downto 0) when "11",--not(ir[4]&ir[3:0]<<2 when "11",
				 zero when others;
	with alu_shfimm_src select
		imm_shft <= zero(word_s-1 downto 1) & '1' when '0',
					zero(word_s-1 downto 3) & "100" when '1',
					zero when others;
	with alu_mem_src select
		alu_mem <= memA_rdd(word_s-8 downto 0) & ir(6 downto 0) when '0', --memA_rdd<<7 | IR[6:0] when '0',
				   memB_rdd when '1',
				   zero when others;
end architecture;

					 