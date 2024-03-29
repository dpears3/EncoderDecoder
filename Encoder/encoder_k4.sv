`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/04/2020 11:19:07 AM
// Design Name: 
// Module Name: encoder_k4
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


module encoder_k4(unencoded_bits, clk, rst, choose_constraint_length, out);

    input unencoded_bits, clk, rst;
    input [2:0] choose_constraint_length;
    output reg [1:0] out;
    
    reg [2:0] shift_reg = 0; //register
    
    always @(posedge clk) begin
        out[1] <= ((unencoded_bits^shift_reg[0])^shift_reg[1])^shift_reg[2];
        out[0] <= (unencoded_bits^shift_reg[0])^shift_reg[2];
        shift_reg = shift_reg>>1;
        shift_reg[2] = unencoded_bits;
    end

endmodule
