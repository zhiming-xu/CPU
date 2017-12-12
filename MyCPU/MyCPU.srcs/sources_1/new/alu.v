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


module alu(data_a,data_b,alu_ena,alu_opr,clk,flag_in,alu_out,flag_out,hi);
	input[15:0] data_a;
	input [15:0] data_b;
	input[4:0] alu_opr;
	input alu_ena,clk;
	input[7:0] flag_in;
	output[7:0] flag_out;
	output[15:0] alu_out;
	output [15:0] hi;
(* DONT_TOUCH= "1" *)	reg[15:0] alu_out;
(* DONT_TOUCH= "1" *)	reg [15:0] hi;
(* DONT_TOUCH= "1" *)	reg[7:0] flag_out;
	reg cf;
	parameter   adc = 5'b00000,
				sbb = 5'b00001,
				mul = 5'b00010,
				div = 5'b00011,
				addi = 5'b00100,
				cmp = 5'b00101,
				andd = 5'b00110,
				orr = 5'b00111,
				nott = 5'b01000,
				xorr = 5'b01001,
				test = 5'b01010,
				shl = 5'b01011,
				shr = 5'b01100,
				sar = 5'b01101,
				mov = 5'b01110,
				movil = 5'b01111,
				movih = 5'b10000,
				clc = 5'b11100,
				stc = 5'b11101;
	always @(posedge clk)
	begin
		if(alu_ena)
			begin
				casex(alu_opr) //xxxx,cf,zf,of,sf
					adc:
						begin
							if (data_a == 0 && data_b == 0 && flag_in[3] == 0) 
								begin
									alu_out = 16'b0000_0000_0000_0000;
									flag_out = 8'b0000_0100;
								end
							else 
								begin
									{cf,alu_out[15:0]} = data_a + data_b + flag_in[3];
									flag_out = {4'b0000,cf,1'b0,cf,1'b0};
								end
						end
					sbb:
						begin
							alu_out = data_a - data_b - flag_in[3];
							if (alu_out == 16'b0000_0000_0000_0000) 
							    flag_out = 8'b0000_0100;
							else
								flag_out = 8'b0000_0000;
						end
					mul:
						begin
							if(data_a == 0 || data_b == 0)
								begin
									{hi[15:0],alu_out[15:0]} = 0;
									flag_out = 8'b0000_0100;
								end
							else 
								begin
									{hi[15:0],alu_out[15:0]} = data_a*data_b;
									flag_out = 8'b0000_0000;
								end
						end
					div:
						begin
							if(data_a == 0)
								begin
									alu_out = 16'b0000_0000_0000_0000;
									flag_out = 8'b0000_0100;
								end
							else 
								begin
									alu_out = data_a/data_b;
									flag_out = 8'b0000_0000;
								end
						end
					addi:
						begin
							if(data_a == 0 && data_b == 0)
								begin
									alu_out = 16'b0000_0000_0000_0000;
									flag_out = 8'b0000_0100;
								end
							else 
								begin
									{cf,alu_out[15:0]} = data_a + data_b;
									flag_out = {4'b0000,cf,1'b0,cf,1'b0};
								end
						end
					cmp:
						begin
							if((data_a-data_b)>0)
								flag_out = 8'b0000_0000;	//a>b:zf=0 sf=0
							else if((data_a-data_b) == 0)
								flag_out = {5'b00000,1'b1,2'b00};	//a=b:zf=1 sf=1
							else if((data_b-data_a)>0)
								flag_out = {5'b00000,1'b0,2'b01};	//a<b:zf=0 sf=1
						end
					andd:	alu_out = data_a & data_b;
					orr:	alu_out = data_a | data_b;
					nott:	alu_out = ~data_a;
					xorr:	alu_out = data_a^data_b;
					test:
						begin
							if((data_a & data_b) == 0)
								flag_out = {5'b00000,1'b1,2'b00};
							else
								flag_out = {5'b00000,1'b0,2'b00};	//wtf?
						end
					shl:
						begin
							flag_out = {4'b0000,data_a[15],flag_in[2:0]};
							alu_out = data_a << 1;
						end
					shr:
						begin
							flag_out = {4'b0000,data_a[0],flag_in[2:0]};
							alu_out = data_a >> 1;
						end
					sar:
						begin
							alu_out = data_a >> 1;
							flag_out = flag_in;
						end
					mov:	alu_out = data_b;
					movil:
						begin
							alu_out = {data_a[15:8],data_b[7:0]};
						end
					movih:
						begin
							alu_out = {data_b[7:0],data_a[7:0]};
						end
					clc:	flag_out = {flag_in[7:4],1'b0,flag_in[2:0]};
					stc:	flag_out = {flag_in[7:4],1'b1,flag_in[2:0]};
					default:
						begin
							alu_out = 16'bxxxx_xxxx_xxxx_xxxx;
							hi = 16'bxxxx_xxxx_xxxx_xxxx;
							flag_out = 8'bxxxx_xxxx;
						end
				endcase
			end
	end
endmodule


