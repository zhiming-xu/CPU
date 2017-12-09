`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/07 22:48:22
// Design Name: 
// Module Name: instreg
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


module instreg(
    input clk,  //clock, "fetch" in clock.v
    input rst,  //reset the instruction register
    input [15:0] data,  //data from the bus
    input ir_ena,       //whether to update the instruction register or not
    output reg [15:0] ir_out    //current value of the instruction register
    );
    always @ (posedge clk)
    begin
        if(!rst)
        begin
            ir_out=16'h0000;
        end
        else if(ir_ena) //now bus tranfer instruction to variable data
        begin
            ir_out=data;//in this case, data is the instruction from bus
        end
    end
endmodule
