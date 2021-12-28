`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/11/07 22:57:29
// Design Name: 
// Module Name: rc5_tb
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
//last change: 2021/11/12 18:00 by lzy 

module alu_tb;
parameter PERIOD    = 10   ;

//I/O
reg             clk                     = 0; 
reg     [31:0]  operand1                = 0;
reg     [31:0]  operand2                = 0;
reg     [3:0]   alu_op                  = 0;
reg     [31:0]  result                  = 0;

wire    [31:0]  alu_out;

//file flag
reg     [63:0]  file_dout   = 64'd0;
reg     [63:0]  file_data0  = 64'd0;
reg     [63:0]  file_data1  = 64'd0;
reg     [63:0]  file_tmp    = 64'd0;
integer         file_pointer;


//clk
initial
begin
    forever #(PERIOD/2)  clk=~clk;
end


//instance
alu u_alu(
    .alu_op             (alu_op     ),
    .operand1           (operand1   ),
    .operand2           (operand2   ),
    .alu_out            (alu_out    )
);

//tb_control
initial begin
    alu_op = 4'b0000;
    @(posedge clk);
    #1000;
    alu_op = 4'b1000;
    #1000;   
    alu_op = 4'b0001;
    #1000;   
    alu_op = 4'b0010;
    #1000;   
    alu_op = 4'b0011;
    #1000;   
    alu_op = 4'b0100;
    #1000;   
    alu_op = 4'b0101;
    #1000;   
    alu_op = 4'b1101;
    #1000;   
    alu_op = 4'b0110;
    #1000;   
    alu_op = 4'b0111;
    #1000;   

    #10000;

end


//read file 
initial begin
    file_pointer= $fopen("random_dataset.txt","r"); 
    if(file_pointer==0) begin
        $display("Can't open the file.");
        $finish;
    end

    @(posedge clk);
    while (!$feof(file_pointer)) begin
   
        $fseek(file_pointer,-8,1);               //set the file_pointer to the previous line(64 bits = 16 bytes)
        $fscanf(file_pointer,"%h",file_data0);
        $fscanf(file_pointer,"%h",file_data1);
        $fscanf(file_pointer,"%h",file_tmp);     //the txt will have a blank line at the end of the file(since i use /n to divide each data)
                                                 //this line is to let the pointer point to the next two line 
                                                 //so that the while loop would be able to stop at the right position 
        operand1 = file_data0;
        operand2 = file_data1;

        #1;
        //Compare output
        if(alu_out!=result) begin
            $display("alu_op = ", alu_op);
            $display("operand1:",operand1);
            $display("operand2:",operand2);
            $display("alu_out:",alu_out);          
            $fatal("Test Case failed!"); 
            $finish;
        end
        #9;
    end
    
    $fclose(file_pointer);
    $display("All alu test cases passed successfully!");
    $finish;
end

//initialize standard result
initial begin     
    forever begin
        case(alu_op)
            4'b0000: result = $signed(operand1) + $signed(operand2);
            4'b1000: result = $signed(operand1) - $signed(operand2);       
            4'b0001: result = operand1 << operand2[4:0];       
            4'b0010: result = $signed(operand1) < $signed(operand2);
            4'b0011: result = operand1 < operand2;
            4'b0100: result = operand1 ^ operand2;
            4'b0101: result = operand1 >> operand2[4:0];
            4'b1101: result = ($signed(operand1)) >>> operand2[4:0];
            4'b0110: result = operand1 | operand2;
            4'b0111: result = operand1 & operand2;
            default: result = 32'd0;
        endcase     
        #1;
    end
end

endmodule