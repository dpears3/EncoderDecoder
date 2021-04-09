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


module top(UART_TXD_IN, UART_RXD_OUT, BTNC, BTNU, BTND, clk);

// Inputs and outputs
input BTNC, BTNU, BTND, clk;
input UART_TXD_IN;
output UART_RXD_OUT;

// Data to transmit 8 bits at a time
reg data_transmit [7:0];
reg [7:0] data;

// Variables for UART
wire center, up;
reg [7:0] TxD_data; // transmitting data
wire error_out;
wire [2:0] error_loc;
wire RxD_data_ready;
wire [7:0] RxD_data; // Recieved data
reg [7:0] counter;
reg [31:0] buffer;

wire [1:0] encoded_bits;               // 2 Bits received 
wire [2:0] choose_constraint_length;   // Values 3 - 6, assumed here as 3

//decoder_sys decoder_s(.encoded_bits(data_in), .choose_constraint_length(3'b011), .final_output(data_out), .clk(clk));
encoder_sys encoder(.unencoded_bits(unencoded_bit), .clk(clk), .choose_constraint_length(choose_constraint_length), .out(out))
Debounce_Top center_deb(.clk(clk), .data_in(BTNC), .data_out(center));
Debounce_Top up_deb(.clk(clk), .data_in(BTNU), .data_out(up));
Debounce_Top down_deb(.clk(clk), .data_in(BTND), .data_out(down));
Debounce_Top left_deb(.clk(clk), .data_in(BTNL), .data_out(left));
async_receiver RX(.clk(clk), .RxD(UART_TXD_IN), .RxD_data_ready(RxD_data_ready), .RxD_data(RxD_data));
async_transmitter TX(.clk(clk), .TxD(UART_RXD_OUT), .TxD_start(center), .TxD_data(TxD_data)); // Center button sends buffer back


//// Module Code ////
always @(posedge clk) begin

    // Print Data out
    if (up) begin
        //TxD_data <= RxD_data;
		//TxD_data <= counter;
		TxD_data <= buffer[7:0];
		buffer <= buffer >> 8;
    end
	
	if (down) begin
		counter <= 0;
	end
	
	// Parse inputs of 4 bytes
	if (RxD_data_ready) begin
		counter++;
		if (counter == 1) begin 
			buffer[7:0] <= RxD_data;
		end
		if (counter == 2) begin 
			buffer[15:8] <= RxD_data;
		end
		if (counter == 3) begin 
			buffer[23:16] <= RxD_data;
		end
		if (counter == 4) begin 
			buffer[31:24] <= RxD_data;
		end
	end
    
end

endmodule
