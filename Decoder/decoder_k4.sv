`timescale 1ns / 1ps
// Version has Random Generator and Comments

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/09/2020 01:50:26 PM
// Design Name: 
// Module Name: decoder_sys_4
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

module decoder_k4(encoded_bits, choose_constraint_length, final_output, clk);

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
    reg [4:0] trellis_path_metric [0:19][0:15];  // 2D array 5 bit data, rows = 20, col = 16
    reg [2:0] trellis_branch_metric [0:19][0:15]; // 2D array 2 bit data, rows = 20, col = 16
    
    
    // Trellis optimum Branches
    logic [2:0] branches[0:15] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}; //Just a short version of trellis_branch_metric used for quick calculations at each time t
    //logic is the same thing as reg
    // Branch 1 or 0 was the min? Useful for traceback
    reg best_path [0:19][0:7] = {{0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0},
                                 {0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0},
                                 {0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0},
                                 {0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0}};// a 1 corresponds to S2 or S3 and a 0 corresponds to S0 or S1
    
    // How the states are described
    reg [2:0] states [0:7] = {3'b000, 3'b100, 3'b010, 3'b110, 3'b001, 3'b101, 3'b011, 3'b111};
    
 logic [1:0] given_input_next_output [0:15] = {2'b00, 2'b11, 2'b11, 2'b00, 2'b10, 2'b01, 2'b01, 2'b10, 2'b11, 2'b00, 2'b00, 2'b11, 2'b01, 2'b10, 2'b10, 2'b01};
                // States: 0 (000) 1 (100) 2 (010) 3 (110) 4 (001) 5 (101) 6 (011) 7 (111)
                // input/output 0/00, 1/11, 0/11, 1/00, 0/10, 1/01, 0/01, 1/10, 0/11, 1/00, 0/00, 1/11, 0/01, 1/10, 0/10, 1/01
    
    // Trellis connecting variable, paired with best_path, Destination: Origin
    reg [3:0] trellis_connection [0:15] = {0, 8, 1, 9, 2, 10, 3, 11, 4, 12, 5, 13, 6, 14, 7, 15};
                             //Format -Source:Destiation;
                            //English - S0:S0 Going backwards from S0 to S0
                            // S0:S0,S0:S2 S1:S0,S1:S2 S2:S1,S2:S3 S3:S1,S3:S3
    reg [3:0] min_trellis = 0; //Stores the index of the best_path based on trellis_path_metric 
    
    // Creating the random variable
    Packet pkt = new();// an object to store random variable
    
    always @(posedge clk) begin
    
        // Initializing, start from zero
        if (symbol_num == 0) begin// time t = 0
            branches[0] <= (encoded_bits ^ given_input_next_output[0]);
            branches[1] <= (encoded_bits ^ given_input_next_output[1]);
            branches[0] <= branches[0][1] + branches[0][0];
            branches[1] <= branches[1][1] + branches[1][0];
            trellis_branch_metric[0][0] <= branches[0];
            trellis_branch_metric[0][1] <= branches[1];
            trellis_path_metric[0][0] <= branches[0];
            trellis_path_metric[0][1] <= branches[1];
        end
        
        if (symbol_num == 1) begin// time t = 1
            // Calculating the XOR
            branches[0] <= (encoded_bits ^ given_input_next_output[0]);
            branches[1] <= (encoded_bits ^ given_input_next_output[1]);
            branches[2] <= (encoded_bits ^ given_input_next_output[2]);
            branches[3] <= (encoded_bits ^ given_input_next_output[3]);
            
            // Calculating the number of errors for the 4 branches
            branches[0] <= {branches[0][1] + branches[0][0]};
            branches[1] <= {branches[1][1] + branches[1][0]};
            branches[2] <= {branches[2][1] + branches[2][0]};
            branches[3] <= {branches[3][1] + branches[3][0]};
            
            // Storing branches
            trellis_branch_metric[1][0] <= branches[0];
            trellis_branch_metric[1][1] <= branches[1];
            trellis_branch_metric[1][2] <= branches[2];
            trellis_branch_metric[1][3] <= branches[3];
            trellis_branch_metric[1][4] <= branches[0];
            trellis_branch_metric[1][5] <= branches[1];
            trellis_branch_metric[1][6] <= branches[2];
            trellis_branch_metric[1][7] <= branches[3];
            
            // Calculating and Storing paths
            trellis_path_metric[1][0] <= trellis_path_metric[0][0] + branches[0];
            trellis_path_metric[1][1] <= trellis_path_metric[0][0] + branches[1];
            trellis_path_metric[1][2] <= trellis_path_metric[0][1] + branches[2];
            trellis_path_metric[1][3] <= trellis_path_metric[0][1] + branches[3];
            trellis_path_metric[1][4] <= trellis_path_metric[0][0] + branches[0];
            trellis_path_metric[1][5] <= trellis_path_metric[0][0] + branches[1];
            trellis_path_metric[1][6] <= trellis_path_metric[0][1] + branches[2];
            trellis_path_metric[1][7] <= trellis_path_metric[0][1] + branches[3];
          
        end
     if (symbol_num == 2) begin// time t = 2

        // Calculating the XOR
        branches[0] <= (encoded_bits ^ given_input_next_output[0]);
        branches[1] <= (encoded_bits ^ given_input_next_output[1]);
        branches[2] <= (encoded_bits ^ given_input_next_output[2]);
        branches[3] <= (encoded_bits ^ given_input_next_output[3]);
        branches[4] <= (encoded_bits ^ given_input_next_output[4]);
        branches[5] <= (encoded_bits ^ given_input_next_output[5]);
        branches[6] <= (encoded_bits ^ given_input_next_output[6]);
        branches[7] <= (encoded_bits ^ given_input_next_output[7]);
        
        // Calculating the number of errors for the 8 branches
        branches[0] <= branches[0][1] + branches[0][0];
        branches[1] <= branches[1][1] + branches[1][0];
        branches[2] <= branches[2][1] + branches[2][0];
        branches[3] <= branches[3][1] + branches[3][0];
        branches[4] <= branches[4][1] + branches[4][0];
        branches[5] <= branches[5][1] + branches[5][0];
        branches[6] <= branches[6][1] + branches[6][0];
        branches[7] <= branches[7][1] + branches[7][0];
        
        // Storing branches
        trellis_branch_metric[2][0] <= branches[0];
        trellis_branch_metric[2][1] <= branches[1];
        trellis_branch_metric[2][2] <= branches[2];
        trellis_branch_metric[2][3] <= branches[3];
        trellis_branch_metric[2][4] <= branches[4];
        trellis_branch_metric[2][5] <= branches[5];
        trellis_branch_metric[2][6] <= branches[6];
        trellis_branch_metric[2][7] <= branches[7];
        
        // Calculating and Storing paths
        trellis_path_metric[2][0] <= trellis_path_metric[1][0] + branches[0];
        trellis_path_metric[2][1] <= trellis_path_metric[1][0] + branches[1];
        trellis_path_metric[2][2] <= trellis_path_metric[1][1] + branches[2];
        trellis_path_metric[2][3] <= trellis_path_metric[1][1] + branches[3];
        trellis_path_metric[2][4] <= trellis_path_metric[1][2] + branches[4];
        trellis_path_metric[2][5] <= trellis_path_metric[1][2] + branches[5];
        trellis_path_metric[2][6] <= trellis_path_metric[1][3] + branches[6];
        trellis_path_metric[2][7] <= trellis_path_metric[1][3] + branches[7];
        trellis_path_metric[2][8] <= trellis_path_metric[1][0] + branches[0];
        trellis_path_metric[2][9] <= trellis_path_metric[1][0] + branches[1];
        trellis_path_metric[2][10] <= trellis_path_metric[1][1] + branches[2];
        trellis_path_metric[2][11] <= trellis_path_metric[1][1] + branches[3];
        trellis_path_metric[2][12] <= trellis_path_metric[1][2] + branches[4];
        trellis_path_metric[2][13] <= trellis_path_metric[1][2] + branches[5];
        trellis_path_metric[2][14] <= trellis_path_metric[1][3] + branches[6];
        trellis_path_metric[2][15] <= trellis_path_metric[1][3] + branches[7];

    end
        // Trellis code
        if (symbol_num >= 3) begin// for time t >= 3 
        
       // Calculate the hamming distance for each branch
        for (i = 0; i < 16; i = i + 1) begin
            // Calculating XOR
            branches[i] <= encoded_bits ^ given_input_next_output[i]; //XORing branch like in previous iterations
            
            // Calculating Error
            branches[i] <= (branches[i][1] + branches[i][0]); //XORing branch like in previous iterations
            
            // Storing into branch metric
            trellis_branch_metric[symbol_num % 20][i] <= branches[i];
            end
            
            // The following 8 if statements update Path metric based on previous path plus the current branch
            // i=0,1: Updating Min(Path[0], Path[8]), S0 -> S0 better than S4 -> S0
            if (trellis_path_metric[(symbol_num - 1) % 20][0] < trellis_path_metric[(symbol_num - 1) % 15][8])  begin
                trellis_path_metric[symbol_num % 20][0] = trellis_path_metric[(symbol_num - 1) % 20][0] + branches[0];
                trellis_path_metric[symbol_num % 20][1] = trellis_path_metric[(symbol_num - 1) % 20][0] + branches[1];
            end
            
            // i=0,1: S2 -> S0 better than S0 -> S0
            else begin
                trellis_path_metric[symbol_num % 20][0] = trellis_path_metric[(symbol_num - 1) % 20][8] + branches[0];
                trellis_path_metric[symbol_num % 20][1] = trellis_path_metric[(symbol_num - 1) % 20][8] + branches[1];
            end
            
            // i=2,3: S0 -> S1 better than S2 -> S1
            if (trellis_path_metric[(symbol_num - 1) % 20][1] < trellis_path_metric[(symbol_num - 1) % 20][9])  begin
                trellis_path_metric[symbol_num % 20][2] = trellis_path_metric[(symbol_num - 1) % 20][1] + branches[2];
                trellis_path_metric[symbol_num % 20][3] = trellis_path_metric[(symbol_num - 1) % 20][1] + branches[3];
            end
            
            // i=2,3: S2 -> S1 better than S0 -> S1
            else begin
                trellis_path_metric[symbol_num % 20][2] = trellis_path_metric[(symbol_num - 1) % 20][9] + branches[2];
                trellis_path_metric[symbol_num % 20][3] = trellis_path_metric[(symbol_num - 1) % 20][9] + branches[3];
            end      

             // i=4,5: S1 -> S2 better than S3 -> S2
            if (trellis_path_metric[(symbol_num - 1) % 20][2] < trellis_path_metric[(symbol_num - 1) % 20][10])  begin
                trellis_path_metric[symbol_num % 20][4] = trellis_path_metric[(symbol_num - 1) % 20][2] + branches[4];
                trellis_path_metric[symbol_num % 20][5] = trellis_path_metric[(symbol_num - 1) % 20][2] + branches[5];
            end
            
            // i=4,5: S3 -> S2 better than S1 -> S2
            else begin
                trellis_path_metric[symbol_num % 20][4] = trellis_path_metric[(symbol_num - 1) % 20][10] + branches[4];
                trellis_path_metric[symbol_num % 20][5] = trellis_path_metric[(symbol_num - 1) % 20][10] + branches[5];
            end
            
             // i=6,7: S1 -> S3 better than S3 -> S3
            if (trellis_path_metric[(symbol_num - 1) % 20][3] < trellis_path_metric[(symbol_num - 1) % 20][11])  begin
                trellis_path_metric[symbol_num % 20][6] = trellis_path_metric[(symbol_num - 1) % 20][3] + branches[6];
                trellis_path_metric[symbol_num % 20][7] = trellis_path_metric[(symbol_num - 1) % 20][3] + branches[7];
            end
            
            // i=6,7: S3 -> S3 better than S1 -> S3
            else begin
                trellis_path_metric[symbol_num % 20][6] = trellis_path_metric[(symbol_num - 1) % 20][11] + branches[6];
                trellis_path_metric[symbol_num % 20][7] = trellis_path_metric[(symbol_num - 1) % 20][11] + branches[7];
            end
            
                      // i=6,7: S1 -> S3 better than S3 -> S3
            if (trellis_path_metric[(symbol_num - 1) % 20][4] < trellis_path_metric[(symbol_num - 1) % 20][12])  begin
                trellis_path_metric[symbol_num % 20][8] = trellis_path_metric[(symbol_num - 1) % 20][4] + branches[8];
                trellis_path_metric[symbol_num % 20][9] = trellis_path_metric[(symbol_num - 1) % 20][4] + branches[9];
            end
            
            // i=6,7: S3 -> S3 better than S1 -> S3
            else begin
                trellis_path_metric[symbol_num % 20][8] = trellis_path_metric[(symbol_num - 1) % 20][12] + branches[8];
                trellis_path_metric[symbol_num % 20][9] = trellis_path_metric[(symbol_num - 1) % 20][12] + branches[9];
            end
 
            
                      // i=6,7: S1 -> S3 better than S3 -> S3
            if (trellis_path_metric[(symbol_num - 1) % 20][5] < trellis_path_metric[(symbol_num - 1) % 20][13])  begin
                trellis_path_metric[symbol_num % 20][10] = trellis_path_metric[(symbol_num - 1) % 20][5] + branches[10];
                trellis_path_metric[symbol_num % 20][11] = trellis_path_metric[(symbol_num - 1) % 20][5] + branches[11];
            end
            
            // i=6,7: S3 -> S3 better than S1 -> S3
            else begin
                trellis_path_metric[symbol_num % 20][10] = trellis_path_metric[(symbol_num - 1) % 20][13] + branches[10];
                trellis_path_metric[symbol_num % 20][11] = trellis_path_metric[(symbol_num - 1) % 20][13] + branches[11];
            end
            
                      // i=6,7: S1 -> S3 better than S3 -> S3
            if (trellis_path_metric[(symbol_num - 1) % 20][6] < trellis_path_metric[(symbol_num - 1) % 20][14])  begin
                trellis_path_metric[symbol_num % 20][12] = trellis_path_metric[(symbol_num - 1) % 20][6] + branches[12];
                trellis_path_metric[symbol_num % 20][13] = trellis_path_metric[(symbol_num - 1) % 20][6] + branches[13];
            end
            
            // i=6,7: S3 -> S3 better than S1 -> S3
            else begin
                trellis_path_metric[symbol_num % 20][12] = trellis_path_metric[(symbol_num - 1) % 20][14] + branches[12];
                trellis_path_metric[symbol_num % 20][13] = trellis_path_metric[(symbol_num - 1) % 20][14] + branches[13];
            end
            
                      // i=6,7: S1 -> S3 better than S3 -> S3
            if (trellis_path_metric[(symbol_num - 1) % 20][7] < trellis_path_metric[(symbol_num - 1) % 20][15])  begin
                trellis_path_metric[symbol_num % 20][14] = trellis_path_metric[(symbol_num - 1) % 20][7] + branches[14];
                trellis_path_metric[symbol_num % 20][15] = trellis_path_metric[(symbol_num - 1) % 20][7] + branches[15];
            end
            
            // i=6,7: S3 -> S3 better than S1 -> S3
            else begin
                trellis_path_metric[symbol_num % 20][14] = trellis_path_metric[(symbol_num - 1) % 20][15] + branches[14];
                trellis_path_metric[symbol_num % 20][15] = trellis_path_metric[(symbol_num - 1) % 20][15] + branches[15];
            end                  
       
    // Calculating the best path for this current state,
    //From lines 221 - 267, seeing at each state what is the best previous path and storing it in best_path
            //S0
            if (trellis_path_metric[symbol_num % 20][0] < trellis_path_metric[symbol_num % 20][8]) begin
                best_path[symbol_num % 20][0] = 1'b0;
            end
            else if (trellis_path_metric[symbol_num % 20][0] == trellis_path_metric[symbol_num % 20][8]) begin //for if the previous paths have same value randomly pick where to go back
                pkt.randomize();
                best_path[symbol_num % 20][0] = pkt.random_num;
            end
            else begin
                best_path[symbol_num % 20][0] = 1'b1;
            end
            
            // S1
            if (trellis_path_metric[symbol_num % 20][1] < trellis_path_metric[symbol_num % 20][9]) begin
                best_path[symbol_num % 20][1] = 1'b0;
            end
            else if (trellis_path_metric[symbol_num % 20][1] == trellis_path_metric[symbol_num % 20][9]) begin
                pkt.randomize();
                best_path[symbol_num % 20][1] = pkt.random_num;
            end
            else begin
                best_path[symbol_num % 20][1] = 1'b1;
            end
            
            // S2
            if (trellis_path_metric[symbol_num % 20][2] < trellis_path_metric[symbol_num % 20][10]) begin
                best_path[symbol_num % 20][2] = 1'b0;
            end
            else if (trellis_path_metric[symbol_num % 20][2] == trellis_path_metric[symbol_num % 20][10]) begin
                pkt.randomize();
                best_path[symbol_num % 20][2] = pkt.random_num;
            end
            else begin
                best_path[symbol_num % 20][2] = 1'b1;
            end
            
            // S3
            if (trellis_path_metric[symbol_num % 20][3] < trellis_path_metric[symbol_num % 20][11]) begin
                best_path[symbol_num % 20][3] = 1'b0;
            end
            else if (trellis_path_metric[symbol_num % 20][3] == trellis_path_metric[symbol_num % 20][11]) begin
                pkt.randomize();
                best_path[symbol_num % 20][3] = pkt.random_num;
            end
            else begin
                best_path[symbol_num % 20][3] = 1'b1;
            end
             // S4
            if (trellis_path_metric[symbol_num % 20][4] < trellis_path_metric[symbol_num % 20][12]) begin
                best_path[symbol_num % 20][4] = 1'b0;
            end
            else if (trellis_path_metric[symbol_num % 20][4] == trellis_path_metric[symbol_num % 20][12]) begin
                pkt.randomize();
                best_path[symbol_num % 20][4] = pkt.random_num;
            end
            else begin
                best_path[symbol_num % 20][4] = 1'b1;
            end
            // S5
            if (trellis_path_metric[symbol_num % 20][5] < trellis_path_metric[symbol_num % 20][13]) begin
                best_path[symbol_num % 20][5] = 1'b0;
            end
            else if (trellis_path_metric[symbol_num % 20][5] == trellis_path_metric[symbol_num % 20][13]) begin
                pkt.randomize();
                best_path[symbol_num % 20][5] = pkt.random_num;
            end
            else begin
                best_path[symbol_num % 20][5] = 1'b1;
            end
           // S6
            if (trellis_path_metric[symbol_num % 20][6] < trellis_path_metric[symbol_num % 20][14]) begin
                best_path[symbol_num % 20][6] = 1'b0;
            end
            else if (trellis_path_metric[symbol_num % 20][6] == trellis_path_metric[symbol_num % 20][14]) begin
                pkt.randomize();
                best_path[symbol_num % 20][6] = pkt.random_num;
            end
            else begin
                best_path[symbol_num % 20][6] = 1'b1;
            end
            // S7
            if (trellis_path_metric[symbol_num % 20][7] < trellis_path_metric[symbol_num % 20][15]) begin
                best_path[symbol_num % 20][7] = 1'b0;
            end
            else if (trellis_path_metric[symbol_num % 20][7] == trellis_path_metric[symbol_num % 20][15]) begin
                pkt.randomize();
                best_path[symbol_num % 20][7] = pkt.random_num;
            end
            else begin
                best_path[symbol_num % 20][7] = 1'b1;
            end
       
        end// matches with symbol_num >=3
        
  // Picking an output
        if (symbol_num >= 19) begin
            
            // Traceback, which is the best ending path metric?
            trace_index = (symbol_num) % 20;
            min_trellis = 0;
            //What is the best path at the last time t
            for (int i = 0; i < 16; i++) begin
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
            for (int i = 1; i < 18; i = i + 1) begin
                
                // trellis_connection and best_path tells us the previous state
                trace_index = (symbol_num - i) % 20;
                origin_index = min_trellis / 2;
                // if min_trellis == 14 or 15 the state is 7
                // if min_trellis == 12 or 13 the state is 6
                // if min_trellis == 10 or 11 the state is 5
                // if min_trellis == 8 or 9 the state is 4
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
            final_output = states[(min_trellis / 2)][2];//Stores the leading bit of states[] in final_output
            //It is needed to use two parameters for the 1D array states[] beacause only the leading bit needs to be stored
            
        end//matches with symbol_num >= 19
        
        symbol_num++;
        
    end //matches with always
    
    
    
endmodule
