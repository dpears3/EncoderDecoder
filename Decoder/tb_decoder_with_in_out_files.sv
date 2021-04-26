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


module tb_decoder_sys_4();

    // Inputs
    reg clk;
    reg [2:0] choose_constraint_length;
    reg [1:0] encoded_bits;
    
    // Outputs
    wire final_output;
    
    // Instatiating
    decoder_sys_4 uut(.encoded_bits(encoded_bits), .choose_constraint_length(choose_constraint_length), .final_output(final_output), .clk(clk));

    // Clock
    always #1 clk = ~clk;

    // File handler
    integer input_file;
    integer scan_file;
    integer output_file;
    integer num_lines = 0;
    
    `define NULL 0
    
    always @(posedge clk) begin
        scan_file = $fscanf(input_file, "%d ", encoded_bits); 
        if (!$feof(input_file)) begin
            num_lines++;
            //loading each line into encoded bits
        end
    end    
    
    initial begin
    
        // Prevent XX
        encoded_bits = 0;
        choose_constraint_length = 3;

        // Setup File Load as read
        input_file = $fopen("output_error_file.txt", "r");
        if (input_file == `NULL) begin
            $display("input_file handle was NULL");
            $finish;
        end

        output_file = $fopen("output_viterbi_file.txt", "w");

        // Initialize Clock
        clk = 0;
        #40;
 
 
        // Loading from file
        for (int i = 0; i < num_lines; i++) begin
            $fwrite(output_file,"%b ",final_output);
            #2;
        end
        
        $fwrite(output_file,"%b ",final_output);
        $fclose(output_file);
        $fclose(input_file);

        $finish;
    end
    

endmodule
