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
reg [7:0] data;
reg [7:0] data_out;

Debounce_Top center_deb(.clk(clk), .data_in(BTNC), .data_out(center));
Debounce_Top up_deb(.clk(clk), .data_in(BTNU), .data_out(up));
async_receiver RX(.clk(clk), .RxD(UART_TXD_IN), .RxD_data_ready(RxD_data_ready), .RxD_data(RxD_data));
async_transmitter TX(.clk(clk), .TxD(UART_RXD_OUT), .TxD_start(center), .TxD_data(TxD_data));

//ECC_7 hamming(.data_in(data_out[6:0]), .error_out(error_out), .error_loc(error_loc), .clk(clk));


//// Module Code ////
always @(posedge clk) begin

    // When up pushed, data is stored
    if (up) begin
        //data <= RxD_data;
        //data_out <= RxD_data;
        TxD_data <= 16'b1111111111111111;
    end
    
//    if (error_out) begin
//        case (error_loc)
//            3'b000:
//                data_out <= {data[7:1], !data[0]};
//            3'b001:
//                data_out <= {data[7:2], !data[1], data[0]};
//            3'b010:
//                data_out <= {data[7:3], !data[2], data[1:0]};
//            3'b011:
//                data_out <= {data[7:4], !data[3], data[2:0]};
//            3'b100:
//                data_out <= {data[7:5], !data[4], data[3:0]};
//            3'b101:
//                data_out <= {data[7:6], !data[5], data[4:0]};
//            3'b110:
//                data_out <= {data[7], !data[6], data[5:0]};           
//        endcase
//        TxD_data <= 8'b11111111; //FF
//    end
//    else begin
//        TxD_data <= {1'b0, data_out[6:0]};
//    end
    
end

endmodule
