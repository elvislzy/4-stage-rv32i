----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2021/11/18 18:55:05
-- Design Name: 
-- Module Name: Control_unit_testbench - Behavioral
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

entity Control_unit_testbench is
--  Port ( );
end Control_unit_testbench;

architecture Behavioral of Control_unit_testbench is

    signal clk : STD_LOGIC:= '0';
    signal opcode : STD_LOGIC_VECTOR (6 downto 0);
    signal funct3 : STD_LOGIC_VECTOR (2 downto 0);
    signal Branch : STD_LOGIC;
    signal Jump : STD_LOGIC; -- jump = 1 equvalent to branch = 1& zero = 1;
    signal MemRead : STD_LOGIC;
    signal MemtoReg : std_logic_vector (1 downto 0); 
    --data write to register is from 01: data-memory,
    --00: alu result, 10: imm(LUI), 11: PC adder(PC + imm, AUIPC/ PC + 4, JALR)
    signal MemWrite : std_logic_vector (3 downto 0); --0001:SB, 0011:SH, 1111:SW, 0000:write disable
    signal PCsrc : std_logic;
    -- PCsrc = 0: next PC comes from PC adder, PCsrc = 1: next PC comes from ALU(JALR)
    signal ALUSrc : STD_LOGIC;
    signal RegWrite : STD_LOGIC;
    signal pc_en : STD_LOGIC; --Instuction memory can only output a new value when this signal is 1.

begin
    dut: entity work.Control_unit port map(
        clk => clk,
        opcode => opcode,
        funct3 => funct3,
        Branch => Branch,
        Jump => Jump,
        MemRead => MemRead,
        MemtoReg => MemtoReg, 
        MemWrite => MemWrite,
        PCsrc => PCsrc,
        ALUSrc => ALUSrc,
        RegWrite =>RegWrite,
        pc_en => pc_en
    );
    
    CLK_GEN: process
    begin
        wait for 50ns;
        clk <= '1';
        wait for 50ns;
        clk <= '0';
    end process;
    
    
    Inst_GEN: process
    begin
        wait for 100ns;
        wait for 100ns;
        opcode <= "0110011";
        wait for 400ns;
        opcode <= "0010011";
        wait for 400ns;
        opcode <= "0110111";
        wait for 400ns;
        opcode <= "0010111";
        wait for 400ns;
        opcode <= "0110111";
        wait for 400ns;
        opcode <= "1100111";
        wait for 400ns;
        opcode <= "1100011";
        wait for 400ns;
        opcode <= "0000011";
        wait for 400ns;
        opcode <= "0100011";
        wait for 400ns;
        opcode <= "0001111";  --fence
        wait for 400ns;
        opcode <= "1110011"; --ecall
        wait for 800ns;
        std.env.stop;
    end process;

end Behavioral;
