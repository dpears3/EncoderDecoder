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


module encoder_k3(unencoded_bits, clk, rst, choose_constraint_length, output1, output2);

    input unencoded_bits, clk, rst, choose_constraint_length;
    output reg output1, output2;
    
    reg [1:0] shift_reg; //register
    
    always @(posedge clk) begin
        output1 <= (unencoded_bits^shift_reg[1])^shift_reg[0];
        output2 <= unencoded_bits^shift_reg[0];
        shift_reg = shift_reg>>1;
        shift_reg[1] = unencoded_bits;
    end

endmodule
