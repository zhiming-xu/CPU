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
    input [2:0] clkcon,
    input clkin,        //100MHz
    output reg clkout=0   //Hz
    );
    integer cnt=0;
    integer num=30_00000;
    
    always @ (posedge clkin)
    begin
        if(!rst)
            casex(clkcon)
                3'b000:
                begin num=80_00000; cnt=0; end
                3'b001:
                begin num=20_00000; cnt=0; end
                3'b010:
                begin num=10_00000; cnt=0; end
                3'b011:
                begin num=3_20000; cnt=0; end
                3'b100:
                begin num=1_00000; cnt=0; end
                3'b101:
                begin num=5_0000; cnt=0; end
                3'b110:
                begin num=700; cnt=0; end
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
