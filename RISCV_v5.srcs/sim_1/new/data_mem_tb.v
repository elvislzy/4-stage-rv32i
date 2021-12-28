`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/18/2021 08:26:10 PM
// Design Name: 
// Module Name: data_mem_tb
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


module data_mem_tb(

    );
    reg             clk         = 0;
    reg             rst         = 0;
    reg     [31:0]  addr        = 32'd0;
    reg     [3:0]   we          = 4'd0;
    reg             re          = 0;
    reg     [31:0]  dmem_in     = 32'b0;
    wire    [31:0]  dmem_out;
    reg     [31:0]  file_tmp    = 32'd0;
    
    data_mem u_data_mem(
    .clk        (clk),
    .rst        (rst),
    .addr       (addr),
    .we         (we),
    .re         (re),
    .dmem_in        (dmem_in),
    .dmem_out       (dmem_out)
    );
    
parameter PERIOD    = 20  ;
reg             cnt_flag    = 1'b0;
reg     [31:0]  file_dout   = 32'd0;
reg     [31:0]  file_din    =32'd0;
reg     [9:0]   cnt=10'b0;
integer         file_pointer;

    initial begin
    file_pointer= $fopen("dmem_v1.txt","r"); 
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

initial begin
    #1;
    rst=1;
    #5;
    we=4'b1111;
    while (!$feof(file_pointer)) begin
        @(posedge clk);
        #1;
        addr={1'b1,{19{1'b0}},cnt,2'b00};
        cnt=cnt+1;     
    end
    cnt_flag = 1;

    we = 4'b0000;
    re = 1;
    cnt=9'b0;
    @(posedge clk); 

    while (!$feof(file_pointer)) begin
        @(posedge clk);
        #1;
        addr={1'b1,{19{1'b0}},cnt,2'b00};
        cnt=cnt+1;     
    end
end

initial begin
    #6;     
    while (!$feof(file_pointer)) begin
        @(posedge clk);
        #1;
        $fseek(file_pointer,-8,1);               //set the file_pointer to the previous lined
        $fscanf(file_pointer,"%h",file_din);
        $fscanf(file_pointer,"%h",file_tmp); 
        dmem_in=file_din;
    end 
    
    @(posedge cnt_flag);
    $fseek(file_pointer,0,0);
    @(posedge clk);
    @(posedge clk);
    while (!$feof(file_pointer)) begin
        @(posedge clk);
        #1;
        $fseek(file_pointer,-8,1);               
        $fscanf(file_pointer,"%h",file_dout);
        $fscanf(file_pointer,"%h",file_tmp); 
        if (file_dout!=dmem_out) begin
            $fatal("Test Case failed!"); 
            $finish;                  
        end     
    end  
             
    $fclose(file_pointer);
    $display("All test cases passed successfully!");
    $finish;

end
       
endmodule
