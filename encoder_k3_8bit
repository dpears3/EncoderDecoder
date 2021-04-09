`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Junkyu Kwon
// 04/09/2021
// Made the encoder_k3 to accept 8 bits
//////////////////////////////////////////////////////////////////////////////////


module encoder_k3(unencoded_bits, clk, rst, choose_constraint_length, out, out_reg);

    input [7:0] unencoded_bits;
    input clk, rst;
    input [2:0] choose_constraint_length;
    output reg [1:0] out;
    output reg [1:0] out_reg;
    int i = 0;
    reg [1:0] shift_reg = 0; //register
    
    always @(posedge clk) begin
        
        if (i < 8) begin
            out[1] <= (unencoded_bits[i]^shift_reg[1])^shift_reg[0];
            out[0] <= unencoded_bits[i]^shift_reg[0];
            shift_reg = shift_reg>>1;
            shift_reg[1] = unencoded_bits[i];
            out_reg <= shift_reg;
            i++;
        end else begin
            
            i = 0;
            out[1] <= (unencoded_bits[i]^shift_reg[1])^shift_reg[0];
            out[0] <= unencoded_bits[i]^shift_reg[0];
            shift_reg = shift_reg>>1;
            shift_reg[1] = unencoded_bits[i];
            out_reg <= shift_reg;
            i++;
        end
    end

endmodule
