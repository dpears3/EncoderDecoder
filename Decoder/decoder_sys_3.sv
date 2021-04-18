`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/09/2020 01:50:26 PM
// Design Name: 
// Module Name: decoder_sys_3
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

module decoder_sys(encoded_bits, choose_constraint_length, final_output, clk);

    // Inputs
    input clk;
    input [1:0] encoded_bits;               // 2 Bits received 
    input [2:0] choose_constraint_length;   // Values 3 - 6, assumed here as 3
    
    output reg final_output; //Final output
    
    // Counting Variables
    integer symbol_num = 0;
    integer state_num = 0;
    integer i = 0;
    integer trace_index;
    integer trace_trellis_index;
    
    // Memory
    // INITIAL STATE MEMORY
    
    // Trellis MEMORY
    reg [4:0] trellis_path_metric [0:14][0:7];  // 2D array 5 bit data, rows = 15, col = 8
    reg [1:0] trellis_branch_metric [0:14][0:7]; // 2D array 2 bit data, rows = 15, col = 8
    
    
    // Trellis optimum Branches
    reg [1:0] branches [0:7]; 
    
    // Branch 1 or 0 was the min? Useful for traceback
    reg best_path [0:14];
    
    // Initial state at 0
    reg [2:0] initial_state = 0;
    
    reg [1:0] states [0:3] = {2'b00, 2'b10, 2'b01, 2'b11};
    
    reg [1:0] given_input_next_output [0:7] = {2'b00, 2'b11, 2'b10, 2'b01, 2'b11, 2'b00, 2'b01, 2'b10};
                               // States:      0 (00)        1 (10)        2 (01)        3 (11)
                               // input/output 0/00,  1/11,  0/10,  1/01,  0/11,  1/00,  0/01,  1/10
    
    // Trellis connecting variable, paired with best_path, Destination: Origin
    reg [2:0] trellis_connection [0:7] = {0,  4,   1,  5,   2,  6,   3,  7};
    //                                 S0:S0,S2 S1:S0,S2 S2:S1,S3 S3:S1,S3
    reg [2:0] min_trellis;    
    
    always @(posedge clk) begin
    
        // Initializing, start from zero
        if (symbol_num == 0) begin
            branches[0] = encoded_bits ^ given_input_next_output[0];
            branches[1] = encoded_bits ^ given_input_next_output[1];
            
            if (branches[0] > 1) begin
                branches[0] <= branches[0] - 1; // Normalize, 11 -> 2 and 10 -> 1...
            end
            if (branches[1] > 1) begin
                branches[1] <= branches[1] - 1; // Normalize, 11 -> 2 and 10 -> 1...
            end 
            
            trellis_branch_metric[0][0] <= branches[0];
            trellis_branch_metric[0][1] <= branches[1];
            
            // Path metric set to branch since this is the initial state
            trellis_path_metric[0][0] <= branches[0];
            trellis_path_metric[0][1] <= branches[1];
            if (branches[0] < branches[1]) begin
                best_path[0] = 0;
            end
            else begin
                best_path[0] = 1;
            end         
        end
        
        if (symbol_num == 1) begin
            branches[0] = encoded_bits ^ given_input_next_output[0];
            branches[1] = encoded_bits ^ given_input_next_output[1];
            branches[2] = encoded_bits ^ given_input_next_output[2];
            branches[3] = encoded_bits ^ given_input_next_output[3];
            
            if (branches[0] > 1) begin
                branches[0] <= branches[0] - 1; // Normalize, 11 -> 2 and 10 -> 1...
                //branches[0] <= {branches[0][1]} + {branches[0][0]};
            end
            if (branches[1] > 1) begin
                branches[1] <= branches[1] - 1; // Normalize, 11 -> 2 and 10 -> 1...
            end 
            if (branches[2] > 1) begin
                branches[2] <= branches[2] - 1; // Normalize, 11 -> 2 and 10 -> 1...
            end
            if (branches[3] > 1) begin
                branches[3] <= branches[3] - 1; // Normalize, 11 -> 2 and 10 -> 1...
            end 
            
            trellis_branch_metric[1][0] <= branches[0];
            trellis_branch_metric[1][1] <= branches[1];
            trellis_branch_metric[1][2] <= branches[2];
            trellis_branch_metric[1][3] <= branches[3];
            
            // Getting the path metrics
            trellis_path_metric[1][0] <= trellis_path_metric[0][0] + branches[0];
            trellis_path_metric[1][1] <= trellis_path_metric[0][0] + branches[1];
            trellis_path_metric[1][2] <= trellis_path_metric[0][1] + branches[2];
            trellis_path_metric[1][3] <= trellis_path_metric[0][1] + branches[3];
            
            // Abstraction from normal trellis
            trellis_path_metric[1][4] <= trellis_path_metric[0][0] + branches[0];
            trellis_path_metric[1][5] <= trellis_path_metric[0][0] + branches[1];
            trellis_path_metric[1][6] <= trellis_path_metric[0][1] + branches[2];
            trellis_path_metric[1][7] <= trellis_path_metric[0][1] + branches[3];
        end

        // Trellis code
        if (symbol_num >= 2) begin
        
            // Calculate the hamming distance for each branch
            for (i = 0; i < 8; i = i + 1) begin
            
                // Calculating
                branches[i] = encoded_bits ^ given_input_next_output[i];
                if (branches[i] > 1) begin
                    branches[i] <= branches[i] - 1; // Normalize, 11 -> 2 and 10 -> 1...
                end
                
                // Storing
                trellis_branch_metric[symbol_num % 15][i] <= branches[i];
            end
            
            // Path metric based on previous plus the current branch
            // i=0,1: Updating Min(Path[0], Path[4]), S0 -> S0 better than S2 -> S0
            if (trellis_path_metric[(symbol_num - 1) % 15][0] < trellis_path_metric[(symbol_num - 1) % 15][4])  begin
                trellis_path_metric[symbol_num % 15][0] = trellis_path_metric[(symbol_num - 1) % 15][0] + branches[0];
                trellis_path_metric[symbol_num % 15][1] = trellis_path_metric[(symbol_num - 1) % 15][0] + branches[1];
                best_path[symbol_num % 15] = 1'b0;
            end
            
            // i=0,1: S2 -> S0 better than S0 -> S0
            else begin
                trellis_path_metric[symbol_num % 15][0] = trellis_path_metric[(symbol_num - 1) % 15][4] + branches[0];
                trellis_path_metric[symbol_num % 15][1] = trellis_path_metric[(symbol_num - 1) % 15][4] + branches[1];
                best_path[symbol_num % 15] = 1'b1;
            end
            
            // i=2,3: S0 -> S1 better than S2 -> S1
            if (trellis_path_metric[(symbol_num - 1) % 15][1] < trellis_path_metric[(symbol_num - 1) % 15][5])  begin
                trellis_path_metric[symbol_num % 15][2] = trellis_path_metric[(symbol_num - 1) % 15][1] + branches[2];
                trellis_path_metric[symbol_num % 15][3] = trellis_path_metric[(symbol_num - 1) % 15][1] + branches[3];
                best_path[symbol_num % 15] = 1'b0;
            end
            
            // i=2,3: S2 -> S1 better than S0 -> S1
            else begin
                trellis_path_metric[symbol_num % 15][2] = trellis_path_metric[(symbol_num - 1) % 15][5] + branches[2];
                trellis_path_metric[symbol_num % 15][3] = trellis_path_metric[(symbol_num - 1) % 15][5] + branches[3];
                best_path[symbol_num % 15] = 1'b1;
            end      

             // i=4,5: S1 -> S2 better than S3 -> S2
            if (trellis_path_metric[(symbol_num - 1) % 15][2] < trellis_path_metric[(symbol_num - 1) % 15][6])  begin
                trellis_path_metric[symbol_num % 15][4] = trellis_path_metric[(symbol_num - 1) % 15][2] + branches[4];
                trellis_path_metric[symbol_num % 15][5] = trellis_path_metric[(symbol_num - 1) % 15][2] + branches[5];
                best_path[symbol_num % 15] = 1'b0;
            end
            
            // i=4,5: S3 -> S2 better than S1 -> S2
            else begin
                trellis_path_metric[symbol_num % 15][4] = trellis_path_metric[(symbol_num - 1) % 15][6] + branches[4];
                trellis_path_metric[symbol_num % 15][5] = trellis_path_metric[(symbol_num - 1) % 15][6] + branches[5];
                best_path[symbol_num % 15] = 1'b1;
            end
            
             // i=6,7: S1 -> S3 better than S3 -> S3
            if (trellis_path_metric[(symbol_num - 1) % 15][3] < trellis_path_metric[(symbol_num - 1) % 15][7])  begin
                trellis_path_metric[symbol_num % 15][6] = trellis_path_metric[(symbol_num - 1) % 15][3] + branches[6];
                trellis_path_metric[symbol_num % 15][7] = trellis_path_metric[(symbol_num - 1) % 15][3] + branches[7];
                best_path[symbol_num % 15] = 1'b0;
            end
            
            // i=6,7: S3 -> S3 better than S1 -> S3
            else begin
                trellis_path_metric[symbol_num % 15][6] = trellis_path_metric[(symbol_num - 1) % 15][7] + branches[6];
                trellis_path_metric[symbol_num % 15][7] = trellis_path_metric[(symbol_num - 1) % 15][7] + branches[7];
                best_path[symbol_num % 15] = 1'b1;
            end                  
       
        end
        
        // Picking an output
        if (symbol_num >= 14) begin
            
            // Traceback, which is the best ending path metric?
            trace_index = (symbol_num) % 15;
            min_trellis <= 0;
            for (int i = 0; i < 8; i++) begin
                if (trellis_path_metric[trace_index][min_trellis] > trellis_path_metric[trace_index][i]) begin
                    min_trellis = i;
                end
            end
            
            // Now need to go from that path backwards
            for (int i = 1; i < 13; i = i + 1) begin
                
                // trellis_connection and best_path tells us the previous state
                trace_index = ((symbol_num % 15) - i) % 15;
                min_trellis <= trellis_connection[(min_trellis / 2) * 2 + best_path[trace_index]];
            end
            
            // Giving output
            final_output <= {states[(min_trellis / 2)][1]};
        end
        
        symbol_num++;
        
    end
    
    
    
endmodule
