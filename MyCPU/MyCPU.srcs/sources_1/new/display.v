`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/08 16:45:41
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


module display_control(
    input [15:0] pc,
    input [15:0] ir,
    input clk,
    output reg [7:0] seg_sel,
    output reg [3:0] dis
    );
    integer index=0;
    always @ (posedge clk)
    begin
        if(index==50000000)
        begin
            index=0;
        end
        else
        begin
            index=index+1;
        end
    end
    
    always @ (index)
    begin
        case(index[18:16])
        3'b000:
        begin seg_sel=8'b11111110; dis=pc[3:0]; end
        3'b001:
        begin seg_sel=8'b11111101; dis=pc[7:4]; end
        3'b010:
        begin seg_sel=8'b11111011; dis=pc[11:8]; end
        3'b011:
        begin seg_sel=8'b11110111; dis=pc[15:12]; end
        3'b100:
        begin seg_sel=8'b11101111; dis=ir[3:0]; end
        3'b101:
        begin seg_sel=8'b11011111; dis=ir[7:4]; end
        3'b110:
        begin seg_sel=8'b10111111; dis=ir[11:8]; end
        3'b111:
        begin seg_sel=8'b01111111; dis=ir[15:12]; end
        endcase
    end
endmodule