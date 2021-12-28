`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/18/2021 04:14:05 PM
// Design Name: 
// Module Name: instr_mem_tb
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


module instr_mem_tb;
    
reg [31:0] pc=32'b0;
wire [31:0] instr_out;
reg clk=0;
reg rst=0;
reg instr_en = 0;

 //file flag
parameter PERIOD            = 10;
reg     [31:0]  file_dout   = 32'd0;
reg     [31:0]  file_tmp    = 32'd0;
reg     [8:0]   cnt         = 9'b0;
integer         file_pointer;


instr_mem u_instr_mem(
.clk        (clk),
.rst        (rst),
.pc         (pc),
.instr_en   (instr_en),
.instr_out  (instr_out)
);


initial begin
    file_pointer= $fopen("imem.txt","r"); 
    if(file_pointer==0) begin
        $display("Can't open the file.");
        $finish;
    end
end    

//clk
initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

//Rst
initial begin
    #5 
    rst = 1;
end 



initial begin
    #6;
    instr_en = 1;
    while (!$feof(file_pointer)) begin
        @(posedge clk);
        #1;
        pc={cnt,2'b00};
        cnt=cnt+1;     
    end
end

initial begin
    #6;
    @(posedge clk);        
    while (!$feof(file_pointer)) begin
        @(posedge clk);
        #1;

        $fseek(file_pointer,-8,1);
        $fscanf(file_pointer,"%h",file_dout);
        $fscanf(file_pointer,"%h",file_tmp);

        if (file_dout!=instr_out) begin
            $display("Test filed!");
            $finish;
        end     
    end
        
    $fclose(file_pointer);
    $display("All test cases passed successfully!");
    $finish;
end                 
          
endmodule
