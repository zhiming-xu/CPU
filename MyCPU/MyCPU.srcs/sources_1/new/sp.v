`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/07 23:48:36
// Design Name: 
// Module Name: sp
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: This is the stack pointer (sp)
// 
//////////////////////////////////////////////////////////////////////////////////


module sp(
    input clk,
    input rst,
    input sp_pop,
    input sp_push,
    output reg [15:0] sp_value//stack top pointer, similiar to esp
    );
    
    always @ (posedge clk)
    begin
        if(!rst)
        begin
            sp_value=16'h0200;
        end
        else 
        begin
            if(sp_push)
            begin
                sp_value=sp_value+1'b1;
            end
            else if(sp_pop)
            begin
                sp_value=sp_value-1'b1;
            end
        end
    end
endmodule
