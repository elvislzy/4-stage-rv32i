----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2021/11/18 16:03:55
-- Design Name: 
-- Module Name: Control_unit - Behavioral
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

entity Control_unit is
    Port ( clk : in STD_LOGIC;
           opcode : in STD_LOGIC_VECTOR (6 downto 0);
           funct3 : in STD_LOGIC_VECTOR (2 downto 0);--funct3 is only used to distinguish sb, sh, and sw.
           Branch : out STD_LOGIC;
           Jump : out STD_LOGIC; -- jump = 1 equvalent to branch = 1& zero = 1;
           MemRead : out STD_LOGIC;
           MemtoReg : out std_logic_vector (1 downto 0); 
           --data write to register is from 01: data-memory,
           --00: alu result, 10: imm(LUI), 11: PC adder(PC + imm, AUIPC/ PC + 4, JALR)
           MemWrite : out std_logic_vector (3 downto 0);--0001:SB, 0011:SH, 1111:SW, 0000:write disable
           PCsrc : out std_logic;
           -- PCsrc = 0: next PC comes from PC adder, PCsrc = 1: next PC comes from ALU(JALR)
           ALUSrc : out STD_LOGIC;
           RegWrite : out STD_LOGIC;
           pc_en : out STD_LOGIC; --PC can only get a new value when this signal is 1.
           instr_en : out STD_LOGIC);
end Control_unit;

architecture Behavioral of Control_unit is

    type state_type is (INIT, InstF, ID, MEM, WB, STOP); 
    --don't need EX because it's all combinatorial logic   
    --INIT reserved for special use if there something needs to initial
    --InstF, ID, MEM, WB refers to instruction fetch(actually also do the decode), instruction decode(also do the EX)
    --memory access, and write back to register respectively.
    
    signal state : state_type;
    signal nextstate : state_type;
