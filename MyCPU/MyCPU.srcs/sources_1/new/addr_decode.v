`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/08 16:03:53
// Design Name: 
// Module Name: addr_decode
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


module addr_decode(
    input [15:0] addr,
    output reg rom_sel,
    output reg ram_sel
    );
    always @ (addr)
    begin
//        casex(addr)
//        16'b0000_0000_xxxx_xxxx: {rom_sel, ram_sel}=2'b10;
//        16'b0000_0001_xxxx_xxxx: {rom_sel, ram_sel}=2'b01;
//        16'b0000_0010_xxxx_xxxx: {rom_sel, ram_sel}=2'b01;
//        default: {rom_sel, ram_sel}=2'b00;
//        endcase
        if(addr<16'h0100)
            {rom_sel, ram_sel}=2'b10;
        else if(addr>=16'h0100&&addr<16'h0300)
            {rom_sel, ram_sel}=2'b01;
        else
            {rom_sel, ram_sel}=2'b00;
    end
endmodule
