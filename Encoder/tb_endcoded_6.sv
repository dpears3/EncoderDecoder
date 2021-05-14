  
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/13/2020 10:59:18 AM
// Design Name: 
// Module Name: sim_encoder
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


module tb_endcoded_6();

    // Inputs
    reg unencoded_bit, clk, choose_constraint_length;
    
    // Outputs
    wire [1:0] out;
    
    // Instatiating
    encoder_k6 uut(.unencoded_bit(unencoded_bit), .clk(clk), .choose_constraint_length(choose_constraint_length), .out(out));
 
    // File handler
    integer input_file;
    integer scan_file;
    integer output_file;
    
    integer xx_remove;
    
    `define NULL 0   
    
    // Clock
    always #1 clk = ~clk;

    always @(posedge clk) begin
        xx_remove = 0;
        scan_file = $fscanf(input_file, "%d ", unencoded_bits); 
        if (!$feof(input_file)) begin
            //loading each line into unencoded bits
        end
    end
    
    initial begin
    
        // Prevent XX
        unencoded_bit = 0;
        xx_remove = 1;
        
        // Setup File Load as read
        input_file = $fopen("input_file.txt", "r");
        if (input_file == `NULL) begin
            $display("input_file handle was NULL");
            $finish;
        end
        
        output_file = $fopen("output_file.txt", "w");
    
        // Initialize clock
        clk = 0;
            
        // Loading from file
        while (!$feof(input_file)) begin
            if (xx_remove == 0) begin
                $fwrite(output_file,"%b ",out);
            end
            #2;
        end

        $fwrite(output_file,"%b ",out);

        #2;
        $fclose(output_file);
        $fclose(input_file);
               
        $finish;
        
    end
    
endmodule
