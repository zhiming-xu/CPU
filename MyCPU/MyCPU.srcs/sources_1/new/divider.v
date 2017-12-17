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
    input rst,
    input [1:0] clkcon,
    input clkin,        //100MHz
    output reg clkout=0   //?Hz
    );
    integer cnt=0;
    integer num=30_00000;
    
    always @ (posedge clkin)
    begin
        if(!rst)
            casex(clkcon)
                2'b00:
                begin num=5_00000; cnt=0; end
                2'b01:
                begin num=60_00000; cnt=0; end
                2'b10:
                begin num=20_00000; cnt=0; end
                2'b11:
                begin num=10_00000; cnt=0; end
            endcase
        else
        begin
            if(cnt==num)
            begin
                clkout=~clkout;
                cnt=0;
            end
            else
                cnt=cnt+1;
        end
    end
endmodule
