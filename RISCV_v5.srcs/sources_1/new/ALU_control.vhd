----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2021/11/16 14:36:28
-- Design Name: 
-- Module Name: ALU_control - Behavioral
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

entity ALU_control is
    Port ( opcode : in STD_LOGIC_VECTOR (6 downto 0);
           funct3 : in STD_LOGIC_VECTOR (2 downto 0);
           inst30 : in STD_LOGIC;
           ALU_op : out STD_LOGIC_VECTOR (3 downto 0));
end ALU_control;

architecture Behavioral of ALU_control is
    
begin
    ALU_op_GEN : process(opcode, funct3, inst30) begin
        if(opcode = "0110011") then -- R-type: ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND. I-type: SLLI, SRLI, SRAI
            ALU_op <= inst30 & funct3;
        elsif(opcode = "0010011") then -- I-type: ADDI, SLTI, SLTIU, XORI, ORI, ANDI
            ALU_op <= '0' & funct3;
        elsif(opcode = "0110111") then -- I-type: LUI
            alu_op <= "0000"; --perform nothing
        elsif(opcode = "0010111") then -- I-type: AUIPC, the add operation is done by another PC adder for any other branch inst.
            alu_op <= "0000"; --perform nothing
        elsif(opcode = "0110111") then -- UJ-type: JAL 
            alu_op <= "0000"; --perform nothing
        elsif(opcode = "1100111") then -- I-type: JALR 
            alu_op <= "0000"; --perform nothing
        elsif(opcode = "1100011" and (funct3 = "000" OR funct3 = "001")) then -- SB-type: BEQ, BNE
            alu_op <= "1000"; --perform sub
        elsif(opcode = "1100011" and (funct3 = "100" OR funct3 = "101")) then -- SB-type: BLT, BGE
            alu_op <= "0010"; --perform less then
        elsif(opcode = "1100011" and (funct3 = "110" OR funct3 = "111")) then -- SB-type: BLTU, BGEU
            alu_op <= "0011"; --perform unsigned less then
        elsif(opcode = "0000011") then -- I-type: LB, LH, LW, LBU, LHU
            alu_op <= "0000"; --perform add.
        elsif(opcode = "0100011") then -- S-type: SB, SH, SW
            alu_op <= "0000"; --perform add.
        elsif(opcode = "0001111") then --fence
            alu_op <= "0000"; --perform nothing
        elsif(opcode = "1110011") then --ecall, ebreak
            alu_op <= "0000"; --perform nothing
        elsif(opcode = "1110011") then --ebreak
            alu_op <= "0000"; --perform nothing\
        else
            alu_op <= "0000"; --perform nothing
        end if;
    end process ALU_op_GEN;

end Behavioral;
