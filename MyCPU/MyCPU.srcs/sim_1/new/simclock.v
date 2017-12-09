`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/07 22:13:58
// Design Name: 
// Module Name: simclock
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


module simclock();
reg reset;
reg clk=0;
wire clk_r;
wire fetch;
clock SIMCLOCK(.reset(reset), .clk(clk), .clk_r(clk_r), .fetch(fetch));
initial begin
    forever #10 clk=~clk;
end
endmodule
