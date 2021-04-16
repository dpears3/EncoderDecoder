`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/26/2020 06:46:58 PM
// Design Name: 
// Module Name: ECC_7
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


module ECC_7(data_in, error_out, error_loc, clk);

    input [6:0] data_in;
    input clk;
    reg [6:0] in_reg;
    reg [2:0] syndrome;
    output reg error_out;
    output reg [2:0] error_loc; // corresponds to bit location, 1 means in[1] has error
    
    always @(posedge clk) begin
        
        in_reg <= data_in;
        syndrome <= {in_reg[3], in_reg[1], in_reg[0]} ^ 
        {in_reg[4] ^ in_reg[5] ^ in_reg[6], in_reg[2] ^ in_reg[5] ^ in_reg[6], in_reg[2] ^ in_reg[4] ^ in_reg[6]};
        
        case(syndrome)
        
            // No error
            3'b000: begin
                error_out <= 1'b0;
            end
            
            // Error at e1
            3'b001: begin
                error_out <= 1'b1;
                error_loc <= 3'b000;
            end
            
            // Error at e2
            3'b010: begin
                error_out <= 1'b1;
                error_loc <= 3'b001;            
            end
            
            // Error at e3
            3'b011: begin
                error_out <= 1'b1;
                error_loc <= 3'b010;           
            end
            
            // Error at e4
            3'b100: begin
                error_out <= 1'b1;
                error_loc <= 3'b011;            
            end
            
            // Error at e5
            3'b101: begin
                error_out <= 1'b1;
                error_loc <= 3'b100;            
            end
            
            // Error at e6
            3'b110: begin
                error_out <= 1'b1;
                error_loc <= 3'b101;            
            end
            
            // Error at e7
            3'b111: begin
                error_out <= 1'b1;
                error_loc <= 3'b110;            
            end
        endcase
    end

endmodule
