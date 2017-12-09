`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/08 14:24:20
// Design Name: 
// Module Name: flags
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


module flags(
    input clk,
    input rst,
    input flag_set,
    input [7:0] flag_in,
(* DONT_TOUCH= "1" *)    output reg [7:0] flag_value
    );
    always @ (posedge clk or negedge rst)
    begin
        if(!rst)
        begin
            flag_value=8'h00;
        end
        else if(flag_set)
        begin
            flag_value=flag_in;
        end
    end
endmodule
