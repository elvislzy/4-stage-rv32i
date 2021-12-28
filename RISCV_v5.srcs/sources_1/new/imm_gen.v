`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/11/14 17:53:50
// Design Name: 
// Module Name: imm_gen
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


module imm_gen(
    instruction,
    imm_ext
);

input           [31:0]  instruction;
output  reg     [31:0]  imm_ext;

parameter       [6:0]   LUI         = 7'b0110111;
parameter       [6:0]   AUIPC       = 7'b0010111;
parameter       [6:0]   JAL         = 7'b1101111;
parameter       [6:0]   JALR        = 7'b1100111;
parameter       [6:0]   BTYPE       = 7'b1100011;
parameter       [6:0]   LOAD        = 7'b0000011;
parameter       [6:0]   STYPE       = 7'b0100011;
parameter       [6:0]   ITYPE_ALU   = 7'b0010011;
parameter       [6:0]   RTYPE       = 7'b0110011;
parameter       [6:0]   ECALLBREAK  = 7'b1110011;
parameter       [6:0]   FENCE       = 7'b0001111;

wire            [6:0]   opcode;
assign opcode   = instruction[6:0];

always @(*) begin
    case(opcode)
        LUI:
            imm_ext = {instruction[31:12], 12'b0};
        AUIPC:
            imm_ext = {instruction[31:12], 12'b0};
        JAL:
            imm_ext = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};
        ITYPE_ALU:
            imm_ext = {{21{instruction[31]}}, instruction[30:20]};
        LOAD:
            imm_ext = {{21{instruction[31]}}, instruction[30:20]};
        JALR:
            imm_ext = {{21{instruction[31]}}, instruction[30:20]};
        BTYPE:
            imm_ext = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
        STYPE:
            imm_ext = {{21{instruction[31]}}, instruction[30:25], instruction[11:7]};
        default:
            imm_ext = {{21{instruction[31]}}, instruction[30:20]}; //ITYPE ALU IMM
    endcase
end

endmodule
