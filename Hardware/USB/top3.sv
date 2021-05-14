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

reg [0:63] buffer;
reg [0:63] encode_buffer;
reg [0:31] decode_buffer;
//reg data_send_ready;
//reg [7:0] send_counter;

reg unencoded_bit;               // 1 Bit received 
reg [1:0] encoder_out;
reg [1:0] decoder_in;
reg decoder_out;

//reg [7:0] bit_counter;
//reg [7:0] byte_counter;
reg [23:0] out_counter;

reg encode_ready;

reg [7:0] index;
reg [7:0] decode_index;

reg send_data;
reg send_ready;
reg remove_zero;
reg decode_start;
reg decoder_data_ready;

wire rst;

reg [1:0] shift_reg = 0; //register
reg [0:31] cycle_out = 64'h1000000000000000;
integer symbol_num;
integer prev_symbol;

decoder_k3 decoder_sys(.encoded_bits(decoder_in), .choose_constraint_length(3'b011), .final_output(decoder_out), .clk(clk), .start(decode_start), .ready(decoder_data_ready), .symbol_num(symbol_num));
encoder_k3 encoder_sys(.unencoded_bit(unencoded_bit), .clk(clk), .choose_constraint_length(choose_constraint_length), .out(encoder_out), .rst(rst));
Debounce_Top center_deb(.clk(clk), .data_in(BTNC), .data_out(center));
Debounce_Top up_deb(.clk(clk), .data_in(BTNU), .data_out(up));
Debounce_Top down_deb(.clk(clk), .data_in(BTND), .data_out(down));
async_receiver RX(.clk(clk), .RxD(UART_TXD_IN), .RxD_data_ready(RxD_data_ready), .RxD_data(RxD_data));
async_transmitter TX(.clk(clk), .TxD(UART_RXD_OUT), .TxD_start(send_ready), .TxD_data(TxD_data)); // sends buffer back when ready

//logic [4:0] array_data [0:14][0:7];

//// Module Code ////
always @(posedge clk) begin

    // Print out
    if (up) begin
       out_counter <= 20'h00001;
    end
	
	if (out_counter > 0) begin
	
/*	   case (out_counter)
	       24'h000001: begin TxD_data <= buffer[0:7]; send_ready <= 1'b0; end  
	       24'h000002: send_ready <= 1'b1;
	       24'h000004: begin TxD_data <= buffer[8:15]; send_ready <= 1'b0; end
	       24'h0FFFF1: send_ready <= 1'b1;
	       24'h0FFFF3: begin TxD_data <= buffer[16:23]; send_ready <= 1'b0; end
	       24'h1FFFF1: send_ready <= 1'b1;
	       24'h1FFFF3: begin TxD_data <= buffer[24:31]; send_ready <= 1'b0; end
	       24'h2FFFF1: send_ready <= 1'b1;
	       24'h2FFFF3: begin TxD_data <= encode_buffer[0:7]; send_ready <= 1'b0; end
	       24'h3FFFF1: send_ready <= 1'b1;
	       24'h3FFFF3: begin TxD_data <= encode_buffer[8:15]; send_ready <= 1'b0; end
	       24'h4FFFF1: send_ready <= 1'b1;
	       24'h4FFFF3: begin TxD_data <= encode_buffer[16:23]; send_ready <= 1'b0; end
	       24'h5FFFF1: send_ready <= 1'b1;
	       24'h5FFFF3: begin TxD_data <= encode_buffer[24:31]; send_ready <= 1'b0; end
	       24'h6FFFF1: send_ready <= 1'b1;  
	       24'h6FFFF3: begin TxD_data <= encode_buffer[32:39]; send_ready <= 1'b0; end
	       24'h7FFFF1: send_ready <= 1'b1;
	       24'h7FFFF3: begin TxD_data <= encode_buffer[40:47]; send_ready <= 1'b0; end
	       24'h8FFFF1: send_ready <= 1'b1;
	       24'h8FFFF3: begin TxD_data <= encode_buffer[48:55]; send_ready <= 1'b0; end
	       24'h9FFFF1: send_ready <= 1'b1;
	       24'h9FFFF3: begin TxD_data <= encode_buffer[56:63]; send_ready <= 1'b0; end
	       24'hAFFFF1: send_ready <= 1'b1;
	   endcase*/
	   
	   case (out_counter)
           24'h000001: begin TxD_data <= buffer[0:7]; send_ready <= 1'b0; end  
	       24'h000002: send_ready <= 1'b1;
	       24'h000004: begin TxD_data <= buffer[8:15]; send_ready <= 1'b0; end
	       24'h0FFFF1: send_ready <= 1'b1;
	       24'h0FFFF3: begin TxD_data <= buffer[16:23]; send_ready <= 1'b0; end
	       24'h1FFFF1: send_ready <= 1'b1;
	       24'h1FFFF3: begin TxD_data <= buffer[24:31]; send_ready <= 1'b0; end
	       24'h2FFFF1: send_ready <= 1'b1;
	       24'h2FFFF3: begin TxD_data <= buffer[32:39]; send_ready <= 1'b0; end
	       24'h3FFFF1: send_ready <= 1'b1;
	       24'h3FFFF3: begin TxD_data <= buffer[40:47]; send_ready <= 1'b0; end
	       24'h4FFFF1: send_ready <= 1'b1;
	       24'h4FFFF3: begin TxD_data <= buffer[48:55]; send_ready <= 1'b0; end
	       24'h5FFFF1: send_ready <= 1'b1;
	       24'h5FFFF3: begin TxD_data <= buffer[56:63]; send_ready <= 1'b0; end
	       24'h6FFFF1: send_ready <= 1'b1;  
	       24'h6FFFF3: begin TxD_data <= decode_buffer[0:7]; send_ready <= 1'b0; end
	       24'h7FFFF1: send_ready <= 1'b1;
	       24'h7FFFF3: begin TxD_data <= decode_buffer[8:15]; send_ready <= 1'b0; end
	       24'h8FFFF1: send_ready <= 1'b1;
	       24'h8FFFF3: begin TxD_data <= decode_buffer[16:23]; send_ready <= 1'b0; end
	       24'h9FFFF1: send_ready <= 1'b1;
	       24'h9FFFF3: begin TxD_data <= decode_buffer[24:31]; send_ready <= 1'b0; end
	       24'hAFFFF1: send_ready <= 1'b1; 
	   endcase

	   if (out_counter > 24'hAFFFF6) begin
	       out_counter <= 0;
	       send_ready <= 1'b0;
	   end
	   else begin
	       out_counter <= out_counter + 1'b1;
	   end
	end

	// Encoding 32 bits
	if (encode_ready == 1 && index < 33) begin

	   unencoded_bit <= buffer[index];
	   
	   if (remove_zero) begin
	       encode_buffer[(2*index) - 2] <= (unencoded_bit^shift_reg[1])^shift_reg[0];
           encode_buffer[(2*index + 1) - 2] <= unencoded_bit^shift_reg[0];
	   end
	   if (index >= 32) begin
	       encode_ready = 0;
	   end
	   
	   shift_reg = shift_reg>>1;
       shift_reg[1] = unencoded_bit;
	   
	   index++;
	   remove_zero <= 1'b1;
	end
	
	// Decoding 32 charateres
	if (decode_start == 1) begin
	      
       // Sending data to decoder
       //decoder_in[0] <= buffer[2*index];
       //decoder_in[1] <= buffer[2*index + 1];
        if (index == 0) begin
            decoder_in <= 2'b11;
        end
        else if (index == 1) begin
            decoder_in <= 2'b01;
        end
        else begin
            decoder_in <= 2'b10;
        end
	   
       // Once producing output, write to buffer
       if (decoder_data_ready && decode_index < 32) begin
           decode_buffer[decode_index] <= decoder_out;
           decode_index++;
       end
        
        //buffer <= 64'h1000000000000000;
        
//	   if (decode_index < 32) begin
//	       decode_buffer[decode_index] <= decoder_out;
//	       decode_index++;
//	   end

//        if (decoder_out == 1'b1) begin
//            decode_buffer[0:31] <= cycle_out;
//            decode_start <= 0;
//        end

//        if (symbol_num >= 14 && (symbol_num - 14) < 32) begin
//            decode_buffer[symbol_num - 14] <= decoder_out;
//            //decode_index++;
//        end
        
        //if (prev_symbol != symbol_num) begin
        //    index++;
        //end
        
	    index++;
	    //prev_symbol <= symbol_num;
	    //cycle_out++;
	end
	
	
	// Recieve 4 bytes of Data, down resets
	if (down) begin
		counter <= 0;
		//byte_counter <= 0;
	end
	
	if (RxD_data_ready) begin
		counter++;
		if (counter == 1) begin 
			buffer[0:7] <= RxD_data;
		end
		if (counter == 2) begin 
			buffer[8:15] <= RxD_data;
		end
		if (counter == 3) begin 
			buffer[16:23] <= RxD_data;
		end
		if (counter == 4) begin 
			buffer[24:31] <= RxD_data;
			//encode_ready <= 1;
		end
		if (counter == 5) begin 
			buffer[32:39] <= RxD_data;
		end
		if (counter == 6) begin 
			buffer[40:47] <= RxD_data;
		end
		if (counter == 7) begin 
			buffer[48:55] <= RxD_data;
		end
		if (counter == 8) begin 
			buffer[56:63] <= RxD_data;
			decoder_in <= buffer[0:1];
			decode_start <= 1;
		end
	end
	
	send_data = 1'b0;
    
end

endmodule
