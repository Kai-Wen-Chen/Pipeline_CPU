`timescale 1ns / 1ps

module ALU_Ctrl(
	funct_i,
	ALUop_i,
	ALUCtrl_o
);

//Input and outpu
input [6-1:0] funct_i;
input [3-1:0] ALUop_i;
output [4-1:0] ALUCtrl_o;

//Internal signals
reg [4-1:0] ALUCtrl_o;

//Main function
initial begin
	ALUCtrl_o = 0;
end 

always @ (funct_i or ALUop_i) begin
	case(ALUop_i)
		3'b000: begin // RTYPE
			case(funct_i)
				6'h24: ALUCtrl_o = 4'b0000; // AND
				6'h25: ALUCtrl_o = 4'b0001; // OR
				6'h20: ALUCtrl_o = 4'b0010; // ADD
				6'h22: ALUCtrl_o = 4'b0011; // SUB
				6'h2a: ALUCtrl_o = 4'b0100; // SLT
				default: ALUCtrl_o = 4'b1111;
			endcase
		end

		3'b001: ALUCtrl_o = 4'b0010; // ADDI
		3'b010: ALUCtrl_o = 4'b0101; // LW
		3'b011: ALUCtrl_o = 4'b0110; // SW
		3'b100: ALUCtrl_o = 4'b0100; // SLTI
		3'b101: ALUCtrl_o = 4'b0111; // BEQ
		default: ALUCtrl_o = 4'b1111;	
	endcase	
end

endmodule
