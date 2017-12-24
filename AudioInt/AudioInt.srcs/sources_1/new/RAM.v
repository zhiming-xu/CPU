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
    //The songs' nodes begin at 256+128=384
    initial begin
        ram[384]=16'd22;
        ram[385]=16'd22;
        ram[386]=16'd13;
        ram[387]=16'd14;
        ram[388]=16'd15;
        ram[389]=16'd17;
        
        ram[390]=16'd20;
        ram[391]=16'd20;
        ram[392]=16'd20;
        ram[393]=16'd20;
        ram[394]=16'd13;
        ram[395]=16'd14;
        ram[396]=16'd15; 
        ram[397]=16'd16;

        ram[398]=16'd20; 
        ram[399]=16'd20; 
        ram[400]=16'd20; 
        ram[401]=16'd20; 
        ram[402]=16'd16; 
        ram[403]=16'd15; 
        ram[404]=16'd21;    
        ram[405]=16'd15;

        ram[406]=16'd20; 
        ram[407]=16'd20; 
        ram[408]=16'd20;        
        ram[409]=16'd20; 
        ram[410]=16'd20; 
        ram[411]=16'd20; 
        ram[412]=16'd20; 
        ram[413]=16'd20;
    end
    assign outdata=(read&&ena)?ram[addr]:16'hzzzz;
    always @ (posedge write)
    begin
        ram[addr]=indata;
    end
endmodule