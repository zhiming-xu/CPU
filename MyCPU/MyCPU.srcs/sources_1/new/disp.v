`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/09 11:06:34
// Design Name: 
// Module Name: display
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


module display(
    input [3:0] dis,
    output reg [6:0] seg
    );
    always @ (dis)
    begin
        case(dis)                   
        0: seg=7'b1000000;       
        1: seg=7'b1111001;       
        2: seg=7'b0100100;       
        3: seg=7'b0110000;       
        4: seg=7'b0011001;       
        5: seg=7'b0010010;       
        6: seg=7'b0000010;       
        7: seg=7'b1111000;       
        8: seg=7'b0000000;       
        9: seg=7'b0010000;       
       10: seg=7'b0001000;       
       11: seg=7'b0000011;       
       12: seg=7'b1000110;       
       13: seg=7'b0100001;       
       14: seg=7'b0000110;       
       15: seg=7'b0001110;       
       default: seg=7'bx;    
       endcase
    end
endmodule
