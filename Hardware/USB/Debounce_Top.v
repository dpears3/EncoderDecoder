`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/10/2020 03:33:23 PM
// Design Name: 
// Module Name: Debounce_Top
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


module Debounce_Top(input clk, input data_in, output data_out);
    wire filtered;
    Filter #(.wd(16),.n(65535),.bound(64000)) F(.data_in(data_in), .clk(clk), .data_out(filtered));
    Edge_Detector E(.clk(clk), .sigIn(filtered), .sigOut(data_out));
endmodule

 module Filter(	
      // Inputs
      clk,data_in,
      // Outputs
      data_out
);
 input clk,data_in;
 output  data_out;
 parameter   wd=3;
 parameter   n=7;
 parameter   bound=5;
 
 reg holder;
 reg[wd-1:0] counter;
 
/*****************************************************************************
 *                         sequential logic                                  *
 *****************************************************************************/ 
	always @(posedge clk)
		begin
			if(data_in == 1'b1 && counter < n)
				counter <= counter + {{(wd-1){1'd0}},1'd1};
			else if(data_in == 1'b0 && counter > 0)	
				counter <= counter + {(wd){1'd1}};
			holder <= data_out;				
		end
 /*****************************************************************************
 *                         combinational logic                                *
 *****************************************************************************/ 
    assign data_out		= (counter <= n-bound)? 1'b0:
						  (counter >= bound)? 1'b1 : holder;
endmodule
    
	
module Edge_Detector(
    input clk, sigIn,
    output sigOut
);
    wire q;
    dff_resetless r1(.clk(clk), .data(sigIn), .q(q));
    assign sigOut = sigIn & !q;
endmodule

module dff_resetless(
    input clk,
    input data, 
    output reg q
);
    always@(posedge clk)
    begin
        q <= data;
    end
endmodule
