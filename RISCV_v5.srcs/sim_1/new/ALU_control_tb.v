`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/11/19 02:34:02
// Design Name: 
// Module Name: ALU_control_tb
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


module ALU_control_tb;

reg     [6:0]   opcode  = 7'd0;
reg     [2:0]   funct3   = 3'd0;
reg             inst30  = 1'b0;
wire    [3:0]   ALU_op;


ALU_control u_ALU_control(
    .opcode      (opcode    ),
    .funct3      (funct3    ),
    .inst30      (inst30    ),
    .ALU_op      (ALU_op    )
);

initial begin
    #1;
    opcode = 7'b0110011;      //RTYPE        
    inst30 = 1'b1;
    funct3  = 3'b000;
    #100;
    if(ALU_op != {inst30, funct3}) begin
        $fatal("Test Case failed!"); 
        $finish; 
    end
    opcode = 7'b0010011;      //ITYPE     
    inst30 = 1'b1;
    funct3  = 3'b000;
    #100;
    if(ALU_op != {1'b0, funct3}) begin
        $fatal("Test Case failed!"); 
        $finish; 
    end
    opcode = 7'b1100011;      //BTYPE     
    inst30 = 1'b1;
    funct3  = 3'b000; 
    #100;
    if(ALU_op != 4'b0010) begin
        $fatal("Test Case failed!"); 
        $finish; 
    end
    opcode = 7'b1100011;      //UNSIGNED BTYPE     
    inst30 = 1'b1;
    funct3  = 3'b111; 
    #100;
    if(ALU_op != 4'b0011) begin
        $fatal("Test Case failed!"); 
        $finish; 
    end
    opcode = 7'b0000011;      //LOAD     
    inst30 = 1'b1;
    funct3  = 3'b000; 
    #100;
    if(ALU_op != 4'b0000) begin
        $fatal("Test Case failed!"); 
        $finish; 
    end
    opcode = 7'b0100011;      //STYPE  
    inst30 = 1'b1;
    funct3  = 3'b000; 
    #100;
    if(ALU_op != 4'b0000) begin
        $fatal("Test Case failed!"); 
        $finish; 
    end
    

    $display("All test cases passed successfully!");
    $finish;
end



endmodule
