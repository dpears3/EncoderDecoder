`timescale 1ns / 1ps// 1 unit of time is 1ns and the precision is 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/17/2020 03:48:11 PM
// Design Name: 
// Module Name: part1_tb
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


module part1_tb();
    reg a,b,c;
    wire out;
    part1 test_part1(.a(a), .b(b), .c(c), .out(out));
    initial begin
        a = 0;
        b = 0;
        c = 0;
        
        #5// delay so that you can see input changes
        a = 0;
        b = 1;
        c = 0;
        
        #5
        a = 1;
        b = 0;
        c = 0;
        
        #5
        a = 1;
        b = 1;
        c = 0;
        
        #5
        a = 0;
        b = 0;
        c = 1;
        
        #5
        a = 0;
        b = 1;
        c = 1;
        
        #5
        a = 1;
        b = 0;
        c = 1;
        
        #5
        a = 1;
        b = 1;
        c = 1;
        
       #5 $finish;//exits simulatiion
    end  
endmodule
