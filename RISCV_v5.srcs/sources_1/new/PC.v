`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/14/2021 09:53:35 AM
// Design Name: 
// Module Name: PC
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


module PC(
    input wire clk,
    input wire rst_n,
	input wire en,
    input wire [31:0] pc_tmp,
    output reg [31:0] pc
    );
    
    always @(posedge clk or negedge rst_n) begin
        if (rst_n==0)
            pc	<= 32'h01000000;
        else if(en)
            pc	<= pc_tmp;
    end
endmodule
