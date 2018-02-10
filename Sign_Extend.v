`timescale 1ns / 1ps

module Sign_Extend(
	data_i,
	data_o,
);

//Input and output
input [16-1:0] data_i;
output [32-1:0] data_o;

//Internal signals
reg signed [32-1:0] data_o;

//Main function
initial begin
	data_o = 0;
end

always @ (data_i) begin
	if (data_i[15] == 0) data_o[31:16] = 16'd0;
	else data_o[31:16] = 16'b1111111111111111;

	data_o[15:0] = data_i;	
end

endmodule
