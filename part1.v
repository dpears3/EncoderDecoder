`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/17/2020 02:31:55 PM
// Design Name: 
// Module Name: part1
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: THis project will simmulate outputs based on
//three inputs (a, b, c).
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module part1(
    input a,
    input b,
    input c,
    output reg out
    );
    always @(a or b or c) begin//couldn't recognize | for some reason
        //case statement used to show truth table outcomes
        case({a,b,c})
            3'b000: begin
                 out <= 1'b1;
            end
            3'b001: begin
                out <= 1'b1;
            end
            3'b100: begin
                out <= 1'b0;
            end
            3'b101: begin
                out <= 1'b0;
            end
            3'b110: begin
                out <= 1'b1;
            end
            3'b111: begin
                out <= 1'b0;    
            end
            default begin//don't cares
                out <= 1'bx;
            end
            
        endcase
     end
    
endmodule
