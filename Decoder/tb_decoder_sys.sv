`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/14/2020 07:25:01 PM
// Design Name: 
// Module Name: sim_decoder_sys
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


module sim_decoder_sys();

    // Inputs
    reg clk;
    reg [2:0] choose_constraint_length;
    reg [1:0] encoded_bits;
    
    // Outputs
    wire final_output;
    
    // Instatiating
    decoder_sys uut(.encoded_bits(encoded_bits), .choose_constraint_length(choose_constraint_length), .final_output(final_output), .clk(clk));

    // Clock
    always #1 clk = ~clk;


    
    initial begin
        clk = 0;
        encoded_bits = 2'b11;
        choose_constraint_length = 3'b011;
        #2;
        encoded_bits = 2'b11;
        #2;
        encoded_bits = 2'b10;
        #2;
        encoded_bits = 2'b01;
        #2;
        encoded_bits = 2'b10;
        #2;
        encoded_bits = 2'b10;
        #2;
        encoded_bits = 2'b11;
        #2;
        encoded_bits = 2'b11;
        #2;
        encoded_bits = 2'b11;
        #2;
        encoded_bits = 2'b10;
        #2;
        encoded_bits = 2'b01;
        #2;
        encoded_bits = 2'b10;
        #2;
        encoded_bits = 2'b10;
        #2;
        encoded_bits = 2'b11;
        #2;
        encoded_bits = 2'b00;

        // Need to wait 15 cycles after
        #30
        $finish;
    end
    

endmodule
