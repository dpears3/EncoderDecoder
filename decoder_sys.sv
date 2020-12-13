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
// aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa










fasdfsadasda

sadasdasdas
dsdfasfsa










adfsadasdasdadadsds
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
    
    output [16:0] final_output //Final output
    
    // Counting Variables
    integer symbol_num = 0;
    integer state_num = 0;
    integer i = 0;
    
    // Memory
    // INITIAL STATE MEMORY
    
    // Trellis MEMORY
    reg [4:0] trellis_path_metric [0:7][0:14];  // 2D array 5 bit data, rows = 8, col = 15
    reg [1:0] trellis_branch_metric [0:7][0:14]; // 2D array 2 bit data, rows = 8, col = 15

    //Branch Metrics
    reg [4:0] s0_branch_0 [0:14];
    reg [4:0] s0_branch_1 [0:14];
    reg [4:0] s1_branch_0 [0:14];
    reg [4:0] s1_branch_1 [0:14];
    reg [4:0] s2_branch_0 [0:14];
    reg [4:0] s2_branch_1 [0:14];
    reg [4:0] s3_branch_0 [0:14];
    reg [4:0] s3_branch_1 [0:14];

    //Path Metrics
    reg [4:0] s0_path_0 [0:14];
    reg [4:0] s0_path_1 [0:14];
    reg [4:0] s1_path_0 [0:14];
    reg [4:0] s1_path_1 [0:14];
    reg [4:0] s2_path_0 [0:14];
    reg [4:0] s2_path_1 [0:14];
    reg [4:0] s3_path_0 [0:14];
    reg [4:0] s3_path_1 [0:14];
    
    // Trellis optimum Branches
    reg [1:0] branches [0:7]; 
    
    
    reg [1:0] given_input_next_output [0:7] = {2'b00, 2'b11, 2'b11, 2'b00, 2'b10, 2'b01, 2'b01, 2'b10};
                               // States:      0 (00)        1 (01)        2 (10)        3 (11)
                               // input/output 0/00,  1/11,  0/10,  1/01,  0/11,  1/00, 0/01,   1/10
    
    always @(posedge clk) begin
    //s0 = 00 , s1 = 10, s2 =01, s3 11
        // Initializing
        //if (symbol_num < 2) begin
            if(symbol_num == 0) begin
                integer s1_count = 0, s0_count = 0;
                if (encoded_bits[1] == 1) begin
                    s0_count = s0_count +1;
                end
                else begin//encoded_bits[1] == 0
                    s1_count = s1_count +1;
                end
                if (encoded_bits[0] == 1) begin
                    s0_count = s0_count +1;
                end
                else begin//encoded_bits[0] == 0
                    s1_count = s1_count +1;
                end
                
                s1_branch_1[0] = s1_count;
                s0_branch_0[0] = s0_count;
            end
            if(symbol_num == 1) begin
                integer s1_count = 0, s0_count = 0, s2_count = 0, s3_count = 0;
                if (encoded_bits[1] == 1) begin
                    s0_count = s0_count +1;
                    s3_count = s3_count +1;
                end
                else begin//encoded_bits[1] == 0
                    s1_count = s1_count +1;
                    s2_count = s2_count +1;
                end
                if (encoded_bits[0] == 1) begin
                    s0_count = s0_count +1;
                     s2_count = s2_count +1;
                    
                end
                else begin//encoded_bits[0] == 0
                    s1_count = s1_count +1;
                    s3_count = s3_count +1;
                end
                s0_branch_0[1] = s0_count;
                s1_branch_1[1] = s1_count;
                s2_branch_0[1] = s2_count;
                s3_branch_1[1] = s3_count;
            end
        //end
    
        // Trellis code
        if (symbol_num >=2 and symbol_num <15) begin
        
            // Calculate the hamming distance for each branch
            for (i = 0; i < 8; i = i + 1) begin
            
                // Calculating
                branches[i] = encoded_bits ^ given_input_next_output[i];
                if (branches[i] > 1) begin
                    branches[i] <= branches[i] - 1; // Normalize, 11 -> 2 and 10 -> 1...
                end
                
                // Storing
                trellis_branch_metric[symbol_num % 15][i] <= branches[i];
                // Path metric based on previous plus the current branch
            end
            
            // Path metric based on previous plus the current branch
            // Updating Min(Path[0], Path[4])
            if (trellis_path_metric[(symbol_num - 1) % 15][0] < trellis_path_metric[(symbol_num - 1) % 15][4])  begin
                trellis_path_metric[symbol_num % 15][0] = trellis_path_metric[(symbol_num - 1) % 15][0] + branches[0];
                trellis_path_metric[symbol_num % 15][1] = trellis_path_metric[(symbol_num - 1) % 15][0] + branches[1];
            end
            else begin
                trellis_path_metric[symbol_num % 15][0] = trellis_path_metric[(symbol_num - 1) % 15][4] + branches[0];
                trellis_path_metric[symbol_num % 15][1] = trellis_path_metric[(symbol_num - 1) % 15][4] + branches[1];
            end
            // Min(Path[0], Path[4]
            //Branch metric
            if (trellis_branch_metric[(symbol_num - 1) % 15][0] < trellis_branch_metric[(symbol_num - 1) % 15][4])  begin
                trellis_branch_metric[symbol_num % 15][0] = trellis_branch_metric[(symbol_num - 1) % 15][0] + branches[0];
                trellis_branch_metric[symbol_num % 15][1] = trellis_branch_metric[(symbol_num - 1) % 15][0] + branches[1];
            end
            else begin
                trellis_branch_metric[symbol_num % 15][0] = trellis_branch_metric[(symbol_num - 1) % 15][4] + branches[0];
                trellis_path_metric[symbol_num % 15][1] = trellis_path_metric[(symbol_num - 1) % 15][4] + branches[1];	                
                trellis_branch_metric[symbol_num % 15][1] = trellis_branch_metric[(symbol_num - 1) % 15][4] + branches[1];
                
            end
  /*          
            for (state_num = 0; state_num < 4; state_num = state_num + 1) begin
            
                // Find optimum branches and store
                
                trellis_branch_metric[state_num][symbol_num] = branches[state_num];
            end
  */        
  
        // can you see this
        // here is an edit
        end
    
        // Picking an output
        if (symbol_num >=15) begin
            //shift over
            //insert new data
            //ouput the decoded bit
            for (i = 0; i < 8; i++) begin
                // Find optimum branches and store
                trellis_branch_metrics[]
            end
            //end_index = symbol_num % 15;
            
        end
        symbol_num++;
        
    end
    
    
    
endmodule

