`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/08 09:21:58
// Design Name: 
// Module Name: cu
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


module cu(
    input clk,
    input cu_ena,
    input [7:0] flag_in,//eflags
    input [4:0] op,     //operand code
    output reg ir_ena,  //instruction register update?
(* DONT_TOUCH= "1" *)   output reg alu_data_sel,    //alu data select
(* DONT_TOUCH= "1" *)    output reg alu_ena,  //alu enable
    output reg pc_ena,  //PC enable
    output reg flag_set,//set eflags
    output reg pc_inc,  //PC increment
    output reg hlt, //halt signal
    output reg rd_m,//memory read signal
(* DONT_TOUCH= "1" *)    output reg [1:0] io,//I/O control signal
    output reg wr_m,//memory write signal
    output reg mar_ena, //memory address register enable
    output reg sp_pop,  //stack pointer pop
    output reg [1:0] mar_sel,   //mar input select
    output reg [1:0] mdr_sel,   //mdr input select
    output reg sp_push, //stack pointer push
    output reg mdr_ena, //memory data register enable
    output reg reg_read1,//register read signals
    output reg reg_read2,
    output reg reg_write1,//register write signals
    output reg reg_write2,
    output reg [3:0] state
    );
    //reg [3:0] state;
    
    //opcode for each operation
    parameter adc=5'b00000,
              sbb=5'b00001,
              mul=5'b00010,
              div=5'b00011,
             addi=5'b00100,
              cmp=5'b00101,
             andd=5'b00110,
              orr=5'b00111,
             nott=5'b01000,
             xorr=5'b01001,
             test=5'b01010,
              shl=5'b01011,
              shr=5'b01100,
              sar=5'b01101,
              mov=5'b01110,
            movil=5'b01111,
            movih=5'b10000,
               in=5'b10001,
              out=5'b10010,
             load=5'b10011,
            store=5'b10100,
             push=5'b10101,
              pop=5'b10110,
               jr=5'b10111,//jmp
              jrc=5'b11000,//jmp if carry
             jrnc=5'b11001,//jmp if not carry
              jrz=5'b11010,//jmp if equal
             jrnz=5'b11011,//jmp if not equal
              clc=5'b11100,//clear carry
              stc=5'b11101,//set carry to 1
              nop=5'b11110,
             halt=5'b11111;
             
    always @ (negedge clk)
    begin
        if(!cu_ena)//cu_ena=0, initialize all output ports to 0
        begin
            state=4'b0000;
            {pc_inc, pc_ena, ir_ena, reg_read1, reg_read2,
            reg_write1, reg_write2, alu_data_sel}=8'h00;
            
            {alu_ena, hlt, io, flag_set, wr_m, rd_m}=7'b0000000;
            {sp_pop, sp_push, mar_sel, mar_ena, mdr_ena, mdr_sel}=8'h00;
        end
        else
        begin
            control_cycle;
        end
    end
    task control_cycle;
    begin
        casex(state)
        4'b0000:
        begin
            {pc_inc, pc_ena, ir_ena, reg_read1,
            reg_read2, reg_write1, reg_write2, alu_data_sel}=8'h00;
            {alu_ena, hlt, io, flag_set, wr_m, rd_m}=7'b0000000;
            {sp_pop, sp_push, mar_sel, mar_ena, mdr_ena, mdr_sel}=8'b00001000;
            state=4'b0001;
        end
        4'b0001:
        begin
            {pc_inc, pc_ena, ir_ena, reg_read1,
            reg_read2, reg_write1, reg_write2, alu_data_sel}=8'h00;
            {alu_ena, hlt, io, flag_set, wr_m, rd_m}=7'b0000001;
            {sp_pop, sp_push, mar_sel, mar_ena, mdr_ena, mdr_sel}=8'h00;
            state=4'b0010;
        end
        4'b0010:
        begin
            {pc_inc, pc_ena, ir_ena, reg_read1,
            reg_read2, reg_write1, reg_write2, alu_data_sel}=8'h00;
            {alu_ena, hlt, io, flag_set, wr_m, rd_m}=7'b0000001;
            {sp_pop, sp_push, mar_sel, mar_ena, mdr_ena, mdr_sel}=8'h07;//111
            state=4'b0011;
        end
        4'b0011:
        begin
            {pc_inc, pc_ena, ir_ena, reg_read1,
            reg_read2, reg_write1, reg_write2, alu_data_sel}=8'h20;
            {alu_ena, hlt, io, flag_set, wr_m, rd_m}=7'b0000000;  
            {sp_pop, sp_push, mar_sel, mar_ena, mdr_ena, mdr_sel}=8'h00;
            state=4'b0100;        
        end
        4'b0100:
        begin
            {pc_inc, pc_ena, ir_ena, reg_read1,
            reg_read2, reg_write1, reg_write2, alu_data_sel}=8'h18;
            {alu_ena, hlt, io, flag_set, wr_m, rd_m}=7'b0000000;
            {sp_pop, sp_push, mar_sel, mar_ena, mdr_ena, mdr_sel}=8'h00;
            state=4'b0101;    
        end
        4'b0101:
        begin
            //if(op==adc||op==sbb||op==mul||op==div||op==orr||op==andd||op==xorr||
            //op==test||op==cmp||op==nott||op==shl||op==sar||op==shr||op==mov)
            casex(op)
            adc, sbb, mul, div, orr, andd, xorr, test, cmp, nott, shl, sar, shr, mov:
            begin
                {pc_inc, pc_ena, ir_ena, reg_read1,
                reg_read2, reg_write1, reg_write2, alu_data_sel}=8'h40;
                {alu_ena, hlt, io, flag_set, wr_m, rd_m}=7'b0000000;
                {sp_pop, sp_push, mar_sel, mar_ena, mdr_ena, mdr_sel}=8'h00;
            end
            //else if(op==addi||op==movil||op==movih)
            addi, movil, movih:
            begin
                {pc_inc, pc_ena, ir_ena, reg_read1,
                reg_read2, reg_write1, reg_write2, alu_data_sel}=8'h41;
                {alu_ena, hlt, io, flag_set, wr_m, rd_m}=7'b0000000;
                {sp_pop, sp_push, mar_sel, mar_ena, mdr_ena, mdr_sel}=8'h00;
            end
            //else if(op==jr||op==jrc||op==jrnc||op==jrz||op==jrnz)
            jr, jrc,jrnc, jrz, jrnz:
            begin
                if(op==jr||((op==jrc)&&flag_in[3])||((op==jrnc)&&(!flag_in[3]))||
                ((op==jrz)&&flag_in[2])||((op==jrnz)&&(!flag_in[2])))
                begin
                    {pc_inc, pc_ena, ir_ena, reg_read1,
                    reg_read2, reg_write1, reg_write2, alu_data_sel}=8'hc0;
                    {alu_ena, hlt, io, flag_set, wr_m, rd_m}=7'b0000000;
                    {sp_pop, sp_push, mar_sel, mar_ena, mdr_ena, mdr_sel}=8'h00;
                end
                else if(op==jr||((op==jrc)&&(!flag_in[3]))||((op==jrnc)&&(flag_in[3]))||
                ((op==jrz)&&(!flag_in[2]))||((op==jrnz)&&(flag_in[2])))
                begin
                    {pc_inc, pc_ena, ir_ena, reg_read1,
                    reg_read2, reg_write1, reg_write2, alu_data_sel}=8'h40;
                    {alu_ena, hlt, io, flag_set, wr_m, rd_m}=7'b0000000;
                    {sp_pop, sp_push, mar_sel, mar_ena, mdr_ena, mdr_sel}=8'h00;
                end
            end
            //else if(op==load||op==in)
            load, in:
            begin
                {pc_inc, pc_ena, ir_ena, reg_read1,
                reg_read2, reg_write1, reg_write2, alu_data_sel}=8'h40;
                {alu_ena, hlt, io, flag_set, wr_m, rd_m}=7'b0000000;
                {sp_pop, sp_push, mar_sel, mar_ena, mdr_ena, mdr_sel}=8'h28;
            end
            //else if(op==store||op==out)
            store, out:
            begin
                {pc_inc, pc_ena, ir_ena, reg_read1,
                reg_read2, reg_write1, reg_write2, alu_data_sel}=8'h40;
                {alu_ena, hlt, io, flag_set, wr_m, rd_m}=7'b0000000;
                {sp_pop, sp_push, mar_sel, mar_ena, mdr_ena, mdr_sel}=8'h1e;
            end
            //else if(op==push)
            push:
            begin
                {pc_inc, pc_ena, ir_ena, reg_read1,
                reg_read2, reg_write1, reg_write2, alu_data_sel}=8'h40;
                {alu_ena, hlt, io, flag_set, wr_m, rd_m}=7'b0000000;
                {sp_pop, sp_push, mar_sel, mar_ena, mdr_ena, mdr_sel}=8'h40;
            end
            //else if(op==pop)
            pop:
            begin
                {pc_inc, pc_ena, ir_ena, reg_read1,
                reg_read2, reg_write1, reg_write2, alu_data_sel}=8'h40;
                {alu_ena, hlt, io, flag_set, wr_m, rd_m}=7'b0000000;
                {sp_pop, sp_push, mar_sel, mar_ena, mdr_ena, mdr_sel}=8'h38;
            end
            //else if(op==clc||op==stc||op==nop)
            clc, stc, nop:
            begin
                {pc_inc, pc_ena, ir_ena, reg_read1,
                reg_read2, reg_write1, reg_write2, alu_data_sel}=8'h40;
                {alu_ena, hlt, io, flag_set, wr_m, rd_m}=7'b0000000;
                {sp_pop, sp_push, mar_sel, mar_ena, mdr_ena, mdr_sel}=8'h00;
            end
            //else if(op==halt)
            halt:
            begin
                {pc_inc, pc_ena, ir_ena, reg_read1,
                reg_read2, reg_write1, reg_write2, alu_data_sel}=8'h00;
                {alu_ena, hlt, io, flag_set, wr_m, rd_m}=7'b0100000;
                {sp_pop, sp_push, mar_sel, mar_ena, mdr_ena, mdr_sel}=8'h00;
            end
            endcase
            state=4'b0110;
        end
        4'b0110:
        begin
            //if(op==adc||op==sbb||op==mul||op==div||op==addi||op==orr||op==andd||
            //op==xorr||op==test||op==cmp||op==nott||op==shl||op==shr||op==sar||op==mov||
            //op==movil||op==movih||op==clc||op==stc)
            casex(op)
            adc, sbb, mul, div, addi, orr, andd, xorr, test, cmp, nott, shl, shr, sar,
            mov, movil, movih, clc, stc:
            begin
                {pc_inc, pc_ena, ir_ena, reg_read1,
                reg_read2, reg_write1, reg_write2, alu_data_sel}=8'h00;
                {alu_ena, hlt, io, flag_set, wr_m, rd_m}=7'b0000000;
                {sp_pop, sp_push, mar_sel, mar_ena, mdr_ena, mdr_sel}=8'h00;
            end
            //else if(op==jr||op==jrc||op==jrnc||op==jrz||op==jrnz)
            jr, jrc, jrnc, jrz, jrnz:
            begin
                {pc_inc, pc_ena, ir_ena, reg_read1,
                reg_read2, reg_write1, reg_write2, alu_data_sel}=8'h00;
                {alu_ena, hlt, io, flag_set, wr_m, rd_m}=7'b0000000;
                {sp_pop, sp_push, mar_sel, mar_ena, mdr_ena, mdr_sel}=8'h00;
            end
            //else if(op==load)
            load:
            begin
                {pc_inc, pc_ena, ir_ena, reg_read1,
                reg_read2, reg_write1, reg_write2, alu_data_sel}=8'h00;
                {alu_ena, hlt, io, flag_set, wr_m, rd_m}=7'b0000001;
                {sp_pop, sp_push, mar_sel, mar_ena, mdr_ena, mdr_sel}=8'h00;
            end
            //else if(op==pop)
            pop:
            begin
                {pc_inc, pc_ena, ir_ena, reg_read1,
                reg_read2, reg_write1, reg_write2, alu_data_sel}=8'h00;
                {alu_ena, hlt, io, flag_set, wr_m, rd_m}=7'b0000001;
                {sp_pop, sp_push, mar_sel, mar_ena, mdr_ena, mdr_sel}=8'h80;
            end
            //else if(op==store)
            store:
            begin
                {pc_inc, pc_ena, ir_ena, reg_read1,
                reg_read2, reg_write1, reg_write2, alu_data_sel}=8'h00;
                {alu_ena, hlt, io, flag_set, wr_m, rd_m}=7'b0000010;
                {sp_pop, sp_push, mar_sel, mar_ena, mdr_ena, mdr_sel}=8'h00;
            end
            //else if(op==push)
            push:
            begin
                {pc_inc, pc_ena, ir_ena, reg_read1,
                reg_read2, reg_write1, reg_write2, alu_data_sel}=8'h00;
                {alu_ena, hlt, io, flag_set, wr_m, rd_m}=7'b0000000;
                {sp_pop, sp_push, mar_sel, mar_ena, mdr_ena, mdr_sel}=8'h3d;
            end
            //else if(op==nop||op==halt)
            nop, halt:
            begin
                {pc_inc, pc_ena, ir_ena, reg_read1,
                reg_read2, reg_write1, reg_write2, alu_data_sel}=8'h00;
                {alu_ena, hlt, io, flag_set, wr_m, rd_m}=7'b0000000;
                {sp_pop, sp_push, mar_sel, mar_ena, mdr_ena, mdr_sel}=8'h00;
            end
            //else if(op==in)
            in:
            begin
                {pc_inc, pc_ena, ir_ena, reg_read1,
                reg_read2, reg_write1, reg_write2, alu_data_sel}=8'h00;
                {alu_ena, hlt, io, flag_set, wr_m, rd_m}=7'b0010000;//10 means in
                {sp_pop, sp_push, mar_sel, mar_ena, mdr_ena, mdr_sel}=8'h00;
            end
            //else if(op==out)
            out:
            begin
                {pc_inc, pc_ena, ir_ena, reg_read1,
                reg_read2, reg_write1, reg_write2, alu_data_sel}=8'h00;
                {alu_ena, hlt, io, flag_set, wr_m, rd_m}=7'b0011000;//11 means out
                {sp_pop, sp_push, mar_sel, mar_ena, mdr_ena, mdr_sel}=8'h00;
            end
            endcase
            state=4'b0111;
        end
        4'b0111:    //write back to reg array and set eflags
        begin
            //if(op==adc||op==sbb||op==div||op==addi||op==shl||op==shr||op==sar)
            casex(op)
            adc, sbb, div, addi, shl, shr, sar:
            begin
                {pc_inc, pc_ena, ir_ena, reg_read1,
                reg_read2, reg_write1, reg_write2, alu_data_sel}=8'h04;
                {alu_ena, hlt, io, flag_set, wr_m, rd_m}=7'b0000100;
                {sp_pop, sp_push, mar_sel, mar_ena, mdr_ena, mdr_sel}=8'h00;
            end
            //else if(op==mul)
            mul:
            begin
                {pc_inc, pc_ena, ir_ena, reg_read1,
                reg_read2, reg_write1, reg_write2, alu_data_sel}=8'h06;
                {alu_ena, hlt, io, flag_set, wr_m, rd_m}=7'b0000100;
                {sp_pop, sp_push, mar_sel, mar_ena, mdr_ena, mdr_sel}=8'h00;
            end
            //else if(op==andd||op==orr||op==xorr||op==nott||op==mov||op==movil||op==movih)
            andd, orr, xorr, nott, mov, movil, movih:
            begin   //only write register array
                {pc_inc, pc_ena, ir_ena, reg_read1,
                reg_read2, reg_write1, reg_write2, alu_data_sel}=8'h04;
                {alu_ena, hlt, io, flag_set, wr_m, rd_m}=7'b0000000;
                {sp_pop, sp_push, mar_sel, mar_ena, mdr_ena, mdr_sel}=8'h00;
            end
            //else if(op==cmp||op==test||op==clc||op==stc)//only change eflags
            cmp, test, clc, stc:
            begin
                {pc_inc, pc_ena, ir_ena, reg_read1,
                reg_read2, reg_write1, reg_write2, alu_data_sel}=8'h00;
                {alu_ena, hlt, io, flag_set, wr_m, rd_m}=7'b0000100;
                {sp_pop, sp_push, mar_sel, mar_ena, mdr_ena, mdr_sel}=8'h00;
            end
            //else if(op==nop||op==halt||op==jr||op==jrc||op==jrnc||op==jrz||op==jrnz||
            //op==store||op==out)
            nop, halt, jr, jrc, jrnc, jrz, jrnz, store, out:
            begin
                {pc_inc, pc_ena, ir_ena, reg_read1,
                reg_read2, reg_write1, reg_write2, alu_data_sel}=8'h00;
                {alu_ena, hlt, io, flag_set, wr_m, rd_m}=7'b0000000;
                {sp_pop, sp_push, mar_sel, mar_ena, mdr_ena, mdr_sel}=8'h00;
            end
            //else if(op==push)
            push:
            begin
                {pc_inc, pc_ena, ir_ena, reg_read1,
                reg_read2, reg_write1, reg_write2, alu_data_sel}=8'h00;
                {alu_ena, hlt, io, flag_set, wr_m, rd_m}=7'b0000010;
                {sp_pop, sp_push, mar_sel, mar_ena, mdr_ena, mdr_sel}=8'h00;
            end
            //else if(op==in) //mem->mdr
            in:
            begin
                {pc_inc, pc_ena, ir_ena, reg_read1,
                reg_read2, reg_write1, reg_write2, alu_data_sel}=8'h00;
                {alu_ena, hlt, io, flag_set, wr_m, rd_m}=7'b0000000;
                {sp_pop, sp_push, mar_sel, mar_ena, mdr_ena, mdr_sel}=8'h07;
            end
            //else if(op==load||op==pop)  //mem->mdr
            load, pop:
            begin
                {pc_inc, pc_ena, ir_ena, reg_read1,
                reg_read2, reg_write1, reg_write2, alu_data_sel}=8'h00;
                {alu_ena, hlt, io, flag_set, wr_m, rd_m}=7'b0000001; //rd_m=1
                {sp_pop, sp_push, mar_sel, mar_ena, mdr_ena, mdr_sel}=8'h07;
            end
            endcase
            state=4'b1000;
        end
        4'b1000:
        begin
            if(op==load||op==pop||op==in)
            begin
                {pc_inc, pc_ena, ir_ena, reg_read1,
                reg_read2, reg_write1, reg_write2, alu_data_sel}=8'h02;
                {alu_ena, hlt, io, flag_set, wr_m, rd_m}=7'b0000000;
                {sp_pop, sp_push, mar_sel, mar_ena, mdr_ena, mdr_sel}=8'h00;
            end
            else
            begin
                {pc_inc, pc_ena, ir_ena, reg_read1,
                reg_read2, reg_write1, reg_write2, alu_data_sel}=8'h00;
                {alu_ena, hlt, io, flag_set, wr_m, rd_m}=7'b0000000;
                {sp_pop, sp_push, mar_sel, mar_ena, mdr_ena, mdr_sel}=8'h00;
            end
            state=4'b0000;
        end
        default:
        begin
            {pc_inc, pc_ena, ir_ena, reg_read1,
            reg_read2, reg_write1, reg_write2, alu_data_sel}=8'h00;
            {alu_ena, hlt, io, flag_set, wr_m, rd_m}=7'b0000000;
            {sp_pop, sp_push, mar_sel, mar_ena, mdr_ena, mdr_sel}=8'h00;
            state=4'b0000;
        end
        endcase
    end
    endtask
endmodule