`timescale 1ns / 1ps

module ALU(
	src1_i,
	src2_i,
	ctrl_i,
	result_o,
);

//Input and output
input [32-1:0] src1_i, src2_i;
input [4-1:0] ctrl_i;
output [32-1:0] result_o;

//Internal signals
reg signed [32-1:0] signed_src1, signed_src2, result_o;

//Main function
always @ (src1_i or src2_i or ctrl_i) begin
	signed_src1 = src1_i;
	signed_src2 = src2_i;
	
	case(ctrl_i)
		4'b0000: result_o = signed_src1 & signed_src2; // AND
		4'b0001: result_o = signed_src1 | signed_src2; // OR
		4'b0010: result_o = signed_src1 + signed_src2; // ADD
		4'b0011: result_o = signed_src1 - signed_src2; // SUB
		4'b0100: result_o = (signed_src1 < signed_src2) ? 32'd1 : 32'd0; // SLT
		4'b0101: result_o = signed_src1 + signed_src2; // LW
		4'b0110: result_o = signed_src1 + signed_src2; // SW
		4'b0111: result_o = 32'd0; // BEQ
		default: result_o = 32'd0;
	endcase
end

endmodule
