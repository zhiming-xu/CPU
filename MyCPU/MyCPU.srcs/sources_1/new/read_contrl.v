`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/08 16:21:37
// Design Name: 
// Module Name: read_contrl
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


module read_contrl(
    input [15:0] addr_in,
    input rd_in, send_addr,
    output reg [15:0] addr,
    output rd
    );
    assign rd=~rd_in;
    always @ (negedge send_addr)
    begin
        if(!send_addr)
        begin
            addr=addr_in;
        end
    end
endmodule
