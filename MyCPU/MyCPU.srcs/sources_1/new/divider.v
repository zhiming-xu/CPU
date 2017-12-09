`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/09 09:38:15
// Design Name: 
// Module Name: divider
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


module divider(
    input clkin,        //100MHz
    output reg clkout=0   //4Hz
    );
    integer cnt=0;
    parameter num=125_00000;
    always @ (posedge clkin)
    begin
        if(cnt==num)
        begin
            clkout=~clkout;
            cnt=0;
        end
        else
            cnt=cnt+1;
    end
endmodule
