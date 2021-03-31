`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/12/2021 10:47:47 AM
// Design Name: 
// Module Name: top
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


module top(UART_TXD_IN, UART_RXD_OUT, BTNC, BTNU, clk);

// Inputs and outputs
input BTNC, BTNU, clk;
input UART_TXD_IN;
output UART_RXD_OUT;

// Variables for UART
wire center, up;
reg [7:0] TxD_data; // transmitting data
wire error_out;
wire [2:0] error_loc;
wire RxD_data_ready;
wire [7:0] RxD_data; // Recieved data
reg [2:0] data_in;
reg [7:0] data;
reg [7:0] data_out;

    wire clk;
    wire [1:0] encoded_bits;               // 2 Bits received 
    wire [2:0] choose_constraint_length;   // Values 3 - 6, assumed here as 3
    
decoder_sys decoder_s(.encoded_bits(data_in), .choose_constraint_length(3'b011), .final_output(data_out), .clk(clk));
Debounce_Top center_deb(.clk(clk), .data_in(BTNC), .data_out(center));
Debounce_Top up_deb(.clk(clk), .data_in(BTNU), .data_out(up));
async_receiver RX(.clk(clk), .RxD(UART_TXD_IN), .RxD_data_ready(RxD_data_ready), .RxD_data(RxD_data));
async_transmitter TX(.clk(clk), .TxD(UART_RXD_OUT), .TxD_start(center), .TxD_data(TxD_data));

//ECC_7 hamming(.data_in(data_out[6:0]), .error_out(error_out), .error_loc(error_loc), .clk(clk));


//// Module Code ////
always @(posedge clk) begin

    // 8 Bits recieved at a time
    if (up) begin
        //data <= RxD_data;
        TxD_data <= RxD_data;
    end
    
end

endmodule
