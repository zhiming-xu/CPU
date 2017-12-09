`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/08 14:26:59
// Design Name: 
// Module Name: risc_cpu
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


module risc_cpu(clkin, reset, addr, indata, outdata, wr_m, rd_m, hlt, io,
//The following variables are used for debug
 cu_ena, sw, pc, ir, fetch, pc_ena, clk);
input clkin;
input  reset;
input [15:0] indata;
input [1:0] sw;
output [15:0] outdata;
output [15:0] addr;
output wr_m, rd_m, hlt;
output [1:0] io;
//The following variables are used for debug
output cu_ena;
output [15:0] pc;
output [15:0] ir;
output pc_ena;
output fetch;
output clk;

wire clkin, clk, clk1, reset, fetch;
wire pc_inc, pc_ena, ir_ena, reg_read1, reg_read2, reg_write1, reg_write2, alu_data_set;
wire flag_set, wr_m, rd_m, sp_pop, sp_push;
wire [1:0] mar_sel;
wire [1:0] mdr_sel;
wire [1:0] io;
wire mar_ena, mdr_ena, alu_ena, hlt;
wire [15:0] pc_addr;
wire [15:0] sp_addr;
wire [15:0] mem_in;
wire [15:0] mem_out;
wire [15:0] reg_out;
wire [15:0] ir_out;
wire [15:0] hi;
wire [15:0] alu_out;
wire [15:0] a;
wire [15:0] b; 
wire [15:0] data_a;
wire [15:0] data_b;
wire [7:0] flag_in;
wire [7:0] flag_out;
wire [15:0] indata;
wire [15:0] outdata;

assign pc=pc_addr;
assign ir=ir_out;
//clock signal 
divider DIVIDER(.clkin(clkin), .clkout(clk));
clock CLOCK(.clk(clk), .clk_r(clk1), .reset(reset), .fetch(fetch));
//controller
cu_contrl  CUCON(.clk(clk1), .cu_ena(cu_ena), .fetch(fetch), .rst(reset));
//control unit
cu CU(.clk(clk1), .cu_ena(cu_ena), .flag_in(flag_in), .op(ir_out[15:11]), .pc_inc(pc_inc),
.pc_ena(pc_ena), .ir_ena(ir_ena), .reg_read1(reg_read1), .reg_read2(reg_read2), 
.reg_write1(reg_write1), .reg_write2(reg_write2), .alu_data_sel(alu_data_sel), .flag_set(flag_set),
.wr_m(wr_m), .rd_m(rd_m), .sp_pop(sp_pop), .sp_push(sp_push), .mar_sel(mar_sel), .mar_ena(mar_ena),
.mdr_sel(mdr_sel), .mdr_ena(mdr_ena), .alu_ena(alu_ena), .hlt(hlt), .io(io)
);
//instruction register
instreg INSREG(.ir_out(ir_out), .data(mem_out), .ir_ena(ir_ena), .clk(clk1), .rst(reset));
//program counter
pc PC(.pc_value(pc_addr), .offset(ir_out[10:0]), .pc_inc(pc_inc), .clk(clk1), .sw(sw),
.pc_ena(pc_ena), .rst(reset));
//stack pointer
sp SP(.clk(clk1), .rst(reset), .sp_pop(sp_pop), .sp_push(sp_push), .sp_value(sp_addr));
//flags
flags FLAGS(.clk(clk1), .rst(reset), .flag_set(flag_set), .flag_in(flag_out), .flag_value(flag_in));
//register array
regarray REGARRAY(.clk(clk1), .rst(reset), .reg_read1(reg_read1), .reg_read2(reg_read2),
.addr1(ir_out[10:8]), .addr2(ir_out[7:5]), .reg_write1(reg_write1), .reg_write2(reg_write2),
.data_in1(alu_out), .data_in2(hi), .data_in3(mem_out), .reg_out1(a), .reg_out2(b)
);
//memory address register
mar MAR(.clk(clk1), .rst(reset), .mar_ena(mar_ena), .mar_sel(mar_sel), .ir_addr1(a),
.ir_addr2(b), .pc_addr(pc_addr), .sp_addr(sp_addr), .mar_addr(addr)
);
//memory data register
mdr MDR(.clk(clk1), .rst(reset), .mdr_ena(mdr_ena), .mdr_sel(mdr_sel), .reg_in1(a), .reg_in2(b),
.reg_out(outdata), .mem_in(indata), .mem_out(mem_out)
);
//arithmetic logic unit
alu ALU(.data_a(data_a), .data_b(data_b), .alu_ena(alu_ena), .alu_opr(ir_out[15:11]), 
.clk(clk1), .flag_in(flag_in), .alu_out(alu_out), .flag_out(flag_out), .hi(hi));
//alu control unit
alu_in_contrl ALUCON(.clk(clk1), .in_a(a), .in_b(b), .data_a(data_a), .data_b(data_b),
.alu_sel(alu_data_sel), .imm(ir_out[7:0]));
endmodule
