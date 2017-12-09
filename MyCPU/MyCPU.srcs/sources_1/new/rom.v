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
        rom[42]=16'b01111_001_000_00001;
        rom[43]=16'b10000_001_000_00000;
        rom[44]=16'b01110_000_001_00000;
        rom[45]=16'b10100_100_000_00000;
        rom[46]=16'b01011_000_000_00000;
        rom[47]=16'b11001_100_000_00010;
        rom[48]=16'b10111_100_000_00100;
    end
    assign data=(read&&ena)?rom[addr]:16'hzzzz;
endmodule
