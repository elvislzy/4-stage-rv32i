`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/14/2021 12:11:52 PM
// Design Name: 
// Module Name: instr_mem
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


module instr_mem(
  input wire              clk,
  input wire      [31:0]  addr,
  input wire              instr_en,
  output reg      [31:0] instr_out
);
  reg [31:0] imem_out;  
  wire[9:0]  imem_addr;
  wire[31:0] imem_data;
  parameter Depth = 1024;
  (*ram_style="block"*) reg [31:0] imem [Depth-1:0];
  
  initial begin
      $readmemh("imem.txt",imem);
  end

  assign imem_addr = addr[11:2];

  always @(posedge clk) begin
    if(instr_en) begin
      imem_out <= imem[imem_addr];
    end
  end

  assign imem_data = imem_out;

  always @(*) begin
    case(addr[1:0])
      2'b00 : instr_out = imem_data;
      2'b01 : instr_out = {imem_data[23:0],8'd0};
      2'b10 : instr_out = {imem_data[15:0],16'd0};
      2'b11 : instr_out = {imem_data[7:0],24'd0};
      default : instr_out = 'hz;
    endcase
  end




endmodule
