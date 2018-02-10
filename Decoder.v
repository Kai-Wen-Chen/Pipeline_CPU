module Decoder(
	instr_op_i,
	WB_o,
	MemRead_o,
	MemWrite_o,
	MemtoReg_o,
	ALU_op_o,
	ALUSrc_o,
	RegDst_o,
);

//Input and output
input [6-1:0] instr_op_i;
output WB_o, MemRead_o, MemWrite_o, MemtoReg_o, ALUSrc_o, RegDst_o;
output [3-1:0] ALU_op_o;

//Internal signals
reg WB_o, MemRead_o, MemWrite_o, MemtoReg_o, ALUSrc_o, RegDst_o;
reg [3-1:0] ALU_op_o;

//Main function
initial begin
	WB_o = 0;
	MemRead_o = 0;
	MemWrite_o = 0;
	MemtoReg_o = 0;
	ALU_op_o = 3'b000;
	ALUSrc_o = 0;
	RegDst_o = 0;
end

always @ (instr_op_i) begin
	case (instr_op_i) 
		6'h00: begin // RTYPE
			WB_o = 1;
			MemRead_o = 0;
			MemWrite_o = 0;
			MemtoReg_o = 0;
			ALU_op_o = 3'b000;
			ALUSrc_o = 0;
			RegDst_o = 1;
		end

		6'h08: begin // ADDI
			WB_o = 1;
			MemRead_o = 0;
			MemWrite_o = 0;
			MemtoReg_o = 0;
			ALU_op_o = 3'b001;
			ALUSrc_o = 1;
			RegDst_o = 0;
		end

		6'h23: begin // LW
			WB_o = 1;
			MemRead_o = 1;
			MemWrite_o = 0;
			MemtoReg_o = 1;
			ALU_op_o = 3'b010;
			ALUSrc_o = 1;
			RegDst_o = 0;
		end

		6'h2B: begin // SW
			WB_o = 0;
			MemRead_o = 1;
			MemWrite_o = 1;
			MemtoReg_o = 0;
			ALU_op_o = 3'b011;
			ALUSrc_o = 1;
			RegDst_o = 0;
		end

		6'h0A: begin // SLTI
			WB_o = 1;
			MemRead_o = 0;
			MemWrite_o = 0;
			MemtoReg_o = 0;
			ALU_op_o = 3'b100;
			ALUSrc_o = 1;
			RegDst_o = 0;
		end

		6'h04: begin // BEQ
			WB_o = 0;
			MemRead_o = 0;
			MemWrite_o = 0;
			MemtoReg_o = 0;
			ALU_op_o = 3'b101;
			ALUSrc_o = 0;
			RegDst_o = 0;
		end

		default: begin
			WB_o = 0;
			MemRead_o = 0;
			MemWrite_o = 0;
			MemtoReg_o = 0;
			ALU_op_o = 3'b111;
			ALUSrc_o = 0;
			RegDst_o = 0;
		end
	endcase
end
endmodule
