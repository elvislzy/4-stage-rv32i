`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/01/06 15:05:43
// Design Name: 
// Module Name: processor_top
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


module processor_top(
    clk,
    rst_n
);

input  wire                     clk;
input  wire                     rst_n;

//processor_ctrl
wire                            branch;
wire                            jump;
wire    [1:0]                   Regsrc;
wire                            PCsrc;
wire    [1:0]                   ALUsrc;


//PC
wire                            pc_en;
wire    [31:0]                  pc_tmp;
wire    [31:0]                  pc;
wire                            pc_jump;
wire    [31:0]                  pc_add;
wire    [31:0]                  pc_add4;
wire    [31:0]                  pc_imm;

//instr_mem
wire                            instr_en;
wire    [31:0]                  instruction;


//registor_file
wire                            RegWrite;
wire    [31:0]                  rd_data_in;
wire    [31:0]                  rs1_data;
wire    [31:0]                  rs2_data;

//imm_gen
reg     [31:0]                  imm_ext;
wire    [31:0]                  imm_ext_tmp;

//alu_ctrl
wire    [3:0]                   alu_op;

//alu
wire    [31:0]                  operand1;
wire    [31:0]                  operand2;
wire    [31:0]                  alu_out_tmp;
reg     [31:0]                  alu_out;

//data_mem
wire                            MemRead;
wire    [3:0]                   MemWrite;
wire    [31:0]                  dmem_out;                  

//data_ext
wire    [31:0]                  data_ext_out;

//branch
wire    [2:0]                   funct3;
wire                            branch_true;
wire                            alu_true;

//////////////////////////////////////////////////////////////////////////////////
//Module
//////////////////////////////////////////////////////////////////////////////////
processor_ctrl processor_ctrl(
    .clk                         (clk                ),
    .rst_n                       (rst_n              ),
    .opcode                      (instruction[6:0]   ),
    .funct3                      (instruction[14:12] ),
    .Branch                      (branch             ),
    .Jump                        (jump               ),
    .MemRead                     (MemRead            ),
    .Regsrc                      (Regsrc             ),
    .MemWrite                    (MemWrite           ),
    .PCsrc                       (PCsrc              ),
    .ALUsrc                      (ALUsrc             ),
    .RegWrite                    (RegWrite           ),
    .PC_en                       (pc_en              ),
    .instr_en                    (instr_en           )
);

PC PC(
    .clk                         (clk                ),
    .rst_n                       (rst_n              ),
    .en                          (pc_en              ),
    .pc_tmp                      (pc_tmp             ),
    .pc                          (pc                 )
);

instr_mem instr_mem(
    .clk                         (clk                ),
    .addr                        (pc                 ),
    .instr_en                    (instr_en           ),
    .instr_out                   (instruction        )
);

regfile regfile(
    .clk                         (clk                ),
    .rst_n                       (rst_n              ),
    .we                          (RegWrite           ),        //write_enable control siginal
    .rd_addr                     (instruction[11:7]  ),
    .rs1_addr                    (instruction[19:15] ),
    .rs2_addr                    (instruction[24:20] ),
    .rd_data_in                  (rd_data_in         ),
    .rs1_data                    (rs1_data           ),
    .rs2_data                    (rs2_data           )
);


imm_gen imm_gen(
    .instruction                 (instruction        ),
    .imm_ext                     (imm_ext_tmp        )
);

alu_ctrl alu_ctrl(
    .clk                         (clk                ),
    .rst_n                       (rst_n              ),
    .opcode                      (instruction[6:0]   ),    
    .funct3                      (instruction[14:12] ),
    .instr30                     (instruction[30]    ),
    .alu_op                      (alu_op             )
);

alu alu(
    .alu_op                      (alu_op             ),
    .operand1                    (operand1           ),
    .operand2                    (operand2           ),
    .alu_out                     (alu_out_tmp        )
);

data_mem data_mem(
    .clk                         (clk                ),
    .addr                        (alu_out            ),
    .we                          (MemWrite           ),             //0001--SB, 0011--SH, 1111--SW, 0000--write disable
    .re                          (MemRead            ),
    .dmem_in                     (rs2_data           ),
    .dmem_out                    (dmem_out           )
);

data_ext data_ext(
    .data_in                     (dmem_out           ),
    .funt3                       (instruction[14:12] ),
    .data_out                    (data_ext_out       )
);

//pc_adder
assign  pc_add4 = pc + 32'd4;
assign  pc_imm  = pc + imm_ext;

//////////////////////////////////////////////////////////////////////////////////
//MUX
//////////////////////////////////////////////////////////////////////////////////
//reg_mux
assign  rd_data_in  = Regsrc[0] ? Regsrc[1] ? pc_add4       //'11'
                    : data_ext_out                          //'01'
                    : Regsrc[1] ? imm_ext                   //'10'
                    : alu_out;                              //'00'

//pc_mux
assign  funct3      = instruction[14:12];
assign  alu_true    = alu_out == 32'd0;
assign  branch_true = ((funct3 == 3'b000) & alu_true)
                    | ((funct3 == 3'b001) & !alu_true)
                    | ((funct3 == 3'b100) & !alu_true)
                    | ((funct3 == 3'b101) & alu_true)
                    | ((funct3 == 3'b110) & !alu_true)
                    | ((funct3 == 3'b111) & alu_true);

assign  pc_jump     = (branch_true & branch) | jump;
assign  pc_add      = PCsrc ? alu_out : pc_imm;
assign  pc_tmp      = pc_jump ? pc_add : pc_add4;
                    
//alu_mux
assign  operand1    = ALUsrc[0] ? pc : rs1_data;
assign  operand2    = ALUsrc[1] ? imm_ext : rs2_data;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        alu_out     <= 32'd0;
    end
    else begin 
       alu_out      <= alu_out_tmp; 
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        imm_ext     <= 32'd0;
    end
    else begin
        imm_ext     <= imm_ext_tmp;
    end
end


endmodule
