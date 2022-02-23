`timescale 1ns / 1ps
// `timescale 100ps/1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/12/09 15:50:01
// Design Name: 
// Module Name: program_tb
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


module program_tb;


//////////////////////////////////////////////////////////////////////////////////
//Clock speed
//////////////////////////////////////////////////////////////////////////////////
parameter f = 500;                   //Mhz
parameter PERIOD = 1/(f*0.001);

//////////////////////////////////////////////////////////////////////////////////
//Program define
//////////////////////////////////////////////////////////////////////////////////
// `define MULTIPLY;
`define DIVIDE;


//////////////////////////////////////////////////////////////////////////////////
//Signal
//////////////////////////////////////////////////////////////////////////////////
reg clk = 0;
reg rst = 0;
//Rst
initial begin
    #5 
    rst = 1;
end 

//clk
initial begin
    forever #(PERIOD/2)  clk=~clk;
end


//////////////////////////////////////////////////////////////////////////////////
//Declaration
//////////////////////////////////////////////////////////////////////////////////

//!!!!!!!!!!!!!!!!!!feature can be used in vivado 2020.3 or later verison

wire [31:0] pc = processor.pc;
wire [31:0] new_pc = processor.pc_tmp;
wire [31:0] instruction = processor.instruction; 
wire [31:0] alu_a = processor.rs1_data; 
wire [31:0] alu_b = processor.operand2; 
wire [31:0] alu_out = processor.alu_out; 
wire [2:0]  state = processor.processor_ctrl.state;
wire [31:0] r0 = processor.regfile.regfile[0]; 
wire [31:0] r1 = processor.regfile.regfile[1]; 
wire [31:0] r2 = processor.regfile.regfile[2];  
wire [31:0] r3 = processor.regfile.regfile[3]; 
wire [31:0] r4 = processor.regfile.regfile[4]; 
wire [31:0] r5 = processor.regfile.regfile[5]; 
wire [31:0] r6 = processor.regfile.regfile[6];  
wire [31:0] r7 = processor.regfile.regfile[7]; 
wire [31:0] r8 = processor.regfile.regfile[8]; 
wire [31:0] r9 = processor.regfile.regfile[9]; 
wire [31:0] r10 = processor.regfile.regfile[10]; 
wire [31:0] r11 = processor.regfile.regfile[11];  
wire [31:0] r12 = processor.regfile.regfile[12]; 


processor_top processor(
    .clk        (clk    ), 
    .rst_n      (rst    )
);



//////////////////////////////////////////////////////////////////////////////////
//Instruction Memory Initialisation
//////////////////////////////////////////////////////////////////////////////////
initial begin
    #1;
    `ifdef MULTIPLY
        $readmemh("imem_multiply.txt",processor.instr_mem.imem);
    `endif
    
    `ifdef DIVIDE
        $readmemh("imem_divide.txt",processor.instr_mem.imem);
    `endif
end

//////////////////////////////////////////////////////////////////////////////////
//Registor file Initialisation
//////////////////////////////////////////////////////////////////////////////////
parameter [31:0] operand1 = 32'd500;
parameter [31:0] operand2 = 32'd25;

initial begin
    #5
    processor.regfile.regfile[10] = operand1;
    processor.regfile.regfile[11] = operand2; 
end

//////////////////////////////////////////////////////////////////////////////////
//Verify
//////////////////////////////////////////////////////////////////////////////////
initial begin
    #10
    while(processor.instr_mem.instr_out[6:0] != 7'b1110011)
        #1;
    
    `ifdef MULTIPLY
        if(processor.data_mem.dmem[7] != operand1 * operand2 )                 $fatal("Test case multiply failed");    
        $display("Multiplication Test case passed");
        $display("op1: %4d, op2: %4d",operand1, operand2);
        $display("result: %4d",processor.data_mem.dmem[7]);
    `endif    
    
    `ifdef DIVIDE
        if(processor.data_mem.dmem[7] != operand1 / operand2 )                 $fatal("Test case divide failed");    
        $display("Division Test case passed");
        $display("op1: %4d, op2: %4d",operand1, operand2);
        $display("result: %4d",processor.data_mem.dmem[7]);
    `endif
    #100;

    $finish; 
end

//////////////////////////////////////////////////////////////////////////////////
//Data memory monitor
//////////////////////////////////////////////////////////////////////////////////
initial begin
    $monitor ("D2: %4d, D3: %4d, D7: %4d", processor.data_mem.dmem[2], processor.data_mem.dmem[3], processor.data_mem.dmem[7]);
   
end

endmodule
        
    