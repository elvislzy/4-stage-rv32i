`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/12/31 14:51:42
// Design Name: 
// Module Name: processor_ctrl
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module processor_ctrl(
    clk,
    rst_n,
    opcode,
    funct3,
    Branch,
    Jump,
    MemRead,
    Regsrc,
    MemWrite,
    PCsrc,
    ALUsrc,
    RegWrite,
    PC_en,
    instr_en
);

input   wire            clk;
input   wire            rst_n;
input   wire    [6:0]   opcode;
input   wire    [2:0]   funct3;

output  reg             Branch;
output  reg             Jump;
output  reg             MemRead;
output  reg     [1:0]   Regsrc;
output  reg     [3:0]   MemWrite;
output  reg             PCsrc;
output  reg     [1:0]   ALUsrc;
output  reg             RegWrite;
output  reg             PC_en;
output  reg             instr_en;


reg                     Branch_tmp;
reg                     Jump_tmp;
reg                     PCsrc_tmp;
reg                     MemRead_tmp;
reg             [1:0]   Regsrc_tmp;
reg             [3:0]   MemWrite_tmp;
reg             [1:0]   ALUsrc_tmp;
reg                     RegWrite_tmp;
reg                     PC_en_tmp;
reg                     instr_en_tmp;


//////////////////////////////////////////////////////////////////////////////////
//FSM
//////////////////////////////////////////////////////////////////////////////////
reg             [2:0]   state;
reg             [2:0]   next_state;

parameter INIT  = 3'b000;
parameter IF    = 3'b001;
parameter ID    = 3'b010;
parameter EX    = 3'b011;
parameter MEM   = 3'b100;
parameter WB    = 3'b101;
parameter HALT  = 3'b110;


always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        state   <= IF;
    else
        state   <= next_state;
end

//////////////////////////////////////////////////////////////////////////////////
//Ctrl
//////////////////////////////////////////////////////////////////////////////////
always @(*) begin
    case(state)
        INIT: begin
            Branch_tmp      = 1'b0;
            Jump_tmp        = 1'b0;
            PCsrc_tmp       = 1'b0;
            MemRead_tmp     = 1'b0;
            Regsrc_tmp      = 2'b00;
            MemWrite_tmp    = 4'b0000;
            ALUsrc_tmp      = 1'b0;
            RegWrite_tmp    = 1'b0;
            PC_en_tmp       = 1'b0;
            instr_en_tmp    = 1'b0;
        end
        IF: begin
            Branch_tmp      = 1'b0;
            Jump_tmp        = 1'b0;
            PCsrc_tmp       = 1'b0;
            MemRead_tmp     = 1'b0;
            Regsrc_tmp      = 2'b00;
            MemWrite_tmp    = 4'b0000;
            ALUsrc_tmp      = 1'b0;
            RegWrite_tmp    = 1'b0;
            PC_en_tmp       = 1'b0;
            instr_en_tmp    = 1'b1;
        end
        ID: begin
            Branch_tmp      = 1'b0;
            Jump_tmp        = 1'b0;
            PCsrc_tmp       = 1'b0;
            MemRead_tmp     = 1'b0;
            Regsrc_tmp      = 2'b00;
            MemWrite_tmp    = 4'b0000;
            ALUsrc_tmp      = 1'b0;
            RegWrite_tmp    = 1'b0;
            PC_en_tmp       = 1'b0;
            instr_en_tmp    = 1'b0;
        end
        EX: begin
            PC_en_tmp       = 1'b0;
            instr_en_tmp    = 1'b0;
            if(opcode == 7'b0110011) begin                               //Rtype
                Branch_tmp      = 1'b0;
                Jump_tmp        = 1'b0;
                PCsrc_tmp       = 1'b0;
                MemRead_tmp     = 1'b0;
                Regsrc_tmp      = 2'b00;
                MemWrite_tmp    = 4'b0000;
                ALUsrc_tmp      = 2'b00;         //op2 from regfile
                RegWrite_tmp    = 1'b0;
            end
            else if(opcode == 7'b0010011) begin                          //Itype
                Branch_tmp      = 1'b0;
                Jump_tmp        = 1'b0;
                PCsrc_tmp       = 1'b0;
                MemRead_tmp     = 1'b0;
                Regsrc_tmp      = 2'b00;
                MemWrite_tmp    = 4'b0000;
                ALUsrc_tmp      = 2'b10;         //op2 from immgen
                RegWrite_tmp    = 1'b0;
            end
            else if(opcode == 7'b0110111) begin                          //LUI
                Branch_tmp      = 1'b0;
                Jump_tmp        = 1'b0;
                PCsrc_tmp       = 1'b0;
                MemRead_tmp     = 1'b0;
                Regsrc_tmp      = 2'b10;        //select immgen
                MemWrite_tmp    = 4'b0000;
                ALUsrc_tmp      = 1'b0;
                RegWrite_tmp    = 1'b0;            
            end
            else if(opcode == 7'b0010111) begin                          //AUIPC
                Branch_tmp      = 1'b0;
                Jump_tmp        = 1'b0;
                PCsrc_tmp       = 1'b0;
                MemRead_tmp     = 1'b0;
                Regsrc_tmp      = 2'b00;        //select pcadder
                MemWrite_tmp    = 4'b0000;
                ALUsrc_tmp      = 2'b11;        //op1-pc, op2-imm
                RegWrite_tmp    = 1'b0;            
            end
            else if(opcode == 7'b1101111) begin                          //JAL
                Branch_tmp      = 1'b0;
                Jump_tmp        = 1'b0;
                PCsrc_tmp       = 1'b0;
                MemRead_tmp     = 1'b0;
                Regsrc_tmp      = 2'b11;        //select pc+4
                MemWrite_tmp    = 4'b0000;
                ALUsrc_tmp      = 2'b00;
                RegWrite_tmp    = 1'b0;
            end
            else if(opcode == 7'b1100111) begin                          //JALR
                Branch_tmp      = 1'b0;
                Jump_tmp        = 1'b0;
                PCsrc_tmp       = 1'b0;
                MemRead_tmp     = 1'b0;
                Regsrc_tmp      = 2'b11;        //select pc+4
                MemWrite_tmp    = 4'b0000;
                ALUsrc_tmp      = 2'b10;         //op2 from imm
                RegWrite_tmp    = 1'b0;            
            end
            else if(opcode == 7'b1100011) begin                          //Branch_tmp
                Branch_tmp      = 1'b1;
                Jump_tmp        = 1'b0;
                PCsrc_tmp       = 1'b0;
                MemRead_tmp     = 1'b0;
                Regsrc_tmp      = 2'b00;
                MemWrite_tmp    = 4'b0000;
                ALUsrc_tmp      = 2'b00;
                RegWrite_tmp    = 1'b0;            
            end
            else if(opcode == 7'b0000011) begin                          //Load
                Branch_tmp      = 1'b0;
                Jump_tmp        = 1'b0;
                PCsrc_tmp       = 1'b0;
                MemRead_tmp     = 1'b0;
                Regsrc_tmp      = 2'b00;
                MemWrite_tmp    = 4'b0000;
                ALUsrc_tmp      = 2'b10;
                RegWrite_tmp    = 1'b0;            
            end
            else if(opcode == 7'b0100011) begin                          //Save
                Branch_tmp      = 1'b0;
                Jump_tmp        = 1'b0;
                PCsrc_tmp       = 1'b0;
                MemRead_tmp     = 1'b0;
                Regsrc_tmp      = 2'b00;
                MemWrite_tmp    = 4'b0000;
                ALUsrc_tmp      = 2'b10;
                RegWrite_tmp    = 1'b0;           
            end
            else if(opcode == 7'b0001111) begin                          //Fence
                Branch_tmp      = 1'b0;
                Jump_tmp        = 1'b0;
                PCsrc_tmp       = 1'b0;
                MemRead_tmp     = 1'b0;
                Regsrc_tmp      = 2'b00;
                MemWrite_tmp    = 4'b0000;
                ALUsrc_tmp      = 2'b00;
                RegWrite_tmp    = 1'b0;            
            end
            else begin
                Branch_tmp      = 1'b0;
                Jump_tmp        = 1'b0;
                PCsrc_tmp       = 1'b0;
                MemRead_tmp     = 1'b0;
                Regsrc_tmp      = 2'b00;
                MemWrite_tmp    = 4'b0000;
                ALUsrc_tmp      = 2'b00;
                RegWrite_tmp    = 1'b0;
            end
        end
        MEM: begin
            PC_en_tmp       = 1'b0;
            instr_en_tmp    = 1'b0;
            if(opcode == 7'b0110011) begin                               //Rtype
                Branch_tmp      = 1'b0;
                Jump_tmp        = 1'b0;
                PCsrc_tmp       = 1'b0;
                MemRead_tmp     = 1'b0;
                Regsrc_tmp      = 2'b00;
                MemWrite_tmp    = 4'b0000;
                ALUsrc_tmp      = 2'b00;         //op2 from regfile
                RegWrite_tmp    = 1'b0;
            end
            else if(opcode == 7'b0010011) begin                          //Itype
                Branch_tmp      = 1'b0;
                Jump_tmp        = 1'b0;
                PCsrc_tmp       = 1'b0;
                MemRead_tmp     = 1'b0;
                Regsrc_tmp      = 2'b00;
                MemWrite_tmp    = 4'b0000;
                ALUsrc_tmp      = 2'b10;         //op2 from immgen
                RegWrite_tmp    = 1'b0;
            end
            else if(opcode == 7'b0110111) begin                          //LUI
                Branch_tmp      = 1'b0;
                Jump_tmp        = 1'b0;
                PCsrc_tmp       = 1'b0;
                MemRead_tmp     = 1'b0;
                Regsrc_tmp      = 2'b10;        //select immgen
                MemWrite_tmp    = 4'b0000;
                ALUsrc_tmp      = 2'b00;
                RegWrite_tmp    = 1'b0;            
            end
            else if(opcode == 7'b0010111) begin                          //AUIPC
                Branch_tmp      = 1'b0;
                Jump_tmp        = 1'b0;
                PCsrc_tmp       = 1'b0;
                MemRead_tmp     = 1'b0;
                Regsrc_tmp      = 2'b00;        //select pcadder
                MemWrite_tmp    = 4'b0000;
                ALUsrc_tmp      = 2'b11;
                RegWrite_tmp    = 1'b0;            
            end
            else if(opcode == 7'b1101111) begin                          //JAL
                Branch_tmp      = 1'b0;
                Jump_tmp        = 1'b0;
                PCsrc_tmp       = 1'b0;
                MemRead_tmp     = 1'b0;
                Regsrc_tmp      = 2'b11;        //select pc+4
                MemWrite_tmp    = 4'b0000;
                ALUsrc_tmp      = 2'b00;
                RegWrite_tmp    = 1'b1;
            end
            else if(opcode == 7'b1100111) begin                          //JALR
                Branch_tmp      = 1'b0;
                Jump_tmp        = 1'b0;
                PCsrc_tmp       = 1'b0;
                MemRead_tmp     = 1'b0;
                Regsrc_tmp      = 2'b11;        //select pc+4
                MemWrite_tmp    = 4'b0000;
                ALUsrc_tmp      = 2'b10;         //op2 from imm
                RegWrite_tmp    = 1'b0;            
            end
            else if(opcode == 7'b1100011) begin                          //Branch_tmp
                Branch_tmp      = 1'b1;
                Jump_tmp        = 1'b0;
                PCsrc_tmp       = 1'b0;
                MemRead_tmp     = 1'b0;
                Regsrc_tmp      = 2'b00;
                MemWrite_tmp    = 4'b0000;
                ALUsrc_tmp      = 2'b00;
                RegWrite_tmp    = 1'b0;            
            end
            else if(opcode == 7'b0000011) begin                          //Load
                Branch_tmp      = 1'b0;
                Jump_tmp        = 1'b0;
                PCsrc_tmp       = 1'b0;
                MemRead_tmp     = 1'b1;
                Regsrc_tmp      = 2'b01;
                MemWrite_tmp    = 4'b0000;
                ALUsrc_tmp      = 2'b10;
                RegWrite_tmp    = 1'b0;            
            end
            else if(opcode == 7'b0100011) begin                          //Save
                Branch_tmp      = 1'b0;
                Jump_tmp        = 1'b0;
                PCsrc_tmp       = 1'b0;
                MemRead_tmp     = 1'b0;
                Regsrc_tmp      = 2'b00;
                MemWrite_tmp    = funct3[1] ? 4'b1111 : funct3[0] ? 4'b0011 : 4'b0001;
                ALUsrc_tmp      = 2'b10;
                RegWrite_tmp    = 1'b0;           
            end
            else if(opcode == 7'b0001111) begin                          //Fence
                Branch_tmp      = 1'b0;
                Jump_tmp        = 1'b0;
                PCsrc_tmp       = 1'b0;
                MemRead_tmp     = 1'b0;
                Regsrc_tmp      = 2'b00;
                MemWrite_tmp    = 4'b0000;
                ALUsrc_tmp      = 2'b00;
                RegWrite_tmp    = 1'b0;            
            end
            else begin
                Branch_tmp      = 1'b0;
                Jump_tmp        = 1'b0;
                PCsrc_tmp       = 1'b0;
                MemRead_tmp     = 1'b0;
                Regsrc_tmp      = 2'b00;
                MemWrite_tmp    = 4'b0000;
                ALUsrc_tmp      = 2'b00;
                RegWrite_tmp    = 1'b0;
            end            
        end
        WB: begin
            instr_en_tmp    = 1'b0;
            PC_en_tmp       = 1'b1;
            if(opcode == 7'b0110011) begin                               //Rtype
                Branch_tmp      = 1'b0;
                Jump_tmp        = 1'b0;
                PCsrc_tmp       = 1'b0;
                MemRead_tmp     = 1'b0;
                Regsrc_tmp      = 2'b00;
                MemWrite_tmp    = 4'b0000;
                ALUsrc_tmp      = 2'b00;         //op2 from regfile
                RegWrite_tmp    = 1'b1;
            end
            else if(opcode == 7'b0010011) begin                          //Itype
                Branch_tmp      = 1'b0;
                Jump_tmp        = 1'b0;
                PCsrc_tmp       = 1'b0;
                MemRead_tmp     = 1'b0;
                Regsrc_tmp      = 2'b00;
                MemWrite_tmp    = 4'b0000;
                ALUsrc_tmp      = 2'b10;         //op2 from immgen
                RegWrite_tmp    = 1'b1;
            end
            else if(opcode == 7'b0110111) begin                          //LUI
                Branch_tmp      = 1'b0;
                Jump_tmp        = 1'b0;
                PCsrc_tmp       = 1'b0;
                MemRead_tmp     = 1'b0;
                Regsrc_tmp      = 2'b10;        //select immgen
                MemWrite_tmp    = 4'b0000;
                ALUsrc_tmp      = 2'b00;
                RegWrite_tmp    = 1'b1; 
            end
            else if(opcode == 7'b0010111) begin                          //AUIPC
                Branch_tmp      = 1'b0;
                Jump_tmp        = 1'b0;
                PCsrc_tmp       = 1'b0;
                MemRead_tmp     = 1'b0;
                Regsrc_tmp      = 2'b00;        //select alu
                MemWrite_tmp    = 4'b0000;
                ALUsrc_tmp      = 2'b11;
                RegWrite_tmp    = 1'b1; 
            end
            else if(opcode == 7'b1101111) begin                          //JAL
                Branch_tmp      = 1'b0;
                Jump_tmp        = 1'b1;
                PCsrc_tmp       = 1'b0;
                MemRead_tmp     = 1'b0;
                Regsrc_tmp      = 2'b11;        //select pc+4
                MemWrite_tmp    = 4'b0000;
                ALUsrc_tmp      = 2'b00;
                RegWrite_tmp    = 1'b1;
            end
            else if(opcode == 7'b1100111) begin                          //JALR
                Branch_tmp      = 1'b0;
                Jump_tmp        = 1'b1;
                PCsrc_tmp       = 1'b1;
                MemRead_tmp     = 1'b0;
                Regsrc_tmp      = 2'b11;        //select pc+4
                MemWrite_tmp    = 4'b0000;
                ALUsrc_tmp      = 2'b10;         //op2 from imm
                RegWrite_tmp    = 1'b1;  
            end
            else if(opcode == 7'b1100011) begin                          //Branch_tmp
                Branch_tmp      = 1'b1;
                Jump_tmp        = 1'b0;
                PCsrc_tmp       = 1'b0;
                MemRead_tmp     = 1'b0;
                Regsrc_tmp      = 2'b00;
                MemWrite_tmp    = 4'b0000;
                ALUsrc_tmp      = 2'b00;
                RegWrite_tmp    = 1'b0; 
            end
            else if(opcode == 7'b0000011) begin                          //Load
                Branch_tmp      = 1'b0;
                Jump_tmp        = 1'b0;
                PCsrc_tmp       = 1'b0;
                MemRead_tmp     = 1'b1;
                Regsrc_tmp      = 2'b01;
                MemWrite_tmp    = 4'b0000;
                ALUsrc_tmp      = 2'b10;
                RegWrite_tmp    = 1'b1;   
            end
            else if(opcode == 7'b0100011) begin                          //Save
                Branch_tmp      = 1'b0;
                Jump_tmp        = 1'b0;
                PCsrc_tmp       = 1'b0;
                MemRead_tmp     = 1'b0;
                Regsrc_tmp      = 2'b00;
                MemWrite_tmp    = funct3[1] ? 4'b1111 : funct3[0] ? 4'b0011 : 4'b0001;
                ALUsrc_tmp      = 2'b10;
                RegWrite_tmp    = 1'b0;    
            end
            else if(opcode == 7'b0001111) begin                          //Fence
                Branch_tmp      = 1'b0;
                Jump_tmp        = 1'b0;
                PCsrc_tmp       = 1'b0;
                MemRead_tmp     = 1'b0;
                Regsrc_tmp      = 2'b00;
                MemWrite_tmp    = 4'b0000;
                ALUsrc_tmp      = 2'b00;
                RegWrite_tmp    = 1'b0;     
            end
            else begin
                Branch_tmp      = 1'b0;
                Jump_tmp        = 1'b0;
                PCsrc_tmp       = 1'b0;
                MemRead_tmp     = 1'b0;
                Regsrc_tmp      = 2'b00;
                MemWrite_tmp    = 4'b0000;
                ALUsrc_tmp      = 2'b00;
                RegWrite_tmp    = 1'b0;
            end
        end
        default: begin
            Branch_tmp      = 1'b0;
            Jump_tmp        = 1'b0;
            PCsrc_tmp       = 1'b0;
            MemRead_tmp     = 1'b0;
            Regsrc_tmp      = 2'b00;
            MemWrite_tmp    = 4'b0000;
            ALUsrc_tmp      = 2'b00;
            RegWrite_tmp    = 1'b0;
            instr_en_tmp    = 1'b0;
            PC_en_tmp       = 1'b0;
        end
    endcase        
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        Branch      <= 1'b0;
        Jump        <= 1'b0;
        PCsrc       <= 1'b0;
        MemRead     <= 1'b0;
        Regsrc      <= 2'b00;
        MemWrite    <= 4'b0000;
        ALUsrc      <= 2'b00;
        RegWrite    <= 1'b0;
        instr_en    <= 1'b0;
        PC_en       <= 1'b0; 
    end
    else begin
        Branch      <= Branch_tmp  ;
        Jump        <= Jump_tmp    ;
        PCsrc       <= PCsrc_tmp   ;
        MemRead     <= MemRead_tmp ;
        Regsrc      <= Regsrc_tmp  ;
        MemWrite    <= MemWrite_tmp;
        ALUsrc      <= ALUsrc_tmp  ;
        RegWrite    <= RegWrite_tmp;
        instr_en    <= instr_en_tmp;
        PC_en       <= PC_en_tmp   ; 
    end
end

//FSM_LUT
always @(*) begin
    case(state)
        INIT:
            if(!rst_n)
                next_state = INIT;
            else
                next_state = IF;
        IF:
            if(!rst_n)
                next_state = INIT;
            else
                next_state = ID;
        ID:
            if(!rst_n)
                next_state = INIT;
            else if(opcode == 7'b1110011)
                next_state = HALT;
            else
                next_state = EX;
        EX:
            if(!rst_n)
                next_state = INIT;
            else
                next_state = MEM;
        MEM:
            if(!rst_n)
                next_state = INIT;
            else
                next_state = WB;
        WB:
            if(!rst_n)
                next_state = INIT;
            else
                next_state = IF;
        HALT:
            if(!rst_n)
                next_state = INIT;
            else
                next_state = HALT;
        default:
            next_state = INIT;
    endcase
end


endmodule
