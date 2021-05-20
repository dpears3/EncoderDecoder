// OLD WORKING COPY


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

// Used for randomness
//class Packet;
//    rand bit random_num;
//endclass

module decoder_k3(buffer_in, choose_constraint_length, final_output, clk, start, ready, buffer_out, reset);

    // Inputs
    input clk, start, reset;
    //input [1:0] encoded_bits;               // 2 Bits received 
    input [0:63] buffer_in;
    input [2:0] choose_constraint_length;   // Values 3 - 6, assumed here as 3
    
    output reg final_output; //Final output
    output reg ready = 0;
    output reg [0:31] buffer_out;
    
    reg [1:0] encoded_bits; // parced out
    
    // Counting Variables
    integer symbol_num = 0;
    integer state_num = 0;
    integer i = 0;
    integer unsigned alpha = 0;
    integer unsigned trace_index;
    integer unsigned origin_index;
    
    // Memory
    
    // Trellis MEMORY
    logic [7:0] trellis_path_metric [0:14][0:7];  // 2D array 5 bit data, rows = 15, col = 8
    logic [1:0] trellis_branch_metric [0:14][0:7]; // 2D array 2 bit data, rows = 15, col = 8
    //logic [4:0][0:7] trellis_path_metric [0:14];  // 2D array 5 bit data, rows = 15, col = 8
    //logic [1:0][0:7] trellis_branch_metric [0:14]; // 2D array 2 bit data, rows = 15, col = 8
        
    // Trellis optimum Branches
    logic [1:0] branches[0:7] = {0,0,0,0,0,0,0,0}; 
    
    // Branch 1 or 0 was the min? Useful for traceback
    reg best_path [0:14][0:3];// a 1 corresponds to S2 or S3 and a 0 corresponds to S0 or S1
    
    // How the states are described
    reg [1:0] states [0:3] = {2'b00, 2'b10, 2'b01, 2'b11};
    
    logic [1:0] given_input_next_output [0:7] = {2'b00, 2'b11, 2'b10, 2'b01, 2'b11, 2'b00, 2'b01, 2'b10};
                               // States:      0 (00)        1 (10)        2 (01)        3 (11)
                               // input/output 0/00,  1/11,  0/10,  1/01,  0/11,  1/00,  0/01,  1/10
    
    // Trellis connecting variable, paired with best_path, Destination: Origin
    reg [2:0] trellis_connection [0:7] = {0,  4,   1,  5,   2,  6,   3,  7};
    //                                 S0:S0,S0:S2 S1:S0,S1:S2 S2:S1,S2:S3 S3:S1,S3:S3
    reg [2:0] min_trellis = 0;    
    
    // Creating the random variable
    //Packet pkt = new();
    
    reg [1:0] cycle_count = 0;
    reg cycle_finished = 0;
    
    always @(posedge clk) begin
    
        if (reset) begin
            symbol_num <= 0;
            cycle_finished <= 0;
            cycle_count <= 0;
            ready <= 0;
        end
    
        if (start) begin
    
        // Initializing, start from zero
        if (symbol_num == 0) begin
        
            trellis_path_metric[0][0] <= (encoded_bits ^ given_input_next_output[0]);
            trellis_path_metric[0][1] <= (encoded_bits ^ given_input_next_output[1]);
            
        end
        
        if (symbol_num == 1) begin
        
            best_path[1][0] = 1'b0;
            best_path[1][1] = 1'b0;
            best_path[1][2] = 1'b0;
            best_path[1][3] = 1'b0;
        
            trellis_path_metric[1][0] = trellis_path_metric[0][0] + (encoded_bits ^ given_input_next_output[0]);
            trellis_path_metric[1][4] = trellis_path_metric[0][0] + (encoded_bits ^ given_input_next_output[0]);
            trellis_path_metric[1][1] = trellis_path_metric[0][0] + (encoded_bits ^ given_input_next_output[1]);
            trellis_path_metric[1][5] = trellis_path_metric[0][0] + (encoded_bits ^ given_input_next_output[1]);            
            trellis_path_metric[1][2] = trellis_path_metric[0][1] + (encoded_bits ^ given_input_next_output[2]);
            trellis_path_metric[1][6] = trellis_path_metric[0][1] + (encoded_bits ^ given_input_next_output[2]);            
            trellis_path_metric[1][3] = trellis_path_metric[0][1] + (encoded_bits ^ given_input_next_output[3]);
            trellis_path_metric[1][7] = trellis_path_metric[0][1] + (encoded_bits ^ given_input_next_output[3]);

        end

        // Trellis code
        if (symbol_num >= 2) begin

            // Calculating branches
            branches[0] = encoded_bits ^ given_input_next_output[0];
            branches[1] = encoded_bits ^ given_input_next_output[1];
            branches[2] = encoded_bits ^ given_input_next_output[2];
            branches[3] = encoded_bits ^ given_input_next_output[3];
            branches[4] = encoded_bits ^ given_input_next_output[4];
            branches[5] = encoded_bits ^ given_input_next_output[5];
            branches[6] = encoded_bits ^ given_input_next_output[6];
            branches[7] = encoded_bits ^ given_input_next_output[7];
            
            
            // Path metric based on previous plus the current branch
            // i=0,1: Updating Min(Path[0], Path[4]), S0 -> S0 better than S2 -> S0
            if (trellis_path_metric[(symbol_num - 1) % 15][0] < trellis_path_metric[(symbol_num - 1) % 15][4])  begin
                trellis_path_metric[symbol_num % 15][0] = trellis_path_metric[(symbol_num - 1) % 15][0] + branches[0];
                trellis_path_metric[symbol_num % 15][1] = trellis_path_metric[(symbol_num - 1) % 15][0] + branches[1];
            end
            
            // i=0,1: S2 -> S0 better than S0 -> S0
            else begin
                trellis_path_metric[symbol_num % 15][0] = trellis_path_metric[(symbol_num - 1) % 15][4] + branches[0];
                trellis_path_metric[symbol_num % 15][1] = trellis_path_metric[(symbol_num - 1) % 15][4] + branches[1];
            end
            
            // i=2,3: S0 -> S1 better than S2 -> S1
            if (trellis_path_metric[(symbol_num - 1) % 15][1] < trellis_path_metric[(symbol_num - 1) % 15][5])  begin
                trellis_path_metric[symbol_num % 15][2] = trellis_path_metric[(symbol_num - 1) % 15][1] + branches[2];
                trellis_path_metric[symbol_num % 15][3] = trellis_path_metric[(symbol_num - 1) % 15][1] + branches[3];
            end
            
            // i=2,3: S2 -> S1 better than S0 -> S1
            else begin
                trellis_path_metric[symbol_num % 15][2] = trellis_path_metric[(symbol_num - 1) % 15][5] + branches[2];
                trellis_path_metric[symbol_num % 15][3] = trellis_path_metric[(symbol_num - 1) % 15][5] + branches[3];
            end      

             // i=4,5: S1 -> S2 better than S3 -> S2
            if (trellis_path_metric[(symbol_num - 1) % 15][2] < trellis_path_metric[(symbol_num - 1) % 15][6])  begin
                trellis_path_metric[symbol_num % 15][4] = trellis_path_metric[(symbol_num - 1) % 15][2] + branches[4];
                trellis_path_metric[symbol_num % 15][5] = trellis_path_metric[(symbol_num - 1) % 15][2] + branches[5];
            end
            
            // i=4,5: S3 -> S2 better than S1 -> S2
            else begin
                trellis_path_metric[symbol_num % 15][4] = trellis_path_metric[(symbol_num - 1) % 15][6] + branches[4];
                trellis_path_metric[symbol_num % 15][5] = trellis_path_metric[(symbol_num - 1) % 15][6] + branches[5];
            end
            
             // i=6,7: S1 -> S3 better than S3 -> S3
            if (trellis_path_metric[(symbol_num - 1) % 15][3] < trellis_path_metric[(symbol_num - 1) % 15][7])  begin
                trellis_path_metric[symbol_num % 15][6] = trellis_path_metric[(symbol_num - 1) % 15][3] + branches[6];
                trellis_path_metric[symbol_num % 15][7] = trellis_path_metric[(symbol_num - 1) % 15][3] + branches[7];
            end
            
            // i=6,7: S3 -> S3 better than S1 -> S3
            else begin
                trellis_path_metric[symbol_num % 15][6] = trellis_path_metric[(symbol_num - 1) % 15][7] + branches[6];
                trellis_path_metric[symbol_num % 15][7] = trellis_path_metric[(symbol_num - 1) % 15][7] + branches[7];
            end                  
       
            // Calculating the best path for this current state, S0
            if (trellis_path_metric[symbol_num % 15][0] < trellis_path_metric[symbol_num % 15][4]) begin
                best_path[symbol_num % 15][0] = 1'b0;
            end
            else if (trellis_path_metric[symbol_num % 15][0] == trellis_path_metric[symbol_num % 15][4]) begin
                //pkt.randomize();
                //best_path[symbol_num % 15][0] = pkt.random_num;
                best_path[symbol_num % 15][0] = 1'b1;                
            end
            else begin
                best_path[symbol_num % 15][0] = 1'b1;
            end
            
            // S1
            if (trellis_path_metric[symbol_num % 15][1] < trellis_path_metric[symbol_num % 15][5]) begin
                best_path[symbol_num % 15][1] = 1'b0;
            end
            else if (trellis_path_metric[symbol_num % 15][1] == trellis_path_metric[symbol_num % 15][5]) begin