begin

    trans_FSM : process (clk) begin
        if (clk'event and clk = '1') then state <= nextstate;
        end if;
    end process trans_FSM;
    
    next_state_FSM : process (state, opcode) begin --becuse it's nonepiplined,so next state doesn't depends on the opcode.
        if(state = INIT) then
            nextstate <= InstF;
        elsif(state = InstF) then
            nextstate <= ID;    --where we access register
        elsif(state = ID and opcode /= "1110011") then --ecall/ebreak
            nextstate <= MEM;
        elsif(state = ID and opcode = "1110011") then --ecall/ebreak
            nextstate <= STOP;
        elsif(state = MEM) then
            nextstate <= WB;
        elsif(state = WB) then
            nextstate <= InstF;
        elsif(state = STOP) then
            nextstate <= STOP;
        else
            nextstate <= INIT; --shouldn't reach here
        end if;
    end process next_state_FSM;

    output_FSM : process(nextstate, state, opcode, funct3) begin 
        if(nextstate = InstF) then --all instruction do the same thing in IF stage
            if(opcode = "1100011") then -- SB-type: BEQ, BNE, BLT, BGE, BLTU, BGEU
                Branch <= '1'; --it's a branch
            else 
                Branch <= '0'; --do not need branch
            end if;

            Jump <= '0'; --do not need to jump
            PCsrc <= '0'; --next PC comes from PC adder
            MemRead <= '0'; --do not need to read data memory
            MemtoReg <= "00"; --do not need the signal
            MemWrite <= "0000";
            ALUSrc <= '0';
            RegWrite <= '0'; --shouldn't write to register
            -- if(state = INIT) then
            --     pc_en <= '0';
            -- else
            --     pc_en <= '1';
            -- end if;
            pc_en <= '0';
            instr_en <= '1';
        elsif(nextstate = ID) then
            instr_en <= '0';
            if(opcode = "0110011") then --all R-type instuctions
                Branch <= '0'; --do not need branch
                Jump <= '0'; --do not need to jump
                PCsrc <= '0'; --next PC comes from PC adder
                MemRead <= '0'; --do not need to read data memory
                MemtoReg <= "00"; --the data needs to write back is from alu result
                MemWrite <= "0000";
                ALUSrc <= '0'; --operand2 comes from register file.
                RegWrite <= '0'; --shouldn't write to register
                pc_en <= '0';
            elsif(opcode = "0010011") then -- I-type arithmetic instruction: ADDI, SLTI, SLTIU, XORI, ORI, ANDI
                Branch <= '0'; --do not need branch
                Jump <= '0'; --do not need to jump
                PCsrc <= '0'; --next PC comes from PC adder
                MemRead <= '0'; --do not need to read data memory
                MemtoReg <= "00"; --the data needs to write back is from alu result
                MemWrite <= "0000";
                ALUSrc <= '1'; --operand2 comes from imm.
                RegWrite <= '0'; --shouldn't write to register
                pc_en <= '0';
            elsif(opcode = "0110111") then -- I-type: LUI
                Branch <= '0'; --do not need branch
                Jump <= '0'; --do not need to jump
                PCsrc <= '0'; --next PC comes from PC adder
                MemRead <= '0'; --do not need to read data memory
                MemtoReg <= "10"; --the data needs to write back is from imm
                MemWrite <= "0000";
                ALUSrc <= '0'; --don't need this signal
                RegWrite <= '0'; --shouldn't write to register
                pc_en <= '0';
            elsif(opcode = "0010111") then -- I-type: AUIPC, the add operation is done by another PC adder
                Branch <= '0'; --do not need branch
                Jump <= '0'; --do not need to jump
                PCsrc <= '0'; --next PC comes from PC adder
                MemRead <= '0'; --do not need to read data memory
                MemtoReg <= "11"; --the data needs to write back is from pc adder
                MemWrite <= "0000";
                ALUSrc <= '0';--don't need this signal
                RegWrite <= '0'; --shouldn't write to register
                pc_en <= '0';
            elsif(opcode = "1101111") then -- UJ-type: JAL
                Branch <= '0'; --do not need branch
                Jump <= '0'; --need to jump, but rd needs to get PC+4 first(in MEM stage)
                PCsrc <= '0'; --next PC comes from PC adder
                MemRead <= '0'; --do not need to read data memory
                MemtoReg <= "11";--rd needs to get PC+4
                MemWrite <= "0000"; 
                ALUSrc <= '0'; --don't need this signal
                RegWrite <= '0'; --shouldn't write to register yet
                pc_en <= '0';
            elsif(opcode = "1100111") then -- I-type: JALR 
                Branch <= '0'; --don't need this signal
                Jump <= '0'; --don't need this signal
                PCsrc <= '1'; --next PC comes from ALU
                MemRead <= '0'; --do not need to read data memory
                MemtoReg <= "11"; --PC + 4 needs to be written to rd
                MemWrite <= "0000"; 
                ALUSrc <= '1'; --operand2 comes from imm.
                RegWrite <= '0'; --shouldn't write to register
                pc_en <= '0';
            elsif(opcode = "1100011") then -- SB-type: BEQ, BNE, BLT, BGE, BLTU, BGEU
                Branch <= '1'; --it's a branch
                Jump <= '0';  --it's not jump
                PCsrc <= '0'; --next PC comes from pc adder
                MemRead <= '0'; --do not need to read data memory
                MemtoReg <= "00"; --don't need this signal
                MemWrite <= "0000"; 
                ALUSrc <= '0'; --operand2 comes from register.
                RegWrite <= '0'; --shouldn't write to register
                pc_en <= '0';
            elsif(opcode = "0000011") then -- I-type: LB, LH, LW, LBU, LHU
                Branch <= '0'; --it's not a branch
                Jump <= '0';  --it's not jump
                PCsrc <= '0'; --next PC comes from pc adder
                MemRead <= '0'; --do not need to read data memory yet
                MemtoReg <= "00"; --don't need this signal
                MemWrite <= "0000"; 
                ALUSrc <= '1'; --operand2 comes from imm.
                RegWrite <= '0'; --shouldn't write to register yet
                pc_en <= '0';
            elsif(opcode = "0100011") then -- S-type: SB, SH, SW
                Branch <= '0'; --it's not a branch
                Jump <= '0';  --it's not jump
                PCsrc <= '0'; --next PC comes from pc adder
                MemRead <= '0'; --do not need to read data memory yet
                MemtoReg <= "00"; --don't need this signal
                MemWrite <= "0000"; --do not need to write data memory yet
                ALUSrc <= '1'; --operand2 comes from imm.
                RegWrite <= '0'; --shouldn't write to register
                pc_en <= '0';
            elsif(opcode = "0001111") then --fence
                Branch <= '0'; --it's not a branch
                Jump <= '0';  --it's not jump
                PCsrc <= '0'; --next PC comes from pc adder
                MemRead <= '0'; --do not need to read data memory
                MemtoReg <= "00"; --don't need this signal
                MemWrite <= "0000"; --do not need to write data memory
                ALUSrc <= '0'; --don't need this signal
                RegWrite <= '0'; --shouldn't write to register
                pc_en <= '0';
            elsif(opcode = "1110011") then --ecall, ebreak
                Branch <= '0'; --it's not a branch
                Jump <= '0';  --it's not jump
                PCsrc <= '0'; --next PC comes from pc adder
                MemRead <= '0'; --do not need to read data memory
                MemtoReg <= "00"; --don't need this signal
                MemWrite <= "0000"; --do not need to write data memory
                ALUSrc <= '1';--don't need this signal
                RegWrite <= '0'; --shouldn't write to register
                pc_en <= '0';
            else
                Branch <= '0'; --it's not a branch
                Jump <= '0';  --it's not jump
                PCsrc <= '0'; --next PC comes from pc adder
                MemRead <= '0'; --do not need to read data memory
                MemtoReg <= "11"; --don't need this signal
                MemWrite <= "0000"; --do not need to write data memory
                ALUSrc <= '1'; --don't need this signal
                RegWrite <= '0'; --shouldn't write to register
                pc_en <= '0';
            end if;
        elsif(nextstate = MEM) then
            instr_en <= '0';
            if(opcode = "0110011") then --all R-type instuctions
                Branch <= '0'; --do not need branch
                Jump <= '0'; --do not need to jump
                PCsrc <= '0'; --next PC comes from PC adder
                MemRead <= '0'; --do not need to read data memory
                MemtoReg <= "00"; --the data needs to write back is from alu result
                MemWrite <= "0000";
                ALUSrc <= '0'; --operand2 comes from register file.
                RegWrite <= '0'; --shouldn't write to register
                pc_en <= '0';
            elsif(opcode = "0010011") then -- I-type arithmetic instruction: ADDI, SLTI, SLTIU, XORI, ORI, ANDI
                Branch <= '0'; --do not need branch
                Jump <= '0'; --do not need to jump
                PCsrc <= '0'; --next PC comes from PC adder
                MemRead <= '0'; --do not need to read data memory
                MemtoReg <= "00"; --the data needs to write back is from alu result
                MemWrite <= "0000";
                ALUSrc <= '1'; --operand2 comes from imm.
                RegWrite <= '0'; --shouldn't write to register
                pc_en <= '0';
            elsif(opcode = "0110111") then -- I-type: LUI
                Branch <= '0'; --do not need branch
                Jump <= '0'; --do not need to jump
                PCsrc <= '0'; --next PC comes from PC adder
                MemRead <= '0'; --do not need to read data memory
                MemtoReg <= "10"; --the data needs to write back is from imm
                MemWrite <= "0000";
                ALUSrc <= '1'; --don't need this signal
                RegWrite <= '0'; --shouldn't write to register
                pc_en <= '0';
            elsif(opcode = "0010111") then -- I-type: AUIPC, the add operation is done by another PC adder
                Branch <= '0'; --do not need branch
                Jump <= '1'; --do not need to jump
                PCsrc <= '0'; --next PC comes from PC adder
                MemRead <= '0'; --do not need to read data memory
                MemtoReg <= "11"; --the data needs to write back is from pc adder
                MemWrite <= "0000";
                ALUSrc <= '1'; --don't need this signal
                RegWrite <= '1'; --shouldn't write to register
                pc_en <= '0';
            elsif(opcode = "1101111") then -- UJ-type: JAL
                Branch <= '0'; --do not need branch
                Jump <= '0'; --need to jump, but rd needs to get PC+4
                PCsrc <= '0'; --next PC comes from PC adder
                MemRead <= '0'; --do not need to read data memory
                MemtoReg <= "11";--don't need this signal
                MemWrite <= "0000"; 
                ALUSrc <= '1'; --don't need this signal
                RegWrite <= '1'; --write to rd
                pc_en <= '0';
            elsif(opcode = "1100111") then -- I-type: JALR 
                Branch <= '0'; --don't need this signal
                Jump <= '1'; --don't need this signal
                PCsrc <= '1'; --next PC comes from ALU
                MemRead <= '0'; --do not need to read data memory
                MemtoReg <= "11"; --PC + 4 needs to be written to rd
                MemWrite <= "0000"; 
                ALUSrc <= '1'; --operand2 comes from imm.
                RegWrite <= '0'; --shouldn't write to register
                pc_en <= '0';
            elsif(opcode = "1100011") then -- SB-type: BEQ, BNE, BLT, BGE, BLTU, BGEU
                Branch <= '1'; --it's a branch
                Jump <= '0';  --it's not jump
                PCsrc <= '0'; --next PC comes from pc adder
                MemRead <= '0'; --do not need to read data memory
                MemtoReg <= "11"; --don't need this signal
                MemWrite <= "0000"; 
                ALUSrc <= '0'; --operand2 comes from register.
                RegWrite <= '0'; --shouldn't write to register
                pc_en <= '0';
            elsif(opcode = "0000011") then -- I-type: LB, LH, LW, LBU, LHU
                Branch <= '0'; --it's not a branch
                Jump <= '0';  --it's not jump
                PCsrc <= '0'; --next PC comes from pc adder
                MemRead <= '1'; --need to read data memory
                MemtoReg <= "01"; -- data written to register comes from data memory
                MemWrite <= "0000"; 
                ALUSrc <= '1'; --operand2 comes from imm.
                RegWrite <= '0'; --shouldn't write to register yet
                pc_en <= '0';
            elsif(opcode = "0100011") then -- S-type: SB, SH, SW
                Branch <= '0'; --it's not a branch
                Jump <= '0';  --it's not jump
                PCsrc <= '0'; --next PC comes from pc adder
                MemRead <= '0'; --do not need to read data memory
                MemtoReg <= "11";--don't need this signal
                if(funct3 = "000") then --sb
                    MemWrite <= "0001"; --need to write data memory
                elsif(funct3 = "001") then --sh
                    MemWrite <= "0011"; --need to write data memory    
                elsif(funct3 = "010") then --sw
                    MemWrite <= "1111"; --need to write data memory   
                else --shouldn't reach here.
                    MemWrite <= "1111"; --need to write data memory
                end if;
                ALUSrc <= '1'; --operand2 comes from imm.
                RegWrite <= '0'; --shouldn't write to register
                pc_en <= '0';
            elsif(opcode = "0001111") then --fence
                Branch <= '0'; --it's not a branch
                Jump <= '0';  --it's not jump
                PCsrc <= '0'; --next PC comes from pc adder
                MemRead <= '0'; --do not need to read data memory
                MemtoReg <= "11"; --don't need this signal
                MemWrite <= "0000"; --do not need to write data memory
                ALUSrc <= '1'; --don't need this signal
                RegWrite <= '0'; --shouldn't write to register
                pc_en <= '0';
            else --shouldn't reach here
                Branch <= '0'; --it's not a branch
                Jump <= '0';  --it's not jump
                PCsrc <= '0'; --next PC comes from pc adder
                MemRead <= '0'; --do not need to read data memory
                MemtoReg <= "11"; --don't need this signal
                MemWrite <= "0000"; --do not need to write data memory
                ALUSrc <= '1'; --don't need this signal
                RegWrite <= '0'; --shouldn't write to register
                pc_en <= '0';
            end if;
        elsif(nextstate = WB) then
            instr_en <= '0';
            if(opcode = "0110011") then --all R-type instuctions
                Branch <= '0'; --do not need branch
                Jump <= '0'; --do not need to jump
                PCsrc <= '0'; --next PC comes from PC adder
                MemRead <= '0'; --do not need to read data memory
                MemtoReg <= "00"; --the data needs to write back is from alu result
                MemWrite <= "0000";
                ALUSrc <= '0'; --operand2 comes from register file.
                RegWrite <= '1'; --write to register
                pc_en <= '1';
            elsif(opcode = "0010011") then -- I-type arithmetic instruction: ADDI, SLTI, SLTIU, XORI, ORI, ANDI
                Branch <= '0'; --do not need branch
                Jump <= '0'; --do not need to jump
                PCsrc <= '0'; --next PC comes from PC adder
                MemRead <= '0'; --do not need to read data memory
                MemtoReg <= "00"; --the data needs to write back is from alu result
                MemWrite <= "0000";
                ALUSrc <= '1'; --operand2 comes from imm.
                RegWrite <= '1'; --write to register
                pc_en <= '1';
            elsif(opcode = "0110111") then -- I-type: LUI
                Branch <= '0'; --do not need branch
                Jump <= '0'; --do not need to jump
                PCsrc <= '0'; --next PC comes from PC adder
                MemRead <= '0'; --do not need to read data memory
                MemtoReg <= "10"; --the data needs to write back is from imm
                MemWrite <= "0000";
                ALUSrc <= '1'; --do not need this signal
                RegWrite <= '1'; --write to register
                pc_en <= '1';
            elsif(opcode = "0010111") then -- I-type: AUIPC, the add operation is done by another PC adder
                Branch <= '0'; --do not need branch
                Jump <= '0'; --do not need to jump
                PCsrc <= '0'; --next PC comes from PC adder
                MemRead <= '0'; --do not need to read data memory
                MemtoReg <= "11"; --the data needs to write back is from pc adder
                MemWrite <= "0000";
                ALUSrc <= '1'; --do not need this signal
                RegWrite <= '0'; --write to register
                pc_en <= '1';
            elsif(opcode = "1101111") then -- UJ-type: JAL
                Branch <= '0'; --do not need branch
                Jump <= '1'; --need to jump, PC=PC+imm
                PCsrc <= '0'; --next PC comes from PC adder
                MemRead <= '0'; --do not need to read data memory
                MemtoReg <= "11";--do not need this signal
                MemWrite <= "0000"; 
                ALUSrc <= '1'; --operand2 comes from imm.
                RegWrite <= '0'; --shouldn't write to register
                pc_en <= '1';
            elsif(opcode = "1100111") then -- I-type: JALR 
                Branch <= '0'; --do not need this signal
                Jump <= '1';--do not need this signal
                PCsrc <= '1'; --next PC comes from ALU
                MemRead <= '0'; --do not need to read data memory
                MemtoReg <= "11"; --PC + 4 needs to be written to rd
                MemWrite <= "0000"; 
                ALUSrc <= '1'; --operand2 comes from imm.
                RegWrite <= '1'; --PC + 4 write to register
                pc_en <= '1';
            elsif(opcode = "1100011") then -- SB-type: BEQ, BNE, BLT, BGE, BLTU, BGEU
                Branch <= '1'; --it's a branch
                Jump <= '0';  --it's not jump
                PCsrc <= '0'; --next PC comes from pc adder
                MemRead <= '0'; --do not need to read data memory
                MemtoReg <= "11"; --do not need this signal
                MemWrite <= "0000"; 
                ALUSrc <= '0'; --operand2 comes from register.
                RegWrite <= '0'; --shouldn't write to register
                pc_en <= '1';
            elsif(opcode = "0000011") then -- I-type: LB, LH, LW, LBU, LHU
                Branch <= '0'; --it's not a branch
                Jump <= '0';  --it's not jump
                PCsrc <= '0'; --next PC comes from pc adder
                MemRead <= '0'; --don't need to read data memory
                MemtoReg <= "01"; -- data written to register comes from data memory
                MemWrite <= "0000"; 
                ALUSrc <= '1'; --operand2 comes from imm.
                RegWrite <= '1'; --write to register
                pc_en <= '1';
            elsif(opcode = "0100011") then -- S-type: SB, SH, SW
                Branch <= '0'; --it's not a branch
                Jump <= '0';  --it's not jump
                PCsrc <= '0'; --next PC comes from pc adder
                MemRead <= '0'; --do not need to read data memory
                MemtoReg <= "11"; --do not need to read data memory
                MemWrite <= "0000"; --don't need to write data memory
                ALUSrc <= '1'; --do not need to read data memory
                RegWrite <= '0'; --shouldn't write to register
                pc_en <= '1';
            elsif(opcode = "0001111") then --fence
                Branch <= '0'; --it's not a branch
                Jump <= '0';  --it's not jump
                PCsrc <= '0'; --next PC comes from pc adder
                MemRead <= '0'; --do not need to read data memory
                MemtoReg <= "11"; --do not need to read data memory
                MemWrite <= "0000"; --do not need to write data memory
                ALUSrc <= '1'; --do not need to read data memory
                RegWrite <= '0'; --shouldn't write to register
                pc_en <= '1';
            else
                Branch <= '0'; --it's not a branch
                Jump <= '0';  --it's not jump
                PCsrc <= '0'; --next PC comes from pc adder
                MemRead <= '0'; --do not need to read data memory
                MemtoReg <= "11"; --don't need this signal
                MemWrite <= "0000"; --do not need to write data memory
                ALUSrc <= '1'; --don't need this signal
                RegWrite <= '0'; --shouldn't write to register
                pc_en <= '0';
            end if;
        else
            instr_en <= '0'; 
            Branch <= '0'; --do not need branch
            Jump <= '0'; --do not need to jump
            PCsrc <= '0'; --next PC comes from PC adder
            MemRead <= '0'; --do not need to read data memory
            MemtoReg <= "00"; --do not need the signal
            MemWrite <= "0000";
            ALUSrc <= '0';
            RegWrite <= '0'; --shouldn't write to register
            pc_en <= '0';
        end if;
    end process output_FSM;
    

end Behavioral;
