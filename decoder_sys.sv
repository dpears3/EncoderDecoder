`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/09/2020 01:50:26 PM
// Design Name: 
// Module Name: decoder_sys
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

module decoder_sys(encoded_bits, choose_constraint_length, clk);

    // Inputs
    input clk;
    input [1:0] encoded_bits;               // 2 Bits received 
    input [2:0] choose_constraint_length;   // Values 3 - 6, assumed here as 3
    
    // Counting Variables
    integer symbol_num = 0;
    integer state_num = 0;
    integer i = 0;
    
    // Memory
    // INITIAL STATE MEMORY
    
    // Trellis MEMORY
    reg [4:0] trellis_path_metric [0:3][0:14];  // 2D array 5 bit data, rows = 4, col = 15
    reg [1:0] trellis_branch_metric [0:3][0:14]; // 2D array 2 bit data, rows = 4, col = 15
    
    // Trellis optimum Branches
    reg [1:0] branches [0:7]; 
    
    
    reg [1:0] given_input_next_output [0:7] = {2'b00, 2'b11, 2'b10, 2'b01, 2'b11, 2'b00, 2'b01, 2'b10};
                               // States:      0 (00)        1 (10)        2 (01)        3 (11)
                               // input/output 0/00,  1/11,  0/10,  1/01,  0/11,  1/00, 0/01,   1/10
    
    always @(posedge clk) begin
    
        // Initializing
        if (symbol_num <= 2) begin
        
        end
    
        // Trellis code
        if (symbol_num > 2) begin
        
            // Calculate the hamming distance for each branch
            for (i = 0; i < 8; i = i + 1) begin
                branches[i] = encoded_bits ^ given_input_next_output[i];
                if (branches[i] > 1) begin
                    branches[i] = branches[i] - 1; // Normalize, 11 -> 2 and 10 -> 1...
                end
            end
            
            for (state_num = 0; state_num < 4; state_num = state_num + 1) begin
            
                // Find optimum branches and store
                
                trellis_branch_metric[state_num][symbol_num] = branches[state_num];
            
            end
        
        end
    
        // Picking an output
        if (symbol_num > 15) begin
        
        end
        
    end
    
    
    
endmodule
