`timescale 1ns / 1ps
// Version has Random Generator and Comments

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
// 
// Revision: Added Comments
// Date of Revision: 4/17/2021
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

// Used for randomness
class Packet;
    rand bit random_num;// for if two paths have same path metric a random path will be chosen
endclass

module decoder_k3(encoded_bits, choose_constraint_length, final_output, clk);

    // Inputs
    input clk;
    input [1:0] encoded_bits;               // 2 Bits received 
    input [2:0] choose_constraint_length;   // Values 3 - 6, assumed here as 3
    
    output reg final_output; //Final output
    
    // Counting Variables
    integer symbol_num = 0;// stores what instance of time the trellis diagram is at.
    integer i = 0;// counter variable
    integer unsigned alpha = 0;//Stores the value of best_path
    integer unsigned trace_index; //stores moded index of path metric for when t>15; don't want to have out of bounds error
    integer unsigned origin_index; //Based on min_trellis, origin_index stores the proper state
    
    // Memory
    
    // Trellis MEMORY
    reg [4:0] trellis_path_metric [0:14][0:7];  // 2D array 5 bit data, rows = 15, col = 8
    reg [1:0] trellis_branch_metric [0:14][0:7]; // 2D array 2 bit data, rows = 15, col = 8
    
    
    // Trellis optimum Branches
    logic [1:0] branches[0:7] = {0,0,0,0,0,0,0,0}; //Just a short version of trellis_branch_metric used for quick calculations at each time t
    //logic is the same thing as reg
    // Branch 1 or 0 was the min? Useful for traceback
    reg best_path [0:14][0:3] = {{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},
                                 {0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},
                                 {0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0}};// a 1 corresponds to S2 or S3 and a 0 corresponds to S0 or S1
    
    // How the states are described
    reg [1:0] states [0:3] = {2'b00, 2'b10, 2'b01, 2'b11};
    
    logic [1:0] given_input_next_output [0:7] = {2'b00, 2'b11, 2'b10, 2'b01, 2'b11, 2'b00, 2'b01, 2'b10};
                               // States:      0 (00)        1 (10)        2 (01)        3 (11)
                               // input/output 0/00,  1/11,  0/10,  1/01,  0/11,  1/00,  0/01,  1/10
    
    // Trellis connecting variable, paired with best_path, Destination: Origin
    reg [2:0] trellis_connection [0:7] = {0,  4,   1,  5,   2,  6,   3,  7};
                            //Format -Source:Destiation;
                            //English - S0:S0 Going backwards from S0 to S0
                            // S0:S0,S0:S2 S1:S0,S1:S2 S2:S1,S2:S3 S3:S1,S3:S3
    reg [2:0] min_trellis = 0; //Stores the index of the best_path based on trellis_path_metric 
    
    // Creating the random variable
    Packet pkt = new();// an object to store random variable
    
    always @(posedge clk) begin
    
        // Initializing, start from zero
        if (symbol_num == 0) begin// time t = 0
            //going from XOR value to number of errors
            if ((encoded_bits ^ given_input_next_output[0]) > 1) begin// if encoded_bits == 11 or 10 and given_input_next_output== 00
           //     branches[0] <= (encoded_bits ^ given_input_next_output[0]) - 1;// Not needed
                trellis_branch_metric[0][0] <= (encoded_bits ^ given_input_next_output[0]) - 1;// stores the correct number errors in trellis_branch_metric
                trellis_path_metric[0][0] <= (encoded_bits ^ given_input_next_output[0]) - 1; // have to subtract 1 b/c 11 and 00 should be diff. of 2 and not 3
            end
            else begin// if encoded_bits == 01 or 00 and given_input_next_output== 00
              //  branches[0] <= encoded_bits ^ given_input_next_output[0];//Not Needed
                trellis_branch_metric[0][0] <= (encoded_bits ^ given_input_next_output[0]);// stores the correct number errors in trellis_branch_metric
                trellis_path_metric[0][0] <= (encoded_bits ^ given_input_next_output[0]);// stores the correct number errors in trellis_path_metric
            end
            if ((encoded_bits ^ given_input_next_output[1]) > 1) begin// if encoded_bits == 11 or 10 and given_input_next_output== 11
         //       branches[1] <= (encoded_bits ^ given_input_next_output[1]) - 1;//Not Needed
                trellis_branch_metric[0][1] <= (encoded_bits ^ given_input_next_output[1]) - 1;
                trellis_path_metric[0][1] <= (encoded_bits ^ given_input_next_output[1]) - 1;
            end
            else begin// if encoded_bits == 01 or 00 and given_input_next_output== 11
           //     branches[1] <= encoded_bits ^ given_input_next_output[1];//Not Needed
                trellis_branch_metric[0][1] <= (encoded_bits ^ given_input_next_output[1]);// stores the correct number errors in trellis_branch_metric
                trellis_path_metric[0][1] <= (encoded_bits ^ given_input_next_output[1]);// stores the correct number errors in trellis_path_metric
            end
        end
        
        if (symbol_num == 1) begin// time t = 1
            branches[0] = encoded_bits ^ given_input_next_output[0];
            branches[1] = encoded_bits ^ given_input_next_output[1];
            branches[2] = encoded_bits ^ given_input_next_output[2];
            branches[3] = encoded_bits ^ given_input_next_output[3];
            // have to perform same subtracting step as in symbol_num ==0
            //trellis_path_metric has to be updated twice to make trace back is easier when comparing values
            if (branches[0] > 1) begin
                trellis_branch_metric[1][0] <= branches[0] - 1;
                trellis_path_metric[1][0] <= trellis_path_metric[0][0] + branches[0] - 1;
                trellis_path_metric[1][4] <= trellis_path_metric[0][0] + branches[0] - 1;
            end
            else begin
                trellis_branch_metric[1][0] <= branches[0];
                trellis_path_metric[1][0] <= trellis_path_metric[0][0] + branches[0];
                trellis_path_metric[1][4] <= trellis_path_metric[0][0] + branches[0];
            end
            if (branches[1] > 1) begin
                trellis_branch_metric[1][1] <= branches[1] - 1;
                trellis_path_metric[1][1] <= trellis_path_metric[0][0] + branches[1] - 1;
                trellis_path_metric[1][5] <= trellis_path_metric[0][0] + branches[1] - 1;
         
            end 
            else begin
                trellis_branch_metric[1][1] <= branches[1];
                trellis_path_metric[1][1] <= trellis_path_metric[0][0] + branches[1];
                trellis_path_metric[1][5] <= trellis_path_metric[0][0] + branches[1];                
            end
            if (branches[2] > 1) begin
                trellis_branch_metric[1][2] <= branches[2] - 1;
                trellis_path_metric[1][2] <= trellis_path_metric[0][1] + branches[2] - 1;
                trellis_path_metric[1][6] <= trellis_path_metric[0][1] + branches[2] - 1;
             
            end
            else begin
                trellis_branch_metric[1][2] <= branches[2];
                trellis_path_metric[1][2] <= trellis_path_metric[0][1] + branches[2];
                trellis_path_metric[1][6] <= trellis_path_metric[0][1] + branches[2];                
            end
            if (branches[3] > 1) begin
                trellis_branch_metric[1][3] <= branches[3] - 1;
                trellis_path_metric[1][3] <= trellis_path_metric[0][1] + branches[3] - 1;
                trellis_path_metric[1][7] <= trellis_path_metric[0][1] + branches[3] - 1;
    
            end
            else begin
                trellis_branch_metric[1][3] <= branches[3];
                trellis_path_metric[1][3] <= trellis_path_metric[0][1] + branches[3];
                trellis_path_metric[1][7] <= trellis_path_metric[0][1] + branches[3];                
            end            
        end

        // Trellis code
        if (symbol_num >= 2) begin// for time t >= 2 
        
            // Calculate the hamming distance for each branch
            for (i = 0; i < 8; i = i + 1) begin
            
                // Calculating
                branches[i] = encoded_bits ^ given_input_next_output[i]; //XORing branch like in previous iterations
                if (branches[i] > 1) begin// subtracting 1 like previous iterations
                    branches[i] = branches[i] - 1; // Normalize, 11 -> 2 and 10 -> 1...
                end
                
                // Storing
                trellis_branch_metric[symbol_num % 15][i] = branches[i];
            end
            
            // The following 4 if statements update Path metric based on previous path plus the current branch
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
       
    // Calculating the best path for this current state,
    //From lines 221 - 267, seeing at each state what is the best previous path and storing it in best_path
            //S0
            if (trellis_path_metric[symbol_num % 15][0] < trellis_path_metric[symbol_num % 15][4]) begin
                best_path[symbol_num % 15][0] = 1'b0;
            end
            else if (trellis_path_metric[symbol_num % 15][0] == trellis_path_metric[symbol_num % 15][4]) begin //for if the previous paths have same value randomly pick where to go back
                pkt.randomize();
                best_path[symbol_num % 15][0] = pkt.random_num;
            end
            else begin
                best_path[symbol_num % 15][0] = 1'b1;
            end
            
            // S1
            if (trellis_path_metric[symbol_num % 15][1] < trellis_path_metric[symbol_num % 15][5]) begin
                best_path[symbol_num % 15][1] = 1'b0;
            end
            else if (trellis_path_metric[symbol_num % 15][1] == trellis_path_metric[symbol_num % 15][5]) begin
                pkt.randomize();
                best_path[symbol_num % 15][1] = pkt.random_num;
            end
            else begin
                best_path[symbol_num % 15][1] = 1'b1;
            end
            
            // S2
            if (trellis_path_metric[symbol_num % 15][2] < trellis_path_metric[symbol_num % 15][6]) begin
                best_path[symbol_num % 15][2] = 1'b0;
            end
            else if (trellis_path_metric[symbol_num % 15][2] == trellis_path_metric[symbol_num % 15][6]) begin
                pkt.randomize();
                best_path[symbol_num % 15][2] = pkt.random_num;
            end
            else begin
                best_path[symbol_num % 15][2] = 1'b1;
            end
            
            // S3
            if (trellis_path_metric[symbol_num % 15][3] < trellis_path_metric[symbol_num % 15][7]) begin
                best_path[symbol_num % 15][3] = 1'b0;
            end
            else if (trellis_path_metric[symbol_num % 15][3] == trellis_path_metric[symbol_num % 15][7]) begin
                pkt.randomize();
                best_path[symbol_num % 15][3] = pkt.random_num;
            end
            else begin
                best_path[symbol_num % 15][3] = 1'b1;
            end
       
        end// matches with symbol_num >=2
        
  // Picking an output
        if (symbol_num >= 14) begin
            
            // Traceback, which is the best ending path metric?
            trace_index = (symbol_num) % 15;
            min_trellis = 0;
            //What is the best path at the last time t
            for (int i = 0; i < 8; i++) begin
                if (trellis_path_metric[trace_index][min_trellis] > trellis_path_metric[trace_index][i]) begin
                    min_trellis = i;
                end
                else if (trellis_path_metric[trace_index][min_trellis] == trellis_path_metric[trace_index][i]) begin
                    pkt.randomize();
                    if (pkt.random_num == 1'b0) begin
                        min_trellis = i;
                    end
                end
            end
            

            // Now need to go from that path backwards
            for (int i = 1; i < 14; i = i + 1) begin
                
                // trellis_connection and best_path tells us the previous state
                trace_index = (symbol_num - i) % 15;
                origin_index = min_trellis / 2;
                // if min_trellis == 6 or 7 the state is 3
                // if min_trellis == 4 or 5 the state is 2
                // if min_trellis == 2 or 3 the state is 1
                // if min_trellis == 0 or 1 the state is 0
                alpha = best_path[trace_index][origin_index];//alpha is 1 or 0
                min_trellis = trellis_connection[(origin_index) * 2 + alpha];//Stores the index of the best path
                //For instance if we are at S0 and alpha == 1 then the best previous path was S2;
                //If we are at S0 and alpha == 0 then the best previous path was S0;
            end
            
            // Giving output
            final_output = states[(min_trellis / 2)][1];//Stores the leading bit of states[] in final_output
            //It is needed to use two parameters for the 1D array states[] beacause only the leading bit needs to be stored
            
        end//matches with symbol_num >= 14
        
        symbol_num++;
        
    end //matches with always
    
    
    
endmodule
