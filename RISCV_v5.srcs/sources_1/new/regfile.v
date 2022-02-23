`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/14/2021 10:18:29 AM
// Design Name: 
// Module Name: regfile
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


module regfile(
    input wire clk,
    input wire rst_n,
    input wire we,        //write_enable control siginal
    input wire [4:0]    rd_addr,
    input wire [4:0]    rs1_addr,
    input wire [4:0]    rs2_addr,
    input wire [31:0]   rd_data_in,
    output reg [31:0]   rs1_data,
    output reg [31:0]   rs2_data
    );
    
    reg [31:0]  regfile [0:31];
    integer i;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i=0;i<=31;i=i+1) begin
                regfile [i]     <= 32'b0;
            end
            rs1_data            <= 32'd0;
            rs2_data            <= 32'd0;
        end
        else if(we) begin
            regfile [rd_addr]   <= rd_data_in;
            regfile [0]         <= 32'b0;
        end
        else begin
            rs1_data            <= regfile [rs1_addr];
            rs2_data            <= regfile [rs2_addr];
        end
    end
endmodule
