`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/18 10:37:04
// Design Name: 
// Module Name: IntegralAudio
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


module integralaudio(
    input clk,  //100MHz
    input [4:0] portin,
    input [1:0] sw,
    output AUD_PWM,
    output AUD_SD
    );
    wire [4:0] port;
    assign port=(sw==2'b01)?portin:5'bzzzzz;
    //clock
    assign AUD_SD=1;
    reg clk_48khz=0;
    integer n1 = 0;
    always @ (posedge clk)
    begin
        if (n1 == 2084)
        begin
            n1 = 0;
            clk_48khz = ~clk_48khz;
        end
        else
            n1 = n1 + 1;
        end
        
    //Wave Generator
    reg [7:0] sin [255:0];
        integer n, k;
        integer f=0;
        initial begin
            $readmemh("E:/steve/Documents/audio.txt", sin, 0, 255);
        end
        
        always @ (posedge clk_48khz)
        begin
            if (f!=0)
            begin
                n = n + 1;
                if (n == f)
                    n = 0;
                k = ((n * 256) / f) % 256;    
            end
            else
            begin
                n = 0;
                k = 0;
            end
        end
        
        always @ (port)
        begin
            case (port)
            1: f = 182;
            2: f = 162;
            3: f = 144;
            4: f = 136;
            5: f = 122;
            6: f = 110;
            7: f = 96;
            
            8: f = 91;
            9: f = 81;
           10: f = 72;
           11: f = 68;
           12: f = 61; 
           13: f = 55;
           14: f = 48;
           
           15: f = 45;
           16: f = 40;
           17: f = 36;
           18: f = 34;
           19: f = 30;
           20: f = 27;
           21: f = 24;
           
           22: f = 22;
           23: f = 20;
           24: f = 18;
           25: f = 17;
           26: f = 15;
           27: f = 13;
           28: f = 12;
            default: f = 0;
            endcase;
        end 
        assign pwm_data = sin[k];
        
        //PWM
        integer n2=0;
        always @ (posedge clk)
        begin        
            if (n2 == 255)
                n2 = 0;
            else 
                n2 = n2 + 1; 
        end
        assign AUD_PWM = (n2 < pwm_data);
endmodule
