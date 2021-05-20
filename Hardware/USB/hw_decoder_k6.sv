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

module hw_decoder_k6(buffer_in, choose_constraint_length, final_output, clk, start, symbol_num, ready, buffer_out);

    // Inputs
    input clk, start;
    //input [1:0] encoded_bits;               // 2 Bits received 
    input [0:63] buffer_in;
    input [2:0] choose_constraint_length;   // Values 3 - 6, assumed here as 3
    
    output reg final_output; //Final output
    output reg ready = 0;
    output reg [0:31] buffer_out;
    
    reg [1:0] encoded_bits; // parced out
    
    // Counting Variables
    output integer symbol_num = 0;
    integer state_num = 0;
    integer i = 0;
    integer unsigned alpha = 0;
    integer unsigned trace_index;
    integer unsigned origin_index;
    
    // Memory
    
    // Trellis MEMORY
    reg [7:0] trellis_path_metric [0:29][0:63];  // 2D array 5 bit data, rows = 30, col = 64
    //reg [2:0] trellis_branch_metric [0:29][0:63]; // 2D array 2 bit data, rows = 30, col = 64
        
    // Trellis optimum Branches
    logic [1:0] branches[0:63];
    
    // Branch 1 or 0 was the min? Useful for traceback
    reg best_path [0:29][0:31];// a 1 corresponds to S2 or S3 and a 0 corresponds to S0 or S1
    
    // How the states are described
    reg [4:0] states [0:31] = {5'b00000, 5'b10000, 5'b01000, 5'b11000, 5'b00100, 5'b10100,
                               5'b01100, 5'b11100, 5'b00010, 5'b10010, 5'b01010, 5'b11010,
                               5'b00110, 5'b10110, 5'b01110, 5'b11110, 5'b00001, 5'b10001,
                               5'b01001, 5'b11001, 5'b00101, 5'b10101, 5'b01101, 5'b11101,
                               5'b00011, 5'b10011, 5'b01011, 5'b11011, 5'b00111, 5'b10111,
                               5'b01111, 5'b11111};
    
    logic [1:0] given_input_next_output [0:63] = {2'b00, 2'b11, 2'b10, 2'b01, 2'b01, 2'b10, 2'b11, 2'b00, 
                                                  2'b11, 2'b00, 2'b01, 2'b10, 2'b10, 2'b01, 2'b00, 2'b11,
                                                  2'b01, 2'b10, 2'b11, 2'b00, 2'b00, 2'b11, 2'b10, 2'b01,
                                                  2'b10, 2'b01, 2'b00, 2'b11, 2'b11, 2'b00, 2'b01, 2'b10,
                                                  2'b11, 2'b00, 2'b01, 2'b10, 2'b10, 2'b01, 2'b00, 2'b11,
                                                  2'b00, 2'b11, 2'b10, 2'b01, 2'b01, 2'b10, 2'b11, 2'b00,
                                                  2'b10, 2'b01, 2'b00, 2'b11, 2'b11, 2'b00, 2'b01, 2'b10,
                                                  2'b01, 2'b10, 2'b11, 2'b00, 2'b00, 2'b11, 2'b10, 2'b01};
    
    // Trellis connecting variable, paired with best_path, Destination: Origin
    reg [5:0] trellis_connection [0:63] = {0, 32, 1, 33, 2, 34, 3, 35, 
                                           4, 36, 5, 37, 6, 38, 7, 39,
                                           8, 40, 9, 41, 10, 42, 11, 43,
                                          12, 44, 13, 45, 14, 46, 15, 47,
                                          16, 48, 17, 49, 18, 50, 19, 51,
                                          20, 52, 21, 53, 22, 54, 23, 55,
                                          24, 56, 25, 57, 26, 58, 27, 59,
                                          28, 60, 29, 61, 30, 62, 31, 63};
                                          
    reg [5:0] min_trellis = 0; //Stores the index of the best_path based on trellis_path_metric   
    
    // Creating the random variable
    //Packet pkt = new();
    
    reg [1:0] cycle_count = 0;
    reg cycle_finished = 0;
    
    always @(posedge clk) begin
    
        if (start) begin
    
        // Initializing, start from zero
        if (symbol_num == 0) begin
        
            trellis_path_metric[0][0] <= (encoded_bits ^ given_input_next_output[0]);
            trellis_path_metric[0][1] <= (encoded_bits ^ given_input_next_output[1]);
            
        end
        
        if (symbol_num == 1) begin
        
            trellis_path_metric[1][0] <= trellis_path_metric[0][0] + (encoded_bits ^ given_input_next_output[0]);
            trellis_path_metric[1][1] <= trellis_path_metric[0][0] + (encoded_bits ^ given_input_next_output[1]);
            trellis_path_metric[1][2] <= trellis_path_metric[0][1] + (encoded_bits ^ given_input_next_output[2]);
            trellis_path_metric[1][3] <= trellis_path_metric[0][1] + (encoded_bits ^ given_input_next_output[3]);

        end

        if (symbol_num == 2) begin// time t = 2
        
            // Calculating and Storing paths
            trellis_path_metric[2][0] <= trellis_path_metric[1][0] + (encoded_bits ^ given_input_next_output[0]);
            trellis_path_metric[2][1] <= trellis_path_metric[1][0] + (encoded_bits ^ given_input_next_output[1]);
            trellis_path_metric[2][2] <= trellis_path_metric[1][1] + (encoded_bits ^ given_input_next_output[2]);
            trellis_path_metric[2][3] <= trellis_path_metric[1][1] + (encoded_bits ^ given_input_next_output[3]);
            trellis_path_metric[2][4] <= trellis_path_metric[1][2] + (encoded_bits ^ given_input_next_output[4]);
            trellis_path_metric[2][5] <= trellis_path_metric[1][2] + (encoded_bits ^ given_input_next_output[5]);
            trellis_path_metric[2][6] <= trellis_path_metric[1][3] + (encoded_bits ^ given_input_next_output[6]);
            trellis_path_metric[2][7] <= trellis_path_metric[1][3] + (encoded_bits ^ given_input_next_output[7]);

        end
        
        if (symbol_num == 3) begin// time t = 3
            
            // Calculating and Storing paths
            trellis_path_metric[3][0] <= trellis_path_metric[2][0] + (encoded_bits ^ given_input_next_output[0]);
            trellis_path_metric[3][1] <= trellis_path_metric[2][0] + (encoded_bits ^ given_input_next_output[1]);
            trellis_path_metric[3][2] <= trellis_path_metric[2][1] + (encoded_bits ^ given_input_next_output[2]);
            trellis_path_metric[3][3] <= trellis_path_metric[2][1] + (encoded_bits ^ given_input_next_output[3]);
            trellis_path_metric[3][4] <= trellis_path_metric[2][2] + (encoded_bits ^ given_input_next_output[4]);
            trellis_path_metric[3][5] <= trellis_path_metric[2][2] + (encoded_bits ^ given_input_next_output[5]);
            trellis_path_metric[3][6] <= trellis_path_metric[2][3] + (encoded_bits ^ given_input_next_output[6]);
            trellis_path_metric[3][7] <= trellis_path_metric[2][3] + (encoded_bits ^ given_input_next_output[7]);
            
            trellis_path_metric[3][8] <= trellis_path_metric[2][4] + (encoded_bits ^ given_input_next_output[8]);
            trellis_path_metric[3][9] <= trellis_path_metric[2][4] + (encoded_bits ^ given_input_next_output[9]);
            trellis_path_metric[3][10] <= trellis_path_metric[2][5] + (encoded_bits ^ given_input_next_output[10]);
            trellis_path_metric[3][11] <= trellis_path_metric[2][5] + (encoded_bits ^ given_input_next_output[11]);
            trellis_path_metric[3][12] <= trellis_path_metric[2][6] + (encoded_bits ^ given_input_next_output[12]);
            trellis_path_metric[3][13] <= trellis_path_metric[2][6] + (encoded_bits ^ given_input_next_output[13]);
            trellis_path_metric[3][14] <= trellis_path_metric[2][7] + (encoded_bits ^ given_input_next_output[14]);
            trellis_path_metric[3][15] <= trellis_path_metric[2][7] + (encoded_bits ^ given_input_next_output[15]);

        end
        
        if (symbol_num == 4) begin// time t = 4
        
            // Calculating the XOR
            branches[0] <= (encoded_bits ^ given_input_next_output[0]);
            branches[1] <= (encoded_bits ^ given_input_next_output[1]);
            branches[2] <= (encoded_bits ^ given_input_next_output[2]);
            branches[3] <= (encoded_bits ^ given_input_next_output[3]);
            branches[4] <= (encoded_bits ^ given_input_next_output[4]);
            branches[5] <= (encoded_bits ^ given_input_next_output[5]);
            branches[6] <= (encoded_bits ^ given_input_next_output[6]);
            branches[7] <= (encoded_bits ^ given_input_next_output[7]);
            branches[8] <= (encoded_bits ^ given_input_next_output[8]);
            branches[9] <= (encoded_bits ^ given_input_next_output[9]);
            branches[10] <= (encoded_bits ^ given_input_next_output[10]);
            branches[11] <= (encoded_bits ^ given_input_next_output[11]);
            branches[12] <= (encoded_bits ^ given_input_next_output[12]);
            branches[13] <= (encoded_bits ^ given_input_next_output[13]);
            branches[14] <= (encoded_bits ^ given_input_next_output[14]);
            branches[15] <= (encoded_bits ^ given_input_next_output[15]);
            branches[16] <= (encoded_bits ^ given_input_next_output[16]);
            branches[17] <= (encoded_bits ^ given_input_next_output[17]);
            branches[18] <= (encoded_bits ^ given_input_next_output[18]);
            branches[19] <= (encoded_bits ^ given_input_next_output[19]);
            branches[20] <= (encoded_bits ^ given_input_next_output[20]);
            branches[21] <= (encoded_bits ^ given_input_next_output[21]);
            branches[22] <= (encoded_bits ^ given_input_next_output[22]);
            branches[23] <= (encoded_bits ^ given_input_next_output[23]);
            branches[24] <= (encoded_bits ^ given_input_next_output[24]);
            branches[25] <= (encoded_bits ^ given_input_next_output[25]);
            branches[26] <= (encoded_bits ^ given_input_next_output[26]);
            branches[27] <= (encoded_bits ^ given_input_next_output[27]);
            branches[28] <= (encoded_bits ^ given_input_next_output[28]);
            branches[29] <= (encoded_bits ^ given_input_next_output[29]);
            branches[30] <= (encoded_bits ^ given_input_next_output[30]);
            branches[31] <= (encoded_bits ^ given_input_next_output[31]);
         
            // Calculating and Storing paths
            trellis_path_metric[4][0] <= trellis_path_metric[3][0] + branches[0];
            trellis_path_metric[4][1] <= trellis_path_metric[3][0] + branches[1];
            trellis_path_metric[4][2] <= trellis_path_metric[3][1] + branches[2];
            trellis_path_metric[4][3] <= trellis_path_metric[3][1] + branches[3];
            trellis_path_metric[4][4] <= trellis_path_metric[3][2] + branches[4];
            trellis_path_metric[4][5] <= trellis_path_metric[3][2] + branches[5];
            trellis_path_metric[4][6] <= trellis_path_metric[3][3] + branches[6];
            trellis_path_metric[4][7] <= trellis_path_metric[3][3] + branches[7];
            
            trellis_path_metric[4][8] <= trellis_path_metric[3][4] + branches[8];
            trellis_path_metric[4][9] <= trellis_path_metric[3][4] + branches[9];
            trellis_path_metric[4][10] <= trellis_path_metric[3][5] + branches[10];
            trellis_path_metric[4][11] <= trellis_path_metric[3][5] + branches[11];
            trellis_path_metric[4][12] <= trellis_path_metric[3][6] + branches[12];
            trellis_path_metric[4][13] <= trellis_path_metric[3][6] + branches[13];
            trellis_path_metric[4][14] <= trellis_path_metric[3][7] + branches[14];
            trellis_path_metric[4][15] <= trellis_path_metric[3][7] + branches[15];
            
            trellis_path_metric[4][16] <= trellis_path_metric[3][8] + branches[16];
            trellis_path_metric[4][17] <= trellis_path_metric[3][8] + branches[17];
            trellis_path_metric[4][18] <= trellis_path_metric[3][9] + branches[18];
            trellis_path_metric[4][19] <= trellis_path_metric[3][9] + branches[19];
            trellis_path_metric[4][20] <= trellis_path_metric[3][10] + branches[20];
            trellis_path_metric[4][21] <= trellis_path_metric[3][10] + branches[21];
            trellis_path_metric[4][22] <= trellis_path_metric[3][11] + branches[22];
            trellis_path_metric[4][23] <= trellis_path_metric[3][11] + branches[23];
            
            trellis_path_metric[4][24] <= trellis_path_metric[3][12] + branches[24];
            trellis_path_metric[4][25] <= trellis_path_metric[3][12] + branches[25];
            trellis_path_metric[4][26] <= trellis_path_metric[3][13] + branches[26];
            trellis_path_metric[4][27] <= trellis_path_metric[3][13] + branches[27];
            trellis_path_metric[4][28] <= trellis_path_metric[3][14] + branches[28];
            trellis_path_metric[4][29] <= trellis_path_metric[3][14] + branches[29];
            trellis_path_metric[4][30] <= trellis_path_metric[3][15] + branches[30];
            trellis_path_metric[4][31] <= trellis_path_metric[3][15] + branches[31];
            
            trellis_path_metric[4][32] <= trellis_path_metric[3][0] + branches[0];
            trellis_path_metric[4][33] <= trellis_path_metric[3][0] + branches[1];
            trellis_path_metric[4][34] <= trellis_path_metric[3][1] + branches[2];
            trellis_path_metric[4][35] <= trellis_path_metric[3][1] + branches[3];
            trellis_path_metric[4][36] <= trellis_path_metric[3][2] + branches[4];
            trellis_path_metric[4][37] <= trellis_path_metric[3][2] + branches[5];
            trellis_path_metric[4][38] <= trellis_path_metric[3][3] + branches[6];
            trellis_path_metric[4][39] <= trellis_path_metric[3][3] + branches[7];
            
            trellis_path_metric[4][40] <= trellis_path_metric[3][4] + branches[8];
            trellis_path_metric[4][41] <= trellis_path_metric[3][4] + branches[9];
            trellis_path_metric[4][42] <= trellis_path_metric[3][5] + branches[10];
            trellis_path_metric[4][43] <= trellis_path_metric[3][5] + branches[11];
            trellis_path_metric[4][44] <= trellis_path_metric[3][6] + branches[12];
            trellis_path_metric[4][45] <= trellis_path_metric[3][6] + branches[13];
            trellis_path_metric[4][46] <= trellis_path_metric[3][7] + branches[14];
            trellis_path_metric[4][47] <= trellis_path_metric[3][7] + branches[15];
            
            trellis_path_metric[4][48] <= trellis_path_metric[3][8] + branches[16];
            trellis_path_metric[4][49] <= trellis_path_metric[3][8] + branches[17];
            trellis_path_metric[4][50] <= trellis_path_metric[3][9] + branches[18];
            trellis_path_metric[4][51] <= trellis_path_metric[3][9] + branches[19];
            trellis_path_metric[4][52] <= trellis_path_metric[3][10] + branches[20];
            trellis_path_metric[4][53] <= trellis_path_metric[3][10] + branches[21];
            trellis_path_metric[4][54] <= trellis_path_metric[3][11] + branches[22];
            trellis_path_metric[4][55] <= trellis_path_metric[3][11] + branches[23];
            
            trellis_path_metric[4][56] <= trellis_path_metric[3][12] + branches[24];
            trellis_path_metric[4][57] <= trellis_path_metric[3][12] + branches[25];
            trellis_path_metric[4][58] <= trellis_path_metric[3][13] + branches[26];
            trellis_path_metric[4][59] <= trellis_path_metric[3][13] + branches[27];
            trellis_path_metric[4][60] <= trellis_path_metric[3][14] + branches[28];
            trellis_path_metric[4][61] <= trellis_path_metric[3][14] + branches[29];
            trellis_path_metric[4][62] <= trellis_path_metric[3][15] + branches[30];
            trellis_path_metric[4][63] <= trellis_path_metric[3][15] + branches[31];
    
            best_path[4][0] = 1'b0;
            best_path[4][1] = 1'b0;
            best_path[4][2] = 1'b0;
            best_path[4][3] = 1'b0;
            best_path[4][4] = 1'b0;
            best_path[4][5] = 1'b0;
            best_path[4][6] = 1'b0;
            best_path[4][7] = 1'b0;        
            best_path[4][8] = 1'b0;
            best_path[4][9] = 1'b0;
            best_path[4][10] = 1'b0;
            best_path[4][11] = 1'b0;
            best_path[4][12] = 1'b0;
            best_path[4][13] = 1'b0;
            best_path[4][14] = 1'b0;
            best_path[4][15] = 1'b0;
            best_path[4][16] = 1'b0;
            best_path[4][17] = 1'b0;
            best_path[4][18] = 1'b0;
            best_path[4][19] = 1'b0;
            best_path[4][20] = 1'b0;
            best_path[4][21] = 1'b0;
            best_path[4][22] = 1'b0;
            best_path[4][23] = 1'b0;
            best_path[4][24] = 1'b0;
            best_path[4][25] = 1'b0;
            best_path[4][26] = 1'b0;
            best_path[4][27] = 1'b0;
            best_path[4][28] = 1'b0;
            best_path[4][29] = 1'b0;
            best_path[4][30] = 1'b0;
            best_path[4][31] = 1'b0;             
                                                                     
        end                

        // Trellis code
        if (symbol_num >= 5) begin

            // Calculate the hamming distance for each branch
            for (i = 0; i < 64; i = i + 1) begin
            
                // Calculating XOR
                branches[i] <= encoded_bits ^ given_input_next_output[i]; //XORing branch like in previous iterations
                
                // Storing into branch metric
                //trellis_branch_metric[symbol_num % 30][i] <= branches[i];
            end
            
            
            // The following 8 if statements update Path metric based on previous path plus the current branch
            if (trellis_path_metric[(symbol_num - 1) % 30][0] < trellis_path_metric[(symbol_num - 1) % 30][32])  begin
                trellis_path_metric[symbol_num % 30][0] = trellis_path_metric[(symbol_num - 1) % 30][0] + branches[0];
                trellis_path_metric[symbol_num % 30][1] = trellis_path_metric[(symbol_num - 1) % 30][0] + branches[1];
            end
            else begin
                trellis_path_metric[symbol_num % 30][0] = trellis_path_metric[(symbol_num - 1) % 30][32] + branches[0];
                trellis_path_metric[symbol_num % 30][1] = trellis_path_metric[(symbol_num - 1) % 30][32] + branches[1];
            end
            if (trellis_path_metric[(symbol_num - 1) % 30][1] < trellis_path_metric[(symbol_num - 1) % 30][33])  begin
                trellis_path_metric[symbol_num % 30][2] = trellis_path_metric[(symbol_num - 1) % 30][1] + branches[2];
                trellis_path_metric[symbol_num % 30][3] = trellis_path_metric[(symbol_num - 1) % 30][1] + branches[3];
            end
            else begin
                trellis_path_metric[symbol_num % 30][2] = trellis_path_metric[(symbol_num - 1) % 30][33] + branches[2];
                trellis_path_metric[symbol_num % 30][3] = trellis_path_metric[(symbol_num - 1) % 30][33] + branches[3];
            end
            if (trellis_path_metric[(symbol_num - 1) % 30][2] < trellis_path_metric[(symbol_num - 1) % 30][34])  begin
                trellis_path_metric[symbol_num % 30][4] = trellis_path_metric[(symbol_num - 1) % 30][2] + branches[4];
                trellis_path_metric[symbol_num % 30][5] = trellis_path_metric[(symbol_num - 1) % 30][2] + branches[5];
            end
            else begin
                trellis_path_metric[symbol_num % 30][4] = trellis_path_metric[(symbol_num - 1) % 30][34] + branches[4];
                trellis_path_metric[symbol_num % 30][5] = trellis_path_metric[(symbol_num - 1) % 30][34] + branches[5];
            end
            if (trellis_path_metric[(symbol_num - 1) % 30][3] < trellis_path_metric[(symbol_num - 1) % 30][35])  begin
                trellis_path_metric[symbol_num % 30][6] = trellis_path_metric[(symbol_num - 1) % 30][3] + branches[6];
                trellis_path_metric[symbol_num % 30][7] = trellis_path_metric[(symbol_num - 1) % 30][3] + branches[7];
            end
            else begin
                trellis_path_metric[symbol_num % 30][6] = trellis_path_metric[(symbol_num - 1) % 30][35] + branches[6];
                trellis_path_metric[symbol_num % 30][7] = trellis_path_metric[(symbol_num - 1) % 30][35] + branches[7];
            end
            if (trellis_path_metric[(symbol_num - 1) % 30][4] < trellis_path_metric[(symbol_num - 1) % 30][36])  begin
                trellis_path_metric[symbol_num % 30][8] = trellis_path_metric[(symbol_num - 1) % 30][4] + branches[8];
                trellis_path_metric[symbol_num % 30][9] = trellis_path_metric[(symbol_num - 1) % 30][4] + branches[9];
            end
            else begin
                trellis_path_metric[symbol_num % 30][8] = trellis_path_metric[(symbol_num - 1) % 30][36] + branches[8];
                trellis_path_metric[symbol_num % 30][9] = trellis_path_metric[(symbol_num - 1) % 30][36] + branches[9];
            end
            if (trellis_path_metric[(symbol_num - 1) % 30][5] < trellis_path_metric[(symbol_num - 1) % 30][37])  begin
                trellis_path_metric[symbol_num % 30][10] = trellis_path_metric[(symbol_num - 1) % 30][5] + branches[10];
                trellis_path_metric[symbol_num % 30][11] = trellis_path_metric[(symbol_num - 1) % 30][5] + branches[11];
            end
            else begin
                trellis_path_metric[symbol_num % 30][10] = trellis_path_metric[(symbol_num - 1) % 30][37] + branches[10];
                trellis_path_metric[symbol_num % 30][11] = trellis_path_metric[(symbol_num - 1) % 30][37] + branches[11];
            end
            if (trellis_path_metric[(symbol_num - 1) % 30][6] < trellis_path_metric[(symbol_num - 1) % 30][38])  begin
                trellis_path_metric[symbol_num % 30][12] = trellis_path_metric[(symbol_num - 1) % 30][6] + branches[12];
                trellis_path_metric[symbol_num % 30][13] = trellis_path_metric[(symbol_num - 1) % 30][6] + branches[13];
            end
            else begin
                trellis_path_metric[symbol_num % 30][12] = trellis_path_metric[(symbol_num - 1) % 30][38] + branches[12];
                trellis_path_metric[symbol_num % 30][13] = trellis_path_metric[(symbol_num - 1) % 30][38] + branches[13];
            end
            if (trellis_path_metric[(symbol_num - 1) % 30][7] < trellis_path_metric[(symbol_num - 1) % 30][39])  begin
                trellis_path_metric[symbol_num % 30][14] = trellis_path_metric[(symbol_num - 1) % 30][7] + branches[14];
                trellis_path_metric[symbol_num % 30][15] = trellis_path_metric[(symbol_num - 1) % 30][7] + branches[15];
            end
            else begin
                trellis_path_metric[symbol_num % 30][14] = trellis_path_metric[(symbol_num - 1) % 30][39] + branches[14];
                trellis_path_metric[symbol_num % 30][15] = trellis_path_metric[(symbol_num - 1) % 30][39] + branches[15];
            end                  
            
            if (trellis_path_metric[(symbol_num - 1) % 30][8] < trellis_path_metric[(symbol_num - 1) % 30][40])  begin
                trellis_path_metric[symbol_num % 30][16] = trellis_path_metric[(symbol_num - 1) % 30][8] + branches[16];
                trellis_path_metric[symbol_num % 30][17] = trellis_path_metric[(symbol_num - 1) % 30][8] + branches[17];
            end
            else begin
                trellis_path_metric[symbol_num % 30][16] = trellis_path_metric[(symbol_num - 1) % 30][40] + branches[16];
                trellis_path_metric[symbol_num % 30][17] = trellis_path_metric[(symbol_num - 1) % 30][40] + branches[17];
            end
            if (trellis_path_metric[(symbol_num - 1) % 30][9] < trellis_path_metric[(symbol_num - 1) % 30][41])  begin
                trellis_path_metric[symbol_num % 30][18] = trellis_path_metric[(symbol_num - 1) % 30][9] + branches[18];
                trellis_path_metric[symbol_num % 30][19] = trellis_path_metric[(symbol_num - 1) % 30][9] + branches[19];
            end
            else begin
                trellis_path_metric[symbol_num % 30][18] = trellis_path_metric[(symbol_num - 1) % 30][41] + branches[18];
                trellis_path_metric[symbol_num % 30][19] = trellis_path_metric[(symbol_num - 1) % 30][41] + branches[19];
            end
            if (trellis_path_metric[(symbol_num - 1) % 30][10] < trellis_path_metric[(symbol_num - 1) % 30][42])  begin
                trellis_path_metric[symbol_num % 30][20] = trellis_path_metric[(symbol_num - 1) % 30][10] + branches[20];
                trellis_path_metric[symbol_num % 30][21] = trellis_path_metric[(symbol_num - 1) % 30][10] + branches[21];
            end
            else begin
                trellis_path_metric[symbol_num % 30][20] = trellis_path_metric[(symbol_num - 1) % 30][42] + branches[20];
                trellis_path_metric[symbol_num % 30][21] = trellis_path_metric[(symbol_num - 1) % 30][42] + branches[21];
            end
            if (trellis_path_metric[(symbol_num - 1) % 30][11] < trellis_path_metric[(symbol_num - 1) % 30][43])  begin
                trellis_path_metric[symbol_num % 30][22] = trellis_path_metric[(symbol_num - 1) % 30][11] + branches[22];
                trellis_path_metric[symbol_num % 30][23] = trellis_path_metric[(symbol_num - 1) % 30][11] + branches[23];
            end
            else begin
                trellis_path_metric[symbol_num % 30][22] = trellis_path_metric[(symbol_num - 1) % 30][43] + branches[22];
                trellis_path_metric[symbol_num % 30][23] = trellis_path_metric[(symbol_num - 1) % 30][43] + branches[23];
            end
            if (trellis_path_metric[(symbol_num - 1) % 30][12] < trellis_path_metric[(symbol_num - 1) % 30][44])  begin
                trellis_path_metric[symbol_num % 30][24] = trellis_path_metric[(symbol_num - 1) % 30][12] + branches[24];
                trellis_path_metric[symbol_num % 30][25] = trellis_path_metric[(symbol_num - 1) % 30][12] + branches[25];
            end
            else begin
                trellis_path_metric[symbol_num % 30][24] = trellis_path_metric[(symbol_num - 1) % 30][44] + branches[24];
                trellis_path_metric[symbol_num % 30][25] = trellis_path_metric[(symbol_num - 1) % 30][44] + branches[25];
            end
            if (trellis_path_metric[(symbol_num - 1) % 30][13] < trellis_path_metric[(symbol_num - 1) % 30][45])  begin
                trellis_path_metric[symbol_num % 30][26] = trellis_path_metric[(symbol_num - 1) % 30][13] + branches[26];
                trellis_path_metric[symbol_num % 30][27] = trellis_path_metric[(symbol_num - 1) % 30][13] + branches[27];
            end
            else begin
                trellis_path_metric[symbol_num % 30][26] = trellis_path_metric[(symbol_num - 1) % 30][45] + branches[26];
                trellis_path_metric[symbol_num % 30][27] = trellis_path_metric[(symbol_num - 1) % 30][45] + branches[27];
            end
            if (trellis_path_metric[(symbol_num - 1) % 30][14] < trellis_path_metric[(symbol_num - 1) % 30][46])  begin
                trellis_path_metric[symbol_num % 30][28] = trellis_path_metric[(symbol_num - 1) % 30][14] + branches[28];
                trellis_path_metric[symbol_num % 30][29] = trellis_path_metric[(symbol_num - 1) % 30][14] + branches[29];
            end
            else begin
                trellis_path_metric[symbol_num % 30][28] = trellis_path_metric[(symbol_num - 1) % 30][46] + branches[28];
                trellis_path_metric[symbol_num % 30][29] = trellis_path_metric[(symbol_num - 1) % 30][46] + branches[29];
            end
            if (trellis_path_metric[(symbol_num - 1) % 30][15] < trellis_path_metric[(symbol_num - 1) % 30][47])  begin
                trellis_path_metric[symbol_num % 30][30] = trellis_path_metric[(symbol_num - 1) % 30][15] + branches[30];
                trellis_path_metric[symbol_num % 30][31] = trellis_path_metric[(symbol_num - 1) % 30][15] + branches[31];
            end
            
            else begin
                trellis_path_metric[symbol_num % 30][30] = trellis_path_metric[(symbol_num - 1) % 30][47] + branches[30];
                trellis_path_metric[symbol_num % 30][31] = trellis_path_metric[(symbol_num - 1) % 30][47] + branches[31];
            end
            if (trellis_path_metric[(symbol_num - 1) % 30][16] < trellis_path_metric[(symbol_num - 1) % 30][48])  begin
                trellis_path_metric[symbol_num % 30][32] = trellis_path_metric[(symbol_num - 1) % 30][16] + branches[32];
                trellis_path_metric[symbol_num % 30][33] = trellis_path_metric[(symbol_num - 1) % 30][16] + branches[33];
            end
            
            else begin
                trellis_path_metric[symbol_num % 30][32] = trellis_path_metric[(symbol_num - 1) % 30][48] + branches[32];
                trellis_path_metric[symbol_num % 30][33] = trellis_path_metric[(symbol_num - 1) % 30][48] + branches[33];
            end
            if (trellis_path_metric[(symbol_num - 1) % 30][17] < trellis_path_metric[(symbol_num - 1) % 30][49])  begin
                trellis_path_metric[symbol_num % 30][34] = trellis_path_metric[(symbol_num - 1) % 30][17] + branches[34];
                trellis_path_metric[symbol_num % 30][35] = trellis_path_metric[(symbol_num - 1) % 30][17] + branches[35];
            end
            else begin
                trellis_path_metric[symbol_num % 30][34] = trellis_path_metric[(symbol_num - 1) % 30][49] + branches[34];
                trellis_path_metric[symbol_num % 30][35] = trellis_path_metric[(symbol_num - 1) % 30][49] + branches[35];
            end
            if (trellis_path_metric[(symbol_num - 1) % 30][18] < trellis_path_metric[(symbol_num - 1) % 30][50])  begin
                trellis_path_metric[symbol_num % 30][36] = trellis_path_metric[(symbol_num - 1) % 30][18] + branches[36];
                trellis_path_metric[symbol_num % 30][37] = trellis_path_metric[(symbol_num - 1) % 30][18] + branches[37];
            end
            else begin
                trellis_path_metric[symbol_num % 30][36] = trellis_path_metric[(symbol_num - 1) % 30][50] + branches[36];
                trellis_path_metric[symbol_num % 30][37] = trellis_path_metric[(symbol_num - 1) % 30][50] + branches[37];
            end
            if (trellis_path_metric[(symbol_num - 1) % 30][19] < trellis_path_metric[(symbol_num - 1) % 30][51])  begin
                trellis_path_metric[symbol_num % 30][38] = trellis_path_metric[(symbol_num - 1) % 30][19] + branches[38];
                trellis_path_metric[symbol_num % 30][39] = trellis_path_metric[(symbol_num - 1) % 30][19] + branches[39];
            end
            else begin
                trellis_path_metric[symbol_num % 30][38] = trellis_path_metric[(symbol_num - 1) % 30][51] + branches[38];
                trellis_path_metric[symbol_num % 30][39] = trellis_path_metric[(symbol_num - 1) % 30][51] + branches[39];
            end           
            if (trellis_path_metric[(symbol_num - 1) % 30][20] < trellis_path_metric[(symbol_num - 1) % 30][52])  begin
                trellis_path_metric[symbol_num % 30][40] = trellis_path_metric[(symbol_num - 1) % 30][20] + branches[40];
                trellis_path_metric[symbol_num % 30][41] = trellis_path_metric[(symbol_num - 1) % 30][20] + branches[41];
            end
            else begin
                trellis_path_metric[symbol_num % 30][40] = trellis_path_metric[(symbol_num - 1) % 30][52] + branches[40];
                trellis_path_metric[symbol_num % 30][41] = trellis_path_metric[(symbol_num - 1) % 30][52] + branches[41];
            end   
            if (trellis_path_metric[(symbol_num - 1) % 30][21] < trellis_path_metric[(symbol_num - 1) % 30][53])  begin
                trellis_path_metric[symbol_num % 30][42] = trellis_path_metric[(symbol_num - 1) % 30][21] + branches[42];
                trellis_path_metric[symbol_num % 30][43] = trellis_path_metric[(symbol_num - 1) % 30][21] + branches[43];
            end
            else begin
                trellis_path_metric[symbol_num % 30][42] = trellis_path_metric[(symbol_num - 1) % 30][53] + branches[42];
                trellis_path_metric[symbol_num % 30][43] = trellis_path_metric[(symbol_num - 1) % 30][53] + branches[43];
            end
           if (trellis_path_metric[(symbol_num - 1) % 30][22] < trellis_path_metric[(symbol_num - 1) % 30][54])  begin
                trellis_path_metric[symbol_num % 30][44] = trellis_path_metric[(symbol_num - 1) % 30][22] + branches[44];
                trellis_path_metric[symbol_num % 30][45] = trellis_path_metric[(symbol_num - 1) % 30][22] + branches[45];
            end
            else begin
                trellis_path_metric[symbol_num % 30][44] = trellis_path_metric[(symbol_num - 1) % 30][54] + branches[44];
                trellis_path_metric[symbol_num % 30][45] = trellis_path_metric[(symbol_num - 1) % 30][54] + branches[45];
            end
            if (trellis_path_metric[(symbol_num - 1) % 30][23] < trellis_path_metric[(symbol_num - 1) % 30][55])  begin
                trellis_path_metric[symbol_num % 30][46] = trellis_path_metric[(symbol_num - 1) % 30][23] + branches[46];
                trellis_path_metric[symbol_num % 30][47] = trellis_path_metric[(symbol_num - 1) % 30][23] + branches[47];
            end
            else begin
                trellis_path_metric[symbol_num % 30][46] = trellis_path_metric[(symbol_num - 1) % 30][55] + branches[46];
                trellis_path_metric[symbol_num % 30][47] = trellis_path_metric[(symbol_num - 1) % 30][55] + branches[47];
            end
            if (trellis_path_metric[(symbol_num - 1) % 30][24] < trellis_path_metric[(symbol_num - 1) % 30][56])  begin
                trellis_path_metric[symbol_num % 30][48] = trellis_path_metric[(symbol_num - 1) % 30][24] + branches[48];
                trellis_path_metric[symbol_num % 30][49] = trellis_path_metric[(symbol_num - 1) % 30][24] + branches[49];
            end
            else begin
                trellis_path_metric[symbol_num % 30][48] = trellis_path_metric[(symbol_num - 1) % 30][56] + branches[48];
                trellis_path_metric[symbol_num % 30][49] = trellis_path_metric[(symbol_num - 1) % 30][56] + branches[49];
            end
             if (trellis_path_metric[(symbol_num - 1) % 30][25] < trellis_path_metric[(symbol_num - 1) % 30][57])  begin
                trellis_path_metric[symbol_num % 30][50] = trellis_path_metric[(symbol_num - 1) % 30][25] + branches[50];
                trellis_path_metric[symbol_num % 30][51] = trellis_path_metric[(symbol_num - 1) % 30][25] + branches[51];
            end
            else begin
                trellis_path_metric[symbol_num % 30][50] = trellis_path_metric[(symbol_num - 1) % 30][57] + branches[50];
                trellis_path_metric[symbol_num % 30][51] = trellis_path_metric[(symbol_num - 1) % 30][57] + branches[51];
            end
            if (trellis_path_metric[(symbol_num - 1) % 30][26] < trellis_path_metric[(symbol_num - 1) % 30][58])  begin
                trellis_path_metric[symbol_num % 30][52] = trellis_path_metric[(symbol_num - 1) % 30][26] + branches[52];
                trellis_path_metric[symbol_num % 30][53] = trellis_path_metric[(symbol_num - 1) % 30][26] + branches[53];
            end
            else begin
                trellis_path_metric[symbol_num % 30][52] = trellis_path_metric[(symbol_num - 1) % 30][58] + branches[52];
                trellis_path_metric[symbol_num % 30][53] = trellis_path_metric[(symbol_num - 1) % 30][58] + branches[53];
            end
            if (trellis_path_metric[(symbol_num - 1) % 30][27] < trellis_path_metric[(symbol_num - 1) % 30][59])  begin
                trellis_path_metric[symbol_num % 30][54] = trellis_path_metric[(symbol_num - 1) % 30][27] + branches[54];
                trellis_path_metric[symbol_num % 30][55] = trellis_path_metric[(symbol_num - 1) % 30][27] + branches[55];
            end
            else begin
                trellis_path_metric[symbol_num % 30][54] = trellis_path_metric[(symbol_num - 1) % 30][59] + branches[54];
                trellis_path_metric[symbol_num % 30][55] = trellis_path_metric[(symbol_num - 1) % 30][59] + branches[55];
            end
            if (trellis_path_metric[(symbol_num - 1) % 30][28] < trellis_path_metric[(symbol_num - 1) % 30][60])  begin
                trellis_path_metric[symbol_num % 30][56] = trellis_path_metric[(symbol_num - 1) % 30][28] + branches[56];
                trellis_path_metric[symbol_num % 30][57] = trellis_path_metric[(symbol_num - 1) % 30][28] + branches[57];
            end
            else begin
                trellis_path_metric[symbol_num % 30][56] = trellis_path_metric[(symbol_num - 1) % 30][60] + branches[56];
                trellis_path_metric[symbol_num % 30][57] = trellis_path_metric[(symbol_num - 1) % 30][60] + branches[57];
            end
            if (trellis_path_metric[(symbol_num - 1) % 30][29] < trellis_path_metric[(symbol_num - 1) % 30][61])  begin
                trellis_path_metric[symbol_num % 30][58] = trellis_path_metric[(symbol_num - 1) % 30][29] + branches[58];
                trellis_path_metric[symbol_num % 30][59] = trellis_path_metric[(symbol_num - 1) % 30][29] + branches[59];
            end
            else begin
                trellis_path_metric[symbol_num % 30][58] = trellis_path_metric[(symbol_num - 1) % 30][61] + branches[58];
                trellis_path_metric[symbol_num % 30][59] = trellis_path_metric[(symbol_num - 1) % 30][61] + branches[59];
            end
            if (trellis_path_metric[(symbol_num - 1) % 30][30] < trellis_path_metric[(symbol_num - 1) % 30][62])  begin
                trellis_path_metric[symbol_num % 30][60] = trellis_path_metric[(symbol_num - 1) % 30][30] + branches[60];
                trellis_path_metric[symbol_num % 30][61] = trellis_path_metric[(symbol_num - 1) % 30][30] + branches[61];
            end
            else begin
                trellis_path_metric[symbol_num % 30][60] = trellis_path_metric[(symbol_num - 1) % 30][62] + branches[60];
                trellis_path_metric[symbol_num % 30][61] = trellis_path_metric[(symbol_num - 1) % 30][62] + branches[61];
            end
            if (trellis_path_metric[(symbol_num - 1) % 30][31] < trellis_path_metric[(symbol_num - 1) % 30][63])  begin
                trellis_path_metric[symbol_num % 30][62] = trellis_path_metric[(symbol_num - 1) % 30][31] + branches[62];
                trellis_path_metric[symbol_num % 30][63] = trellis_path_metric[(symbol_num - 1) % 30][31] + branches[63];
            end
            else begin
                trellis_path_metric[symbol_num % 30][62] = trellis_path_metric[(symbol_num - 1) % 30][63] + branches[62];
                trellis_path_metric[symbol_num % 30][63] = trellis_path_metric[(symbol_num - 1) % 30][63] + branches[63];
            end
            
            //S0
            if (trellis_path_metric[symbol_num % 30][0] < trellis_path_metric[symbol_num % 30][32]) begin
                best_path[symbol_num % 30][0] = 1'b0;
            end
            else if (trellis_path_metric[symbol_num % 30][0] == trellis_path_metric[symbol_num % 30][32]) begin //for if the previous paths have same value randomly pick where to go back
                best_path[symbol_num % 30][0] = 1'b1;
            end
            else begin
                best_path[symbol_num % 30][0] = 1'b1;
            end
            
            // S1
            if (trellis_path_metric[symbol_num % 30][1] < trellis_path_metric[symbol_num % 30][33]) begin
                best_path[symbol_num % 30][1] = 1'b0;
            end
            else if (trellis_path_metric[symbol_num % 30][1] == trellis_path_metric[symbol_num % 30][33]) begin
                best_path[symbol_num % 30][1] = 1'b1;
            end
            else begin
                best_path[symbol_num % 30][1] = 1'b1;
            end
            
            // S2
            if (trellis_path_metric[symbol_num % 30][2] < trellis_path_metric[symbol_num % 30][34]) begin
                best_path[symbol_num % 30][2] = 1'b0;
            end
            else if (trellis_path_metric[symbol_num % 30][2] == trellis_path_metric[symbol_num % 30][34]) begin
                best_path[symbol_num % 30][2] = 1'b1;
            end
            else begin
                best_path[symbol_num % 30][2] = 1'b1;
            end
            
            // S3
            if (trellis_path_metric[symbol_num % 30][3] < trellis_path_metric[symbol_num % 30][35]) begin
                best_path[symbol_num % 30][3] = 1'b0;
            end
            else if (trellis_path_metric[symbol_num % 30][3] == trellis_path_metric[symbol_num % 30][35]) begin
                best_path[symbol_num % 30][3] = 1'b1;
            end
            else begin
                best_path[symbol_num % 30][3] = 1'b1;
            end
             // S4
            if (trellis_path_metric[symbol_num % 30][4] < trellis_path_metric[symbol_num % 30][36]) begin
                best_path[symbol_num % 30][4] = 1'b0;
            end
            else if (trellis_path_metric[symbol_num % 30][4] == trellis_path_metric[symbol_num % 30][36]) begin
                best_path[symbol_num % 30][4] = 1'b1;
            end
            else begin
                best_path[symbol_num % 30][4] = 1'b1;
            end
            // S5
            if (trellis_path_metric[symbol_num % 30][5] < trellis_path_metric[symbol_num % 30][37]) begin
                best_path[symbol_num % 30][5] = 1'b0;
            end
            else if (trellis_path_metric[symbol_num % 30][5] == trellis_path_metric[symbol_num % 30][37]) begin
                best_path[symbol_num % 30][5] = 1'b1;
            end
            else begin
                best_path[symbol_num % 30][5] = 1'b1;
            end
           // S6
            if (trellis_path_metric[symbol_num % 30][6] < trellis_path_metric[symbol_num % 30][38]) begin
                best_path[symbol_num % 30][6] = 1'b0;
            end
            else if (trellis_path_metric[symbol_num % 30][6] == trellis_path_metric[symbol_num % 30][38]) begin
                best_path[symbol_num % 30][6] = 1'b1;
            end
            else begin
                best_path[symbol_num % 30][6] = 1'b1;
            end
            // S7
            if (trellis_path_metric[symbol_num % 30][7] < trellis_path_metric[symbol_num % 30][39]) begin
                best_path[symbol_num % 30][7] = 1'b0;
            end
            else if (trellis_path_metric[symbol_num % 30][7] == trellis_path_metric[symbol_num % 30][39]) begin
                best_path[symbol_num % 30][7] = 1'b1;
            end
            else begin
                best_path[symbol_num % 30][7] = 1'b1;
            end
            // S8
            if (trellis_path_metric[symbol_num % 30][8] < trellis_path_metric[symbol_num % 30][40]) begin
                best_path[symbol_num % 30][8] = 1'b0;
            end
            else if (trellis_path_metric[symbol_num % 30][8] == trellis_path_metric[symbol_num % 30][40]) begin //for if the previous paths have same value randomly pick where to go bac
                best_path[symbol_num % 30][8] = 1'b1;
            end
            else begin
                best_path[symbol_num % 30][8] = 1'b1;
            end
            
            // S9
            if (trellis_path_metric[symbol_num % 30][9] < trellis_path_metric[symbol_num % 30][41]) begin
                best_path[symbol_num % 30][9] = 1'b0;
            end
            else if (trellis_path_metric[symbol_num % 30][9] == trellis_path_metric[symbol_num % 30][41]) begin
                best_path[symbol_num % 30][9] = 1'b1;
            end
            else begin
                best_path[symbol_num % 30][9] = 1'b1;
            end
            
            // S10
            if (trellis_path_metric[symbol_num % 30][10] < trellis_path_metric[symbol_num % 30][42]) begin
                best_path[symbol_num % 30][10] = 1'b0;
            end
            else if (trellis_path_metric[symbol_num % 30][10] == trellis_path_metric[symbol_num % 30][42]) begin
                best_path[symbol_num % 30][10] = 1'b1;
            end
            else begin
                best_path[symbol_num % 30][10] = 1'b1;
            end
            
            // S11
            if (trellis_path_metric[symbol_num % 30][11] < trellis_path_metric[symbol_num % 30][43]) begin
                best_path[symbol_num % 30][11] = 1'b0;
            end
            else if (trellis_path_metric[symbol_num % 30][11] == trellis_path_metric[symbol_num % 30][43]) begin
                best_path[symbol_num % 30][11] = 1'b1;
            end
            else begin
                best_path[symbol_num % 30][11] = 1'b1;
            end
             // S12
            if (trellis_path_metric[symbol_num % 30][12] < trellis_path_metric[symbol_num % 30][44]) begin
                best_path[symbol_num % 30][12] = 1'b0;
            end
            else if (trellis_path_metric[symbol_num % 30][12] == trellis_path_metric[symbol_num % 30][44]) begin
                best_path[symbol_num % 30][12] = 1'b1;
            end
            else begin
                best_path[symbol_num % 30][12] = 1'b1;
            end
            // S13
            if (trellis_path_metric[symbol_num % 30][13] < trellis_path_metric[symbol_num % 30][45]) begin
                best_path[symbol_num % 30][13] = 1'b0;
            end
            else if (trellis_path_metric[symbol_num % 30][13] == trellis_path_metric[symbol_num % 30][45]) begin
                best_path[symbol_num % 30][13] = 1'b1;
            end
            else begin
                best_path[symbol_num % 30][13] = 1'b1;
            end
           // S14
            if (trellis_path_metric[symbol_num % 30][14] < trellis_path_metric[symbol_num % 30][46]) begin
                best_path[symbol_num % 30][14] = 1'b0;
            end
            else if (trellis_path_metric[symbol_num % 30][14] == trellis_path_metric[symbol_num % 30][46]) begin
                best_path[symbol_num % 30][14] = 1'b1;
            end
            else begin
                best_path[symbol_num % 30][14] = 1'b1;
            end
            // S15
            if (trellis_path_metric[symbol_num % 30][15] < trellis_path_metric[symbol_num % 30][47]) begin
                best_path[symbol_num % 30][15] = 1'b0;
            end
            else if (trellis_path_metric[symbol_num % 30][15] == trellis_path_metric[symbol_num % 30][47]) begin
                best_path[symbol_num % 30][15] = 1'b1;
            end
            else begin
                best_path[symbol_num % 30][15] = 1'b1;
            end
             // S16
            if (trellis_path_metric[symbol_num % 30][16] < trellis_path_metric[symbol_num % 30][48]) begin
                best_path[symbol_num % 30][16] = 1'b0;
            end
            else if (trellis_path_metric[symbol_num % 30][16] == trellis_path_metric[symbol_num % 30][48]) begin
                best_path[symbol_num % 30][16] = 1'b1;
            end
            else begin
                best_path[symbol_num % 30][16] = 1'b1;
            end
            // S17
            if (trellis_path_metric[symbol_num % 30][17] < trellis_path_metric[symbol_num % 30][49]) begin
                best_path[symbol_num % 30][17] = 1'b0;
            end
            else if (trellis_path_metric[symbol_num % 30][17] == trellis_path_metric[symbol_num % 30][49]) begin
                best_path[symbol_num % 30][17] = 1'b1;
            end
            else begin
                best_path[symbol_num % 30][17] = 1'b1;
            end
            // S18
            if (trellis_path_metric[symbol_num % 30][18] < trellis_path_metric[symbol_num % 30][50]) begin
                best_path[symbol_num % 30][18] = 1'b0;
            end
            else if (trellis_path_metric[symbol_num % 30][18] == trellis_path_metric[symbol_num % 30][50]) begin
                best_path[symbol_num % 30][18] = 1'b1;
            end
            else begin
                best_path[symbol_num % 30][18] = 1'b1;
            end
            // S19
            if (trellis_path_metric[symbol_num % 30][19] < trellis_path_metric[symbol_num % 30][51]) begin
                best_path[symbol_num % 30][19] = 1'b0;
            end
            else if (trellis_path_metric[symbol_num % 30][19] == trellis_path_metric[symbol_num % 30][51]) begin
                best_path[symbol_num % 30][19] = 1'b1;
            end
            else begin
                best_path[symbol_num % 30][19] = 1'b1;
            end
            // S20
            if (trellis_path_metric[symbol_num % 30][20] < trellis_path_metric[symbol_num % 30][52]) begin
                best_path[symbol_num % 30][20] = 1'b0;
            end
            else if (trellis_path_metric[symbol_num % 30][20] == trellis_path_metric[symbol_num % 30][52]) begin
                best_path[symbol_num % 30][20] = 1'b1;
            end
            else begin
                best_path[symbol_num % 30][20] = 1'b1;
            end
            // S21
            if (trellis_path_metric[symbol_num % 30][21] < trellis_path_metric[symbol_num % 30][53]) begin
                best_path[symbol_num % 30][21] = 1'b0;
            end
            else if (trellis_path_metric[symbol_num % 30][21] == trellis_path_metric[symbol_num % 30][53]) begin
                best_path[symbol_num % 30][21] = 1'b1;
            end
            else begin
                best_path[symbol_num % 30][21] = 1'b1;
            end
            // S22
            if (trellis_path_metric[symbol_num % 30][22] < trellis_path_metric[symbol_num % 30][54]) begin
                best_path[symbol_num % 30][22] = 1'b0;
            end
            else if (trellis_path_metric[symbol_num % 30][22] == trellis_path_metric[symbol_num % 30][54]) begin
                best_path[symbol_num % 30][22] = 1'b1;
            end
            else begin
                best_path[symbol_num % 30][22] = 1'b1;
            end
            // S23
            if (trellis_path_metric[symbol_num % 30][23] < trellis_path_metric[symbol_num % 30][55]) begin
                best_path[symbol_num % 30][23] = 1'b0;
            end
            else if (trellis_path_metric[symbol_num % 30][23] == trellis_path_metric[symbol_num % 30][55]) begin
                best_path[symbol_num % 30][23] = 1'b1;
            end
            else begin
                best_path[symbol_num % 30][23] = 1'b1;
            end
            // S24
            if (trellis_path_metric[symbol_num % 30][24] < trellis_path_metric[symbol_num % 30][56]) begin
                best_path[symbol_num % 30][24] = 1'b0;
            end
            else if (trellis_path_metric[symbol_num % 30][24] == trellis_path_metric[symbol_num % 30][56]) begin
                best_path[symbol_num % 30][24] = 1'b1;
            end
            else begin
                best_path[symbol_num % 30][24] = 1'b1;
            end
            // S25
            if (trellis_path_metric[symbol_num % 30][25] < trellis_path_metric[symbol_num % 30][57]) begin
                best_path[symbol_num % 30][25] = 1'b0;
            end
            else if (trellis_path_metric[symbol_num % 30][25] == trellis_path_metric[symbol_num % 30][57]) begin
                best_path[symbol_num % 30][25] = 1'b1;
            end
            else begin
                best_path[symbol_num % 30][25] = 1'b1;
            end
            // S26
            if (trellis_path_metric[symbol_num % 30][26] < trellis_path_metric[symbol_num % 30][58]) begin
                best_path[symbol_num % 30][26] = 1'b0;
            end
            else if (trellis_path_metric[symbol_num % 30][26] == trellis_path_metric[symbol_num % 30][58]) begin
                best_path[symbol_num % 30][26] = 1'b1;
            end
            else begin
                best_path[symbol_num % 30][26] = 1'b1;
            end
            // S27
            if (trellis_path_metric[symbol_num % 30][27] < trellis_path_metric[symbol_num % 30][59]) begin
                best_path[symbol_num % 30][27] = 1'b0;
            end
            else if (trellis_path_metric[symbol_num % 30][27] == trellis_path_metric[symbol_num % 30][59]) begin
                best_path[symbol_num % 30][27] = 1'b1;
            end
            else begin
                best_path[symbol_num % 30][27] = 1'b1;
            end
            // S28
            if (trellis_path_metric[symbol_num % 30][28] < trellis_path_metric[symbol_num % 30][60]) begin
                best_path[symbol_num % 30][28] = 1'b0;
            end
            else if (trellis_path_metric[symbol_num % 30][28] == trellis_path_metric[symbol_num % 30][60]) begin
                best_path[symbol_num % 30][28] = 1'b1;
            end
            else begin
                best_path[symbol_num % 30][28] = 1'b1;
            end
            // S29
            if (trellis_path_metric[symbol_num % 30][29] < trellis_path_metric[symbol_num % 30][61]) begin
                best_path[symbol_num % 30][29] = 1'b0;
            end
            else if (trellis_path_metric[symbol_num % 30][29] == trellis_path_metric[symbol_num % 30][61]) begin
                best_path[symbol_num % 30][29] = 1'b1;
            end
            else begin
                best_path[symbol_num % 30][29] = 1'b1;
            end
            // S30
            if (trellis_path_metric[symbol_num % 30][30] < trellis_path_metric[symbol_num % 30][62]) begin
                best_path[symbol_num % 30][30] = 1'b0;
            end
            else if (trellis_path_metric[symbol_num % 30][30] == trellis_path_metric[symbol_num % 30][62]) begin
                best_path[symbol_num % 30][30] = 1'b1;
            end
            else begin
                best_path[symbol_num % 30][30] = 1'b1;
            end
            // S31
            if (trellis_path_metric[symbol_num % 30][31] < trellis_path_metric[symbol_num % 30][63]) begin
                best_path[symbol_num % 30][31] = 1'b0;
            end
            else if (trellis_path_metric[symbol_num % 30][31] == trellis_path_metric[symbol_num % 30][63]) begin
                best_path[symbol_num % 30][31] = 1'b1;
            end
            else begin
                best_path[symbol_num % 30][31] = 1'b1;
            end
       
        end
        
        // Picking an output
        if (symbol_num >= 29) begin
            
            
            if (cycle_count == 2'b11) begin
            
            // Traceback, which is the best ending path metric?
            trace_index = (symbol_num) % 30;
            min_trellis = 0;
            
            
            for (int i = 0; i < 64; i++) begin
                if (trellis_path_metric[trace_index][min_trellis] > trellis_path_metric[trace_index][i]) begin
                    min_trellis = i;
                end
                else if (trellis_path_metric[trace_index][min_trellis] == trellis_path_metric[trace_index][i]) begin
                    min_trellis = i;
                end
            end
            

            // Now need to go from that path backwards
            for (int i = 1; i < 26; i = i + 1) begin
                
                // trellis_connection and best_path tells us the previous state
                trace_index = (symbol_num - i) % 30;
                origin_index = min_trellis / 2;
                alpha = best_path[trace_index][origin_index];
                min_trellis = trellis_connection[(origin_index) * 2 + alpha];
            end
            
            // Giving output
            final_output = states[(min_trellis / 2)][1];
            buffer_out[symbol_num - 29] = states[(min_trellis / 2)][1];
            
            
            end
        end
        
        cycle_count++;
        
        if (cycle_count == 0 && symbol_num < 62 && cycle_finished == 1'b1) begin
            symbol_num++;
        end
        
        if (symbol_num >= 61) begin
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
