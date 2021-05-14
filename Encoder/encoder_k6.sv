`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/04/2020 11:19:07 AM
// Design Name: 
// Module Name: encoder_k3
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


module encoder_k6(unencoded_bit, clk, rst, choose_constraint_length, out);

    input unencoded_bit, clk, rst;
    input [2:0] choose_constraint_length;
    output reg [1:0] out;
    
    reg [4:0] shift_reg = 0; //register
    
    always @(posedge clk) begin
        out[1] <= ((unencoded_bit^shift_reg[4])^shift_reg[2])^shift_reg[0];
        out[0] <= (((unencoded_bit^shift_reg[3])^shift_reg[2])^shift_reg[1])^shift_reg[0];
        shift_reg = shift_reg>>1;
        shift_reg[4] = unencoded_bit;
    end

endmodule
