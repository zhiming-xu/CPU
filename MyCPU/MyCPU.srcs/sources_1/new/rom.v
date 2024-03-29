`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/08 16:06:48
// Design Name: 
// Module Name: rom
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


module rom(
    input [15:0] addr,
    input ena, 
    input read,
    output [15:0] data
    );
    reg [15:0] rom [255:0];
    initial begin
//        rom[16'd10]=16'b01111_010_0110_0101;
//        rom[16'd11]=16'b10000_010_0000_0000;
//        rom[16'd12]=16'b01111_111_0000_0001;
//        rom[16'd13]=16'b10000_111_0000_0000;
//        rom[16'd14]=16'b01111_001_0000_0010;
//        rom[16'd15]=16'b10000_001_0000_0000;
//        rom[16'd16]=16'b00000_111_001_00000;
//        rom[16'd17]=16'b00100_001_0000_0001;
//        rom[16'd18]=16'b00101_010_001_00000;
//        rom[16'd19]=16'b11011_100_0000_0011;
//        rom[16'd20]=16'b11111_000_0000_0000;
       rom[16'd74]=16'b01111_010_0110_0101;    //movil r2, 0110 0101
       rom[16'd75]=16'b10000_010_0000_0000;    //movih r2, 0000 0000
       rom[16'd76]=16'b01111_111_0000_0001;    //movil r7, 0000 0001
       rom[16'd77]=16'b10000_111_0000_0000;    //movih r7, 0000 0000
       rom[16'd78]=16'b01111_001_0000_0010;    //movil r1, 0000 0010
       rom[16'd79]=16'b10000_001_000_00000;    //movil r1, 0000 0000
       rom[16'd80]=16'b00000_111_001_00000;    //adc r7, r1
       rom[16'd81]=16'b00100_001_0000_0001;    //addi r1, 1
       rom[16'd82]=16'b00101_010_001_00000;    //cmp r2, r1 
       rom[16'd83]=16'b11011_100_000_00011;    //jrnz PC-3
       rom[16'd84]=16'b11111_000_000_00000;    //hlt
        //Program 1, LED
        rom[16'd42]=16'b11110_011_0000_0000;
        rom[16'd43]=16'b11110_100_0000_1000;
        rom[16'd44]=16'b11110_100_011_00000;
        rom[16'd45]=16'b11110_100_0000_0011;    //nop
        rom[16'd46]=16'b10000_001_0000_0001;    //movih r1, 
        rom[16'd47]=16'b01111_001_1000_0000;    //movil r1, 384
        rom[16'd48]=16'b01110_000_001_00000;    //mov r0, r1
        rom[16'd49]=16'b10000_010_0000_0010;    //movih r2, 
        rom[16'd50]=16'b01111_010_0000_0000;    //movil r2, 512
        //The loop starts here
        rom[16'd51]=16'b10011_111_000_00000;    //load M[r0]->r7  30
        rom[16'd52]=16'b10100_000_111_00000;    //store r7->M[r0]
        rom[16'd53]=16'b00100_000_0000_0001;    //addi r0, 1
        rom[16'd54]=16'b00101_010_000_00000;    //cmp r2, r0
        rom[16'd55]=16'b11011_100_000_00100;    //jrnz PC-4
        rom[16'd56]=16'b10011_111_000_00000;    //load M[r0]->r7
        rom[16'd57]=16'b11111_000_000_00000;    //hlt
        //sum_i=1^100
       
    end
    assign data=(read&&ena)?rom[addr]:16'hzzzz;
endmodule
