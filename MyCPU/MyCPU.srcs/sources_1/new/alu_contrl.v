`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/08 15:12:57
// Design Name: 
// Module Name: alu_contrl
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


module alu_in_contrl(clk,in_a,in_b,data_a,data_b,alu_sel,imm);
	input[15:0] in_a,in_b;
	input[7:0] imm;
	input alu_sel,clk;
	output[15:0] data_a;
	output [15:0] data_b;
(* DONT_TOUCH= "1" *)	reg[15:0] data_a;
(* DONT_TOUCH= "1" *)	reg [15:0] data_b;

	always @(posedge clk)
		begin
			if(alu_sel)
				begin
					data_a <= in_a;
					data_b <= imm;
				end
			else 
				begin
					data_a <= in_a;
					data_b <= in_b;
				end
		end
endmodule
