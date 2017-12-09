`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/08 15:18:29
// Design Name: 
// Module Name: cu_contrl
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


module cu_contrl(
    input clk,
    input fetch,
    input rst,
    output reg cu_ena
    );
    always @ (posedge clk)
    begin
        if(!rst)    //originally low voltage effective, I think it should be changed
        begin
            cu_ena=0;
        end
        else if(fetch)
        begin
            cu_ena=1;
        end
    end
endmodule
