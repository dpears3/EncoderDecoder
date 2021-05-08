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

/*function void func_out;
    send_ready = 1'b1;

endfunction*/


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
reg [7:0] bit_number;
reg [31:0] buffer;
reg [63:0] encode_buffer = 64'hcefdd0c6a93d6236;
reg data_send_ready;
reg [7:0] send_counter;

reg unencoded_bit;               // 1 Bit received 
reg [2:0] out;   // Values 3 - 6, assumed here as 3

reg [7:0] bit_counter;
reg [7:0] byte_counter;
reg [9:0] out_counter;

reg encode_ready;

reg index;

reg send_data;
reg send_ready;



//decoder_sys decoder_s(.encoded_bits(data_in), .choose_constraint_length(3'b011), .final_output(data_out), .clk(clk));
encoder_k3 encoder_sys(.unencoded_bit(unencoded_bit), .clk(clk), .choose_constraint_length(choose_constraint_length), .out(out));
Debounce_Top center_deb(.clk(clk), .data_in(BTNC), .data_out(center));
Debounce_Top up_deb(.clk(clk), .data_in(BTNU), .data_out(up));
Debounce_Top down_deb(.clk(clk), .data_in(BTND), .data_out(down));
async_receiver RX(.clk(clk), .RxD(UART_TXD_IN), .RxD_data_ready(RxD_data_ready), .RxD_data(RxD_data));
async_transmitter TX(.clk(clk), .TxD(UART_RXD_OUT), .TxD_start(send_ready), .TxD_data(TxD_data)); // sends buffer back when ready


//// Module Code ////
always @(posedge clk) begin

    // Print Data out, push up and then center
    if (up) begin
       out_counter <= 10'b0000000001;
//	   TxD_data <= encode_buffer[7:0];
//	   encode_buffer <= encode_buffer >> 8;
	   //TxD_data <= buffer[7:0];
	   //buffer <= buffer >> 8;
    end
	
	if (out_counter > 10'b0000000000) begin
	   if (out_counter == 10'b0000000001) begin
	       TxD_data = buffer[7:0];
	       //buffer <= buffer >> 8;
	       send_ready <= 1'b0;
	   end
	   if (out_counter == 10'b0000000100) begin
	       send_ready <= 1'b1;
	   end
	   if (out_counter == 10'b1111100000) begin
	       TxD_data = encode_buffer[7:0];
	       //encode_buffer <= encode_buffer >> 8;
	       send_ready <= 1'b0;
	   end
	   if (out_counter == 10'b1111100100) begin
	       send_ready <= 1'b1;
	   end
	   if (out_counter > 10'b1111100111) begin
	       out_counter <= 10'b00000;
	       send_ready <= 1'b0;
	   end
	   else begin
	       out_counter <= out_counter + 1'b1;
	   end
	end
	
	if (counter == 4) begin
		encode_ready <= 1;
		counter++;
	end
	
/*	if (encode_ready) begin
	   unencoded_bit <= buffer[index];
	   encode_buffer[2*index] <= out[0];
	   encode_buffer[2*index + 1] <= out[1];
	   if (index >= 31) begin
	       encode_ready = 0;
	   end
	   index++;
	end*/
	
/*	if (byte_counter == 1 || byte_counter == 2 || byte_counter == 3 || byte_counter == 4) begin //Only first byte works still need to figure out shifting
	   index = bit_counter + (byte_counter - 1) * 8;
		unencoded_bit <= buffer[index];
		//encode_buffer[1:0] <= out;
	
		encode_buffer[2* index + 1] <= out[1];
		encode_buffer[2* index ] <= out[0];
		//sunencoded_bit = buffer[index];
		//encode_buffer[1:0] <= out;
		//encode_buffer <= encode_buffer << 2;
		bit_counter++;
		
		if (bit_counter > 7) begin
			bit_counter = 0;
			byte_counter++;
		//    buffer <= buffer >> 8;
			
			// All 8 bytes from encode_buffer ready
			if (byte_counter == 5) begin
				data_send_ready = 1'b1;
			end
		end
	end*/
	
	// Recieve 4 bytes of Data, down resets
	if (down) begin
		counter <= 0;
		byte_counter <= 0;
	end
	
/*	if (RxD_data_ready) begin
		if (counter >= 0 && counter < 4) begin 
			buffer[7:0] <= RxD_data;
			buffer <= buffer << 8;
		end
		counter++;
	end*/
	
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
	
	send_data = 1'b0;
    
end

endmodule
