`timescale 1ns / 1ps

module Adder(
	src1_i,
	src2_i,
	result_o
);

//Input and output
input [32-1:0] src1_i , src2_i;
output [32-1:0] result_o;

//Internal signals
wire [32-1:0] result_o;

//Main function
assign result_o = src1_i + src2_i;

endmodule
