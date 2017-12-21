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
    input [4:0] port,
    output AUD_PWM,
    output AUD_SD
    );
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
            1: f = 91;
            2: f = 81;
            3: f = 72;
            4: f = 68;
            5: f = 61; 
            6: f = 55;
            7: f = 48;
            8: f = 45;
            9: f = 40;
            10: f = 36;
            11: f = 34;
            12: f = 30;
            13: f = 27;
            14: f = 24;
            15: f = 22;
            16: f = 20;
            17: f = 18;
            18: f = 17;
            19: f = 15;
            20: f = 13;
            21: f = 12;
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
