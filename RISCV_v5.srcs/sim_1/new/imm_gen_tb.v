`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/11/18 17:44:09
// Design Name: 
// Module Name: imm_gen_tb
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


module imm_gen_tb;


reg     [31:0]  instruction;
wire    [31:0]  imm_ext;


imm_gen u_imm_gen(
    instruction,
    imm_ext
);


initial begin
    instruction = 32'b100000000001_10000_100_00000_0110111;      //LUI        
    #100;
    if(imm_ext != {instruction[31:12], 12'b0}) begin
        $fatal("Test Case failed!"); 
        $finish; 
    end
    instruction = 32'b100000000000_10000_100_00000_0010111;      //AUIPC     
    #100;
    if(imm_ext != {instruction[31:12], 12'b0}) begin
        $fatal("Test Case failed!"); 
        $finish; 
    end
    instruction = 32'b111111111111_11111_111_00000_1101111;      //JAL      
    #100;
    if(imm_ext != {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0}) begin
        $fatal("Test Case failed!"); 
        $finish; 
    end
    instruction = 32'b100000000000_00000_000_00000_1100111;      //JALR     
    #100;
    if(imm_ext != {{21{instruction[31]}}, instruction[30:20]}) begin
        $fatal("Test Case failed!"); 
        $finish; 
    end
    instruction = 32'b1000001_00000_00000_000_10001_1100011;      //BTYPE     
    #100;
    if(imm_ext != {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0}) begin
        $fatal("Test Case failed!"); 
        $finish; 
    end
    instruction = 32'b000000000001_00001_001_00000_0010011;      //LOAD  
    #100;
    if(imm_ext != {{21{instruction[31]}}, instruction[30:20]}) begin
        $fatal("Test Case failed!"); 
        $finish; 
    end
    instruction = 32'b1000001_00000_00000_000_10001_0100011;      //STYPE    
    #100;
    if(imm_ext != {{21{instruction[31]}}, instruction[30:25], instruction[11:7]}) begin
        $fatal("Test Case failed!"); 
        $finish; 
    end
    instruction = 32'b000000000001_00001_001_00000_0010011;      //ITYPE_ALU 
    #100;
    if(imm_ext != {{21{instruction[31]}}, instruction[30:20]}) begin
        $fatal("Test Case failed!"); 
        $finish; 
    end

    $display("All test cases passed successfully!");
    $finish;
end


endmodule
