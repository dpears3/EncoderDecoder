`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/13/2020 10:58:36 AM
// Design Name: 
// Module Name: encoder
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


module encoder(unencoded_bits, clk, choose_constraint_length, out);

    // connection polynomial defined as top and then bottom output 
    // 111 101 = (7,5)

    input unencoded_bits, clk;
    input [2:0] choose_constraint_length;
    output reg [1:0] out;
    
    reg [1:0] shift_reg = 0; //register
    
    always @(posedge clk) begin
        out[1] <= (unencoded_bits^shift_reg[1])^shift_reg[0];
        out[0] <= unencoded_bits^shift_reg[0];
        shift_reg = shift_reg>>1;
        shift_reg[1] = unencoded_bits;
    end

endmodule
