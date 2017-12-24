`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/21 08:34:23
// Design Name: 
// Module Name: ramsim
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


module ramsim();
reg [15:0] addr;
reg [15:0] indata;
reg read, write, ena;
wire [15:0] outdata;
ram RAM(.addr(addr), .indata(indata), .ena(ena), .write(write), .read(read), .outdata(outdata));
initial begin
    ena=1;
    addr=16'd386;
    indata=16'd15;
    write=1;    #50;
    write=0;    #50;
    read=1;     #50;
    read=0;     #50;
    addr=16'd512;
    indata=16'd256;
    write=1;    #50;
    write=0;    #50;
    read=1;     #50;
    read=0;     #50;
end
endmodule
