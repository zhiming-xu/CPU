`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/07 22:10:13
// Design Name: 
// Module Name: clock
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


module clock(
    input clk,
    input reset,
    output reg fetch,
    output clk_r
    );
    integer cnt=0;
    
    assign clk_r=~clk;
    always @ (negedge clk)
    begin
        if(!reset)
        begin
            cnt=0;
            fetch=0;
        end
        else
        begin
            if(cnt==3)
            begin
                cnt=cnt+1;
                fetch=1;
            end
            else if(cnt==7)
            begin
                cnt=0;
                fetch=0;
            end
            else
            begin
                cnt=cnt+1;
            end
        end
    end
endmodule
