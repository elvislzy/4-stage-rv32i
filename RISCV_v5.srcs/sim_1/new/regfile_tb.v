`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/19/2021 12:37:39 AM
// Design Name: 
// Module Name: regfile_tb
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


module regfile_tb(

    );
    reg clk=0;
    reg rst;
    reg we;       //write_enable control siginal
    reg [4:0] rd_addr;
    reg [4:0] rs1_addr;
    reg [4:0] rs2_addr;
    reg [31:0] rd_data_in;
    wire [31:0] rs1_data;
    wire [31:0] rs2_data;
    
    regfile u_regfile(
    .clk        (clk),
    .rst        (rst),
    .we         (we),       //write_enable control siginal
    .rd_addr        (rd_addr),
    .rs1_addr       (rs1_addr),
    .rs2_addr        (rs2_addr),
    .rd_data_in         (rd_data_in),
    .rs1_data           (rs1_data),
    .rs2_data           (rs2_data)
    );
    
    parameter PERIOD    = 20  ;
    reg             cnt_flag    = 1'b0;
    reg     [31:0]  file_dout1  = 32'd0;
    reg     [31:0]  file_tmp    =32'd0;
    reg     [31:0]  file_dout2  =32'd0;
    reg     [31:0]  file_din    =32'd0;
    reg     [4:0]   cnt         =5'b0;
    integer         file_pointer;
    
    initial begin
    file_pointer= $fopen("regfile.txt","r"); 
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
    we=1;
    while (!$feof(file_pointer)) begin
        @(posedge clk);
        #1;
        rd_addr=cnt;
        cnt=cnt+1;     
    end

    cnt_flag = 1'b1;
    we = 0;
    cnt= 5'b0;
    @(posedge clk); 

    while (!$feof(file_pointer)) begin
        @(posedge clk);
        #1;
        rs1_addr=cnt;
        rs2_addr=cnt+1;
        cnt=cnt+2;     
    end
end

initial begin
    #6;     
    while (!$feof(file_pointer)) begin
        @(posedge clk);
        #1;
        $fseek(file_pointer,-8,1);               //set the file_pointer to the previous line
        $fscanf(file_pointer,"%h",file_din);
        $fscanf(file_pointer,"%h",file_tmp); 
        rd_data_in=file_din;
    end 

    @(posedge cnt_flag);
    $fseek(file_pointer,0,0);
    @(posedge clk);
    @(posedge clk);

    while (!$feof(file_pointer)) begin
        @(posedge clk);
        #1;
        $fseek(file_pointer,-8,1);               
        $fscanf(file_pointer,"%h",file_dout1);
        $fscanf(file_pointer,"%h",file_dout2);
        $fscanf(file_pointer,"%h",file_tmp); 
        if (rs1_addr!=5'd2) begin
        if (file_dout1!=rs1_data) begin
            $fatal("Test filed!"); 
            $finish;                      
        end
        end     
        if (file_dout2!=rs2_data) begin
            $fatal("Test filed!");
            $finish;                       
        end   
    end  
             
    $fclose(file_pointer);
    $display("All test cases passed successfully!");
    $finish;
end


endmodule
