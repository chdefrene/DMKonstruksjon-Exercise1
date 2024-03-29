library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.defs.ALL;

entity DataPath is
	generic (
		ADDR_WIDTH : integer := 8;	
		DATA_WIDTH : integer := 32;
		REG_ADDR_WIDTH : integer := 5;
		IMMEDIATE_WIDTH : integer := 16
	);
	port (
		clk, reset : in std_logic;
		read_reg_1_in, read_reg_2_in, write_reg_in : in std_logic_vector(REG_ADDR_WIDTH-1 downto 0);
		immediate_in : in std_logic_vector(IMMEDIATE_WIDTH-1 downto 0);
		read_data_in : in std_logic_vector(DATA_WIDTH-1 downto 0);
		alu_result_in : in std_logic_vector(DATA_WIDTH-1 downto 0);
		-- Control signals
		alu_src_in : in alu_src_t;
		reg_src_in : in reg_src_t;
		reg_write_in : in boolean;
		alu_1_out, alu_2_out : out std_logic_vector(DATA_WIDTH-1 downto 0);  
		write_data_out : out std_logic_vector(DATA_WIDTH-1 downto 0)
	);
end DataPath;

architecture Behavioral of DataPath is

	type register_file_t is array(31 downto 0) of std_logic_vector(DATA_WIDTH-1 downto 0);

	signal register_file : register_file_t;
	signal reg_write_data : std_logic_vector(DATA_WIDTH-1 downto 0);
	

begin

	-- Handle register updates
	process (clk, reset, reg_write_in) is begin
			if reset = '1' then
				register_file <= (others => (others => '0'));
			elsif rising_edge(clk) and reg_write_in then
				register_file(to_integer(unsigned(write_reg_in))) <= reg_write_data;
			end if;
	end process;

	reg_write_data <= read_data_in when reg_src_in = REG_SRC_MEMORY else alu_result_in;

	-- Outputs for ALU and memory
	alu_1_out <= register_file(to_integer(unsigned(read_reg_1_in)));
	write_data_out <= register_file(to_integer(unsigned(read_reg_2_in)));
	with alu_src_in select alu_2_out <=
		register_file(to_integer(unsigned(read_reg_2_in))) when ALU_SRC_REGISTER,
		std_logic_vector(resize(signed(immediate_in), DATA_WIDTH)) when others;
	
end Behavioral;