//                pkt.randomize();
//                best_path[symbol_num % 15][1] = pkt.random_num;
                best_path[symbol_num % 15][1] = 1'b1;
            end
            else begin
                best_path[symbol_num % 15][1] = 1'b1;
            end
            
            // S2
            if (trellis_path_metric[symbol_num % 15][2] < trellis_path_metric[symbol_num % 15][6]) begin
                best_path[symbol_num % 15][2] = 1'b0;
            end
            else if (trellis_path_metric[symbol_num % 15][2] == trellis_path_metric[symbol_num % 15][6]) begin
//                pkt.randomize();
//                best_path[symbol_num % 15][2] = pkt.random_num;
                best_path[symbol_num % 15][2] = 1'b1;
            end
            else begin
                best_path[symbol_num % 15][2] = 1'b1;
            end
            
            // S3
            if (trellis_path_metric[symbol_num % 15][3] < trellis_path_metric[symbol_num % 15][7]) begin
                best_path[symbol_num % 15][3] = 1'b0;
            end
            else if (trellis_path_metric[symbol_num % 15][3] == trellis_path_metric[symbol_num % 15][7]) begin
//                pkt.randomize();
//                best_path[symbol_num % 15][3] = pkt.random_num;
                best_path[symbol_num % 15][3] = 1'b1;
            end
            else begin
                best_path[symbol_num % 15][3] = 1'b1;
            end
       
        end
        
        // Picking an output
        if (symbol_num >= 14) begin
            
            
            if (cycle_count == 2'b11) begin
            
            // Traceback, which is the best ending path metric?
            trace_index = (symbol_num) % 15;
            min_trellis = 0;
            
            
            for (int i = 0; i < 8; i++) begin
                if (trellis_path_metric[trace_index][min_trellis] > trellis_path_metric[trace_index][i]) begin
                    min_trellis = i;
                end
                else if (trellis_path_metric[trace_index][min_trellis] == trellis_path_metric[trace_index][i]) begin
//                    pkt.randomize();
//                    if (pkt.random_num == 1'b0) begin
//                        min_trellis = i;
//                    end

                    min_trellis = i;

                end
            end
            

            // Now need to go from that path backwards
            for (int i = 1; i < 14; i = i + 1) begin
                
                // trellis_connection and best_path tells us the previous state
                trace_index = (symbol_num - i) % 15;
                origin_index = min_trellis / 2;
                alpha = best_path[trace_index][origin_index];
                min_trellis = trellis_connection[(origin_index) * 2 + alpha];
            end
            
            // Giving output
            final_output = states[(min_trellis / 2)][1];
            
            buffer_out[symbol_num - 14] = states[(min_trellis / 2)][1];
            
            
            end
        end
        
        cycle_count++;
        
        if (cycle_count == 0 && symbol_num < 47 && cycle_finished == 1'b1) begin
            symbol_num++;
        end
        
        if (symbol_num >= 46) begin
            ready = 1'b1;
        end
        
        if (symbol_num < 32) begin
            encoded_bits[1] <= buffer_in[2*symbol_num];
            encoded_bits[0] <= buffer_in[2*symbol_num + 1];
        end
        
        cycle_finished = 1'b1;
        
        end

    end
    
    
    
endmodule
