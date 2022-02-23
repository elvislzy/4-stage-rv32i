`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/12/16 15:36:38
// Design Name: 
// Module Name: Memory_tb
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


module Memory_tb;
parameter f = 500;                   //Mhz
parameter PERIOD = 1/(f*0.001);

reg clk = 0;
reg rst = 0;

processor_top processor(
    .clk        (clk    ), 
    .rst_n      (rst    )
);

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



//Rst
initial begin
    #5 
    rst = 1;
end 

//clk
initial begin
    forever #(PERIOD/2)  clk=~clk;
end



//Data Memory Initialisation
reg [31:0] data0 = 32'b0000_1111_0000_0000_0000_0000_1111_1111;     //LB
reg [31:0] data1 = 32'b0000_1111_0000_0000_1111_1111_1111_1111;     //LH    
reg [31:0] data2 = 32'b1000_0000_1111_1111_1111_1111_1111_1111;     //Lw    

initial begin
    processor.data_mem.dmem[0] = data0;
    processor.data_mem.dmem[1] = data1;
    processor.data_mem.dmem[2] = data2;
end


//Instruction Memory Initialisation

initial begin
    //initial
    //lui test
    processor.instr_mem.imem[0] = {32'b10000000000000000000_00001_0110111};           // lui  x1, imm 
    //load data from data memory to registor file
    //load test
    processor.instr_mem.imem[1] = {32'b000000000000_00001_000_00010_0000011};       // lb   x2,x1(0) data memory address start at 0x80000000
    processor.instr_mem.imem[2] = {32'b000000000000_00001_100_00011_0000011};       // lbu  x3,x1(0) 
    processor.instr_mem.imem[3] = {32'b000000000100_00001_001_00100_0000011};       // lh   x4,x1(4) 
    processor.instr_mem.imem[4] = {32'b000000000100_00001_101_00101_0000011};       // lhu  x5,x1(4)
    processor.instr_mem.imem[5] = {32'b000000001000_00001_010_00110_0000011};       // lw   x6,x1(8)

    processor.instr_mem.imem[6] = {32'b0000000_00110_00001_000_01100_0100011};       // sb   x6,x1(12)
    processor.instr_mem.imem[7] = {32'b0000000_00110_00001_001_10000_0100011};       // sh   x6,x1(16)
    processor.instr_mem.imem[8] = {32'b0000000_00110_00001_010_10100_0100011};       // sw   x6,x1(20)

    //load N numbers from rom to registor r2,r3,r4
    processor.instr_mem.imem[9] = {32'b00000000000100000000_00001_0110111};         // lui  x1,0x00100000 rom memory addres start at 0x00100000 
    processor.instr_mem.imem[10] = {32'b000000000000_00001_010_00111_0000011};      // lw   x7,x1(0)
    processor.instr_mem.imem[11] = {32'b000000000100_00001_010_01000_0000011};      // lw   x8,x1(4)
    processor.instr_mem.imem[12] = {32'b000000001000_00001_010_01001_0000011};      // lw   x9,x1(8)

end


//Verify
initial begin   
    #1200;
    //LOAD
    if(r2 != {{24{data0[7]}},data0[7:0]} )    $fatal("Test case 'LB' failed"); 
    if(r3 != {{24{1'b0}},data0[7:0]} )        $fatal("Test case 'LBU' failed"); 
    if(r4 != {{16{data1[7]}},data1[15:0]} )   $fatal("Test case 'LH' failed"); 
    if(r5 != {{16{1'b0}},data1[15:0]} )       $fatal("Test case 'LHU' failed"); 
    //SAVE
    if(processor.data_mem.dmem[3] != {{24{1'b0}},data2[7:0]})     $fatal("Test case 'SB' failed"); 
    if(processor.data_mem.dmem[4] != {{16{1'b0}},data2[15:0]})    $fatal("Test case 'SH' failed"); 
    if(processor.data_mem.dmem[5] != data2)                     $fatal("Test case 'SW' failed"); 
    //Load N number
    if(r7 != 32'd11311762)  $fatal("Test case 'N number 1' failed"); 
    if(r8 != 32'd19816562)  $fatal("Test case 'N number 2' failed"); 
    if(r9 != 32'd17003972)  $fatal("Test case 'N number 3' failed");
 
    #100
    $display("Memory Test cases passed");
    $finish;
end

//Monitor
initial begin
    //print N numbers
    $monitor ("R7: %4d, R8: %4d, R9: %4d", processor.regfile.regfile[7], processor.regfile.regfile[8], processor.regfile.regfile[9]); 
    
end

endmodule
    