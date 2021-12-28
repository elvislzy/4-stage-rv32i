----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2021/12/01 17:04:21
-- Design Name: 
-- Module Name: processor_top - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity processor_top is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC);
end processor_top;

architecture Behavioral of processor_top is
    
    --port for PC
    signal pc_in: std_logic_vector(31 downto 0);
    signal pc_out: std_logic_vector(31 downto 0);
    
    --port for instruction memory
    --signal pc_out: std_logic_vector(31 downto 0);
    signal instruction : std_logic_vector(31 downto 0);
    signal instr_en : std_logic;
    
    --port for regfile
    signal rd_data_in : std_logic_vector(31 downto 0);
    signal rs1_data : std_logic_vector(31 downto 0);
    signal rs2_data : std_logic_vector(31 downto 0);
    
    --port for Control unit
    signal Branch : std_logic;
    signal Jump : std_logic;
    signal MemRead : std_logic;
    signal MemtoReg : std_logic_vector(1 downto 0);
    signal MemWrite : std_logic_vector(3 downto 0);
    signal PCsrc : std_logic;
    signal ALUSrc : std_logic;
    signal RegWrite : std_logic;
    signal pc_en : std_logic;
    
    --port for Imm Gen
    signal imm_extended : std_logic_vector(31 downto 0);
    
    --port for ALU Control
    signal ALU_op : std_logic_vector(3 downto 0);
    
    --port for ALU
    signal alu_out : std_logic_vector(31 downto 0);
    signal operand2 : std_logic_vector(31 downto 0);
    
    --port for data_ext_EX
    --none

    --port for data_ext_MEM
    signal dmem_out_ext : std_logic_vector(31 downto 0);

    --port for PC_adder
    signal pc_imm : std_logic_vector(31 downto 0);
    signal pc_add4 : std_logic_vector(31 downto 0);
    
    --port for data_memory
    --signal dmem_in : std_logic_vector(31 downto 0);
    signal dmem_out : std_logic_vector(31 downto 0);
    
    signal next_pc : std_logic_vector(31 downto 0);
    
begin
    --PC
    PC : entity work.PC port map(
        clk => clk,
        rst => rst,
	    en => pc_en,
        pc_tmp => pc_in,
        pc => pc_out
    );
    
    --instruction memory
    instr_mem : entity work.instr_mem port map(
        clk => clk,
        instr_en => instr_en,
        addr => pc_out,
        instr_out => instruction
    );
    
    --regfile
    regfile : entity work.regfile port map(
        clk => clk,
        rst => rst,
        we => RegWrite,
        rd_addr => instruction(11 downto 7),
        rs1_addr => instruction(19 downto 15),
        rs2_addr => instruction(24 downto 20),
        rd_data_in => rd_data_in,
        rs1_data => rs1_data,
        rs2_data => rs2_data
    );
    
    --Control Unit
    Control_unit : entity work.Control_unit port map(
        clk => clk,
        opcode => instruction(6 downto 0),
        funct3 => instruction(14 downto 12),
        Branch => Branch,
        Jump => Jump,
        MemRead => MemRead,
        MemtoReg => MemtoReg,
        MemWrite => MemWrite,
        PCsrc => PCsrc,
        ALUSrc => ALUSrc,
        RegWrite => RegWrite,
        pc_en => pc_en,
        instr_en => instr_en
    );
    
    --Immeidate Gen
    imm_gen : entity work.imm_gen port map(
        instruction => instruction,
        imm_ext => imm_extended
    );
    
    --Mux for operand2
    operand2_Gen : process(rs2_data, imm_extended, ALUSrc) is begin
        if(ALUSrc = '0') then
            operand2 <= rs2_data;
        else
            operand2 <= imm_extended;
        end if;
    end process operand2_Gen;
    
    --ALU_control
    ALU_control : entity work.ALU_control port map(
        opcode => instruction(6 downto 0),
        funct3 => instruction(14 downto 12),
        inst30 => instruction(30),
        ALU_op => ALU_op
    );
    
    --ALU
    alu :entity work.alu port map(
        alu_op => ALU_op,
        operand1 => rs1_data,
        operand2 => operand2,
        alu_out => alu_out
    );
    
--    data_ext_EX : entity work.data_ext port map(
--        data_in => rs2_data,
--        funt3 => instruction(14 downto 12),
--        data_out => dmem_in
--    );
    
    data_ext_MEM : entity work.data_ext port map(
        data_in => dmem_out,
        funt3 => instruction(14 downto 12),
        data_out => dmem_out_ext
    );
    
    data_mem : entity work.data_mem port map(
        clk => clk,
        addr => alu_out,
        we => MemWrite,
        re => MemRead,
        dmem_in => rs2_data,
        dmem_out => dmem_out
    );
    
    --pc_adder
    pc_adder: entity work.pc_adder port map(
        pc => pc_out,
        imm => imm_extended,
        pc_imm => pc_imm,
        pc_add4 => pc_add4
    );
    
    --Mux for next_pc
    next_pc_Gen : process(branch, jump, alu_out, pc_imm, pc_add4, instruction(14 downto 12)) is begin
        if(jump = '1') then
            next_pc <= pc_imm;
        elsif(branch = '1' and instruction(14 downto 12) = "000" and alu_out = "00000000000000000000000000000000") then --beq
            next_pc <= pc_imm;
        elsif(branch = '1' and instruction(14 downto 12) = "001" and alu_out /= "00000000000000000000000000000000") then --bne
            next_pc <= pc_imm;
        elsif(branch = '1' and instruction(14 downto 12) = "100" and alu_out(0)= '1') then --blt
            next_pc <= pc_imm;
        elsif(branch = '1' and instruction(14 downto 12) = "101" and alu_out(0) = '0') then --bge
            next_pc <= pc_imm;
        elsif(branch = '1' and instruction(14 downto 12) = "110" and alu_out(0)= '1') then --bltu
            next_pc <= pc_imm;
        elsif(branch = '1' and instruction(14 downto 12) = "111" and alu_out(0) = '0') then --bgeu
            next_pc <= pc_imm;
        else
            next_pc <= pc_add4;
        end if;
    end process next_pc_Gen;
    
    --Mux for pc_in
    pc_in_Gen : process(next_pc, alu_out, PCsrc) is begin
        if(PCsrc = '0') then
            pc_in <= next_pc;
        else
            pc_in <= alu_out;
        end if;
    end process pc_in_Gen;
    
    --Mux for rd_data_in
    rd_data_in_Gen : process(next_pc, alu_out, imm_extended, dmem_out_ext, MemtoReg) is begin
        if(MemtoReg = "11") then
            rd_data_in <= next_pc;
        elsif(MemtoReg = "00") then
            rd_data_in <= alu_out;
        elsif(MemtoReg = "01") then
            rd_data_in <= dmem_out_ext;
        elsif(MemtoReg = "10") then
            rd_data_in <= imm_extended;
        else 
            rd_data_in <= alu_out;
        end if;
    end process rd_data_in_Gen;



end Behavioral;
