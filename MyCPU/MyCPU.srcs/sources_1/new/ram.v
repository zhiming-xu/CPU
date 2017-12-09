`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/08 16:08:54
// Design Name: 
// Module Name: ram
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


module ram(
    input [15:0] addr,
    input [15:0] indata,
    input ena, 
    input read,
    input write,
    output [15:0] outdata
    );
    reg [15:0] ram [767:256];
    assign outdata=(read&&ena)?ram[addr]:16'hzzzz;
    always @ (posedge write)
    begin
        ram[addr]=indata;
    end
endmodule