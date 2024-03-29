LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.defs.ALL;


ENTITY tb_Control IS
END tb_Control;

ARCHITECTURE behavior OF tb_Control IS
	constant ADDR_WIDTH : integer := 8;
	constant DATA_WIDTH : integer := 32;
	constant REG_ADDR_WIDTH : integer := 5;
	constant IMMEDIATE_WIDTH : integer := 16;

	-- Component Declaration for the Unit Under Test (UUT)
	COMPONENT Control
		generic (
			ADDR_WIDTH : integer := 8;
			DATA_WIDTH : integer := 32;
			REG_ADDR_WIDTH : integer := 5;
			IMMEDIATE_WIDTH : integer := 16
		);
		port (
			clk, reset, enable : in std_logic;
			instruction_in : in std_logic_vector(DATA_WIDTH-1 downto 0);
			alu_control_out : out alu_operation_t;
			alu_shamt_out : out std_logic_vector(REG_ADDR_WIDTH-1 downto 0);
			read_reg_1_out, read_reg_2_out, write_reg_out : out std_logic_vector(REG_ADDR_WIDTH-1 downto 0);
			pc_write_out, branch_out, jump_out, reg_write_out, mem_write_out : out boolean;
			reg_src_out : out reg_src_t;
			alu_src_out : out alu_src_t
		);
  END COMPONENT;

  --Inputs
	signal clk : std_logic := '0';
	signal reset : std_logic := '0';
	signal enable : std_logic := '1';
	signal instruction_in : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');

	--Outputs
	signal alu_control_out : alu_operation_t;
	signal alu_shamt_out : std_logic_vector(REG_ADDR_WIDTH-1 downto 0) := (others => '0');
	signal read_reg_1_out, read_reg_2_out, write_reg_out : std_logic_vector(REG_ADDR_WIDTH-1 downto 0) := (others => '0');
	signal pc_write_out, branch_out, jump_out, reg_write_out, mem_write_out : boolean;
	signal reg_src_out : reg_src_t;
	signal alu_src_out : alu_src_t;

	-- Clock period definitions
	constant clk_period : time := 10 ns;


	-- Test instructions
	constant INSTR_LOAD : std_logic_vector(DATA_WIDTH-1 downto 0)  := "100011" & "11100" & "00011" & x"0010";
	constant INSTR_STORE : std_logic_vector(DATA_WIDTH-1 downto 0) := "101011" & "11100" & "00011" & x"0010";
	constant INSTR_ADD : std_logic_vector(DATA_WIDTH-1 downto 0)   := "000000" & "10000" & "01000" & "00100" & "00010" & "100000";
	constant INSTR_ADDI : std_logic_vector(DATA_WIDTH-1 downto 0)  := "001000" & "10000" & "01000" & x"0010";
	constant INSTR_SUB : std_logic_vector(DATA_WIDTH-1 downto 0)   := "000000" & "10000" & "01000" & "00100" & "00010" & "100010";
	constant INSTR_AND : std_logic_vector(DATA_WIDTH-1 downto 0)   := "000000" & "10000" & "01000" & "00100" & "00010" & "100100";
	constant INSTR_ANDI : std_logic_vector(DATA_WIDTH-1 downto 0)  := "001100" & "10000" & "01000" & x"0010";
	constant INSTR_OR : std_logic_vector(DATA_WIDTH-1 downto 0)    := "000000" & "10000" & "01000" & "00100" & "00010" & "100101";
	constant INSTR_ORI : std_logic_vector(DATA_WIDTH-1 downto 0)   := "001101" & "10000" & "01000" & x"0010";
	constant INSTR_SLT : std_logic_vector(DATA_WIDTH-1 downto 0)   := "000000" & "10000" & "01000" & "00100" & "00010" & "101010";
	constant INSTR_SLTI : std_logic_vector(DATA_WIDTH-1 downto 0)  := "001010" & "10000" & "01000" & x"0010";
	constant INSTR_SLL : std_logic_vector(DATA_WIDTH-1 downto 0)   := "000000" & "10000" & "01000" & "00100" & "00010" & "000000";
	constant INSTR_LUI : std_logic_vector(DATA_WIDTH-1 downto 0)   := "001111" & "10000" & "01000" & x"0010";
	constant INSTR_BEQ : std_logic_vector(DATA_WIDTH-1 downto 0)   := "000100" & "10000" & "01000" & x"0010";
	constant INSTR_J : std_logic_vector(DATA_WIDTH-1 downto 0)     := "000010" & "00" & x"000000";


BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut: Control PORT MAP (
		clk => clk,
		reset => reset,
		enable => enable,
		instruction_in => instruction_in,
		alu_control_out => alu_control_out,
		alu_shamt_out => alu_shamt_out,
		read_reg_1_out => read_reg_1_out,
		read_reg_2_out => read_reg_2_out,
		write_reg_out => write_reg_out,
		pc_write_out => pc_write_out,
		branch_out => branch_out,
		jump_out => jump_out,
		reg_write_out => reg_write_out,
		alu_src_out => alu_src_out,
		reg_src_out => reg_src_out,
		mem_write_out => mem_write_out
	);

	-- Clock process definitions
	clk_process: process
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;




	-- Stimulus process
	stim_proc: process

		procedure AssertFetchState is
		begin
			assert pc_write_out = false
				report "pc_write_out should be false when in fetch state"
				severity failure;
			assert reg_write_out = false
				report "reg_write_out should be false when in fetch state"
				severity failure;
			assert mem_write_out = false
				report "mem_write_out should be false when in fetch state"
				severity failure;
			assert read_reg_1_out = instruction_in(25 downto 21)
				report "read_reg_1_out should be instruction_in[25-21]"
				severity failure;
			assert read_reg_2_out = instruction_in(20 downto 16)
				report "read_reg_2_out should be instruction[20-16]"
				severity failure;
		end AssertFetchState;


		procedure AssertExecuteState is
		begin
			if instruction_in(31) = '0' then
				assert pc_write_out = true
					report "pc_write_out should be true in execute state"
					severity failure;
			else
				assert pc_write_out = false
					report "pc_write_out should be false in execute state"
					severity failure;
			end if;
		end AssertExecuteState;


		procedure AssertStallState is
		begin
			assert pc_write_out = true
				report "pc_write_out should be true in stall state"
				severity failure;
		end AssertStallState; 


		procedure AssertALUInstruction(
			alu_operation : alu_operation_t) is
		begin
			-- Reg write enable
			assert reg_write_out = true
				report "reg_write_out should be true to write back data from ALU result"
				severity failure;

			-- ALU operation
			assert alu_control_out = alu_operation
				report "alu_control_out is not set according to instruction"
				severity failure;

			-- MemToReg
			assert reg_src_out = REG_SRC_ALU
				report "reg_src_out should be alu to write back data from ALU result"
				severity failure;
		 
			-- Branch signal should not be set
			assert branch_out = false
				report "branch_out should be false for writeback instructions"
				severity failure;

			-- Jump signal should not be set
			assert jump_out = false
				report "jump_out should be false for writeback instructions"
				severity failure;

		end AssertALUInstruction;


		procedure AssertRTypeInstruction is
		begin
			-- Write reg 
			assert write_reg_out = instruction_in(15 downto 11)
				report "write_reg_out should be instruction_in[15-11] for R type instruction"
				severity failure;


			-- ALU src
			assert alu_src_out = ALU_SRC_REGISTER
				report "alu_src_out should be '0' to select register rt instead of immediate value"
				severity failure;

			-- SHAMT should always be put through on R type instruction
			assert alu_shamt_out = instruction_in(10 downto 6)
				report "alu_shamt_out should always be put through on R type instructions"
				severity failure;
		end AssertRTypeInstruction;


		procedure AssertITypeInstruction is
		begin
			assert write_reg_out = instruction_in(20 downto 16)
				report "write_reg_out should be instruction_in[20-16] for I type instruction"
				severity failure;
			-- ALU src
			assert alu_src_out = ALU_SRC_IMMEDIATE
				report "alu_src_out should be '1' to select immediate value instead of register rt"
				severity failure;
		end AssertITypeInstruction;


	begin

		-- hold reset state for 100 ns
		reset <= '1';
		wait for 100 ns;
		reset <= '0';

		-- Processor starts after first clock tick
		wait for clk_period;

		-- Control should be in fetch state
		AssertFetchState;

		--- LOAD instruction ---
		report "Testing LOAD instruction";
		instruction_in <= INSTR_LOAD;
		wait for clk_period;

		-- Control should now be in execute state
		AssertExecuteState;

		-- Branch signal should not be set
		assert branch_out = false
			report "branch_out should be false for LOAD instructions"
			severity failure;

		-- Jump signal should not be set
		assert jump_out = false
			report "jump_out should be false for LOAD instructions"
			severity failure;

		-- Check signals for load instruction
		assert reg_write_out = false
			report "reg_write_out should be false for LOAD instruction"
			severity failure;

		-- ALU should be rs + imm
		assert alu_src_out = ALU_SRC_IMMEDIATE
			report "alu_src_out should be immediate for LOAD instruction to select immediate value for the ALU"
			severity failure;

		-- ALU control should be ADD
		assert alu_control_out = ALU_ADD
			report "alu_contorl_out should be ALU_ADD for LOAD instruction"
			severity failure;

		-- Mem Write should be off, since we are not writing any new values 
		assert mem_write_out = false
			report "mem_write_out should be false for LOAD instruction to prevent writing to data memory"
			severity failure;


		-- Wait a clock cycle
		wait for clk_period;


		-- Should now be in stall state
		AssertStallState;

		-- Mem to reg enable
		assert reg_src_out = REG_SRC_MEMORY
			report "reg_src_out should be memory for LOAD instruction in stall state to write the correct value in the register"
			severity failure;

		-- Reg write enable
		assert reg_write_out = true
			report "reg_write_out should be true for LOAD instruction in stall state to write the value in the register"
			severity failure;

			assert write_reg_out = instruction_in(20 downto 16)
				report "write_reg_out should be instruction_in[20-16] for LOAD instruction"
				severity failure;

		-- Mem write disable
		assert mem_write_out = false
			report "mem_write_out should be false for LOAD instruction in stall state to prevent writing to data memory"
		severity failure;

		--- Done with LOAD instruction
		report "LOAD instruction passed";


		wait for clk_period;


		--- Test STORE instruction
		report "Testing STORE instruction";

		-- Should now be in fetch state
		AssertFetchState;


		-- Instruction from memory changes to a STORE instruction
		instruction_in <= INSTR_STORE;

		wait for clk_period;

		-- Should now be in execute state
		AssertExecuteState;

		-- Branch signal should not be set
		assert branch_out = false
			report "branch_out should be false for STORE instructions"
			severity failure;

		-- Jump signal should not be set
		assert jump_out = false
			report "jump_out should be false for STORE instructions"
			severity failure;

		-- Check signals for STORE instruction
		assert reg_write_out = false
			report "reg_write_out should be false for STORE instruction"
			severity failure;

		-- ALU should be rs + imm
		assert alu_src_out = ALU_SRC_IMMEDIATE
			report "alu_src_out should be immediate for STORE instruction to select immediate value for the ALU"
			severity failure;

		-- ALU control should be ADD
		assert alu_control_out = ALU_ADD
			report "alu_control_out should be ALU_ADD for STORE instruction"
			severity failure;


		wait for clk_period;

		-- Should now be in stall state
		AssertStallState;

		-- Reg write should still be 0
		assert reg_write_out = false
			report "reg_write_out should be false for STORE instruction in stall state"
			severity failure;

		-- Mem write should still be 1
		assert mem_write_out = true
			report "mem_write_out should be true for STORE instruction in stall state"
			severity failure;

		-- Done with STORE instruction
		report "STORE instruction passed";


		wait for clk_period;

		-- instruction_in should now change
		instruction_in <= INSTR_ADD;


		--- Testing R type and I type instructions ---

		--- ADD (R type) ---
		-- set instruction and wait for clk_period already done
		AssertFetchState;
		wait for clk_period;
		AssertExecuteState;
		AssertRTypeInstruction;
		AssertALUInstruction(ALU_ADD);
		report "ADD instruction passed";


		--- ADDI (I type) ---
		instruction_in <= INSTR_ADDI;
		wait for clk_period;
		AssertFetchState;
		wait for clk_period;
		AssertExecuteState;
		AssertITypeInstruction;
		AssertALUInstruction(ALU_ADD);
		report "ADDI instruction passed";


		--- SUB (R type) ---
		instruction_in <= INSTR_SUB;
		wait for clk_period;
		AssertFetchState;
		wait for clk_period;
		AssertExecuteState;
		AssertRTypeInstruction;
		AssertALUInstruction(ALU_SUB);
		report "SUB instruction passed";


		--- AND (R type) ---
		instruction_in <= INSTR_AND;
		wait for clk_period;
		AssertFetchState;
		wait for clk_period;
		AssertExecuteState;
		AssertRTypeInstruction;
		AssertALUInstruction(ALU_AND);
		report "AND instruction passed";


		--- ANDI (I type) ---
		instruction_in <= INSTR_ANDI;
		wait for clk_period;
		AssertFetchState;
		wait for clk_period;
		AssertExecuteState;
		AssertITypeInstruction;
		AssertALUInstruction(ALU_AND);
		report "ANDI instruction passed";


		--- OR (R type) ---
		instruction_in <= INSTR_OR;
		wait for clk_period;
		AssertFetchState;
		wait for clk_period;
		AssertExecuteState;
		AssertRTypeInstruction;
		AssertALUInstruction(ALU_OR);
		report "OR instruction passed";


		--- ORI (I type) ---
		instruction_in <= INSTR_ORI;
		wait for clk_period;
		AssertFetchState;
		wait for clk_period;
		AssertExecuteState;
		AssertITypeInstruction;
		AssertALUInstruction(ALU_OR);
		report "ORI instruction passed";


		--- SLT (R type) ---
		instruction_in <= INSTR_SLT;
		wait for clk_period;
		AssertFetchState;
		wait for clk_period;
		AssertExecuteState;
		AssertRTypeInstruction;
		AssertALUInstruction(ALU_SLT);
		report "SLT instruction passed";


		--- SLTI (I type) ---
		instruction_in <= INSTR_SLTI;
		wait for clk_period;
		AssertFetchState;
		wait for clk_period;
		AssertExecuteState;
		AssertITypeInstruction;
		AssertALUInstruction(ALU_SLT);
		report "SLTI instruction passed";


		--- SLL (R type) ---
		instruction_in <= INSTR_SLL;
		wait for clk_period;
		AssertFetchState;
		wait for clk_period;
		AssertExecuteState;
		AssertRTypeInstruction;
		report "SLL instruction passed";

		--- LUI (I type) ---
		instruction_in <= INSTR_LUI;
		wait for clk_period;
		AssertFetchState;
		wait for clk_period;
		AssertExecuteState;
		AssertITypeInstruction;
		assert unsigned(alu_shamt_out) = 16
			report "alu_shamt_out for LUI should be set to 16"
			severity failure;
		report "LUI instruction passed";


		--- Test BEQ instruction ---
		instruction_in <= INSTR_BEQ;
		wait for clk_period;
		AssertFetchState;
		wait for clk_period;
		AssertExecuteState;

		-- reg write 0
		assert reg_write_out = false
			report "reg_write_out should be false for BEQ instruction to prevent data from ALU or memory to be written to register"
			severity failure;

		-- ALU src 0
		assert alu_src_out = ALU_SRC_REGISTER
			report "alu_src_out should be register for BEQ instruction to select rt instead of immediate"
			severity failure;

		-- ALU operation ALU_SUB
		assert alu_control_out = ALU_SUB
			report "alu_control_out should be ALU_SUB for BEQ instruction to compare registers rs and rt"
			severity failure;

		-- mem write 0
		assert mem_write_out = false
			report "mem_write_out should be false for BEQ instruction to prevent data being written to memory"
			severity failure;

		-- branch enable
		assert branch_out = true
			report "branch_out should be true on BEQ instruction"
			severity failure;

		-- jump disable
		assert jump_out = false
			report "jump_out should be false on BEQ instruction"
			severity failure;

		-- Done with BEQ instruction
		report "BEQ instruction passed";




		--- Test J instruction (JUMP) ---
		instruction_in <= INSTR_J;
		wait for clk_period;
		AssertFetchState;
		wait for clk_period;
		AssertExecuteState;

		-- reg write 0
		assert reg_write_out = false
			report "reg_write_out should be false for J instruction to prevent data from ALU or memory to be written to register"
			severity failure;

		-- mem write 0
		assert mem_write_out = false
			report "mem_write_out should be false for J instruction to prevent data being written to memory"
			severity failure;

		-- branch enable
		assert branch_out = false
			report "branch_out should be false on J instruction"
			severity failure;

		-- jump disable
		assert jump_out = true
			report "jump_out should be true on J instruction"
			severity failure;

		report "J instruction passed";


		report "Test success";
		wait;


	end process;

END;
