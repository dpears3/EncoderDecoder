`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/04/2020 11:34:05 AM
// Design Name: 
// Module Name: sim_encoder_k3
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


module sim_encoder_k3();

    // Inputs
    reg unencoded_bits, clk, rst, choose_constraint_length;
    
    // Outputs
    wire output1, output2;
    
    // Instatiating
    encoder_k3 uut(.unencoded_bits(unencoded_bits), .clk(clk), .rst(rst), .choose_constraint_length(choose_constraint_length), .output1(output1), .output2(output2));
    
    // Clock
    always #1 clk = ~clk;
    
    initial begin
    
        // Loading values into inputs, need to load 0's in register to see output
        clk = 0;
        unencoded_bits = 1'b1;
        #2
        unencoded_bits = 1'b1;
        #2
        unencoded_bits = 1'b1;
        #2
        unencoded_bits = 1'b0;
        #2
        unencoded_bits = 1'b1;
        #2
        unencoded_bits = 1'b0;
        #2
        unencoded_bits = 1'b0;
        #6
        $finish;
        
    end
    
endmodule
