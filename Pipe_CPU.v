`timescale 1ns / 1ps
/*******************************************************************
 * Create Date: 	2016/05/03
 * Design Name: 	Pipeline CPU
 * Module Name:		Pipe_CPU 
 * Project Name: 	Architecture Project_3 Pipeline CPU
 
 * Please DO NOT change the module name, or your'll get ZERO point.
 * You should add your code here to complete the project 3.
 ******************************************************************/
module Pipe_CPU(
        clk_i,
		rst_i
		);
    
/****************************************
*            I/O ports                  *
****************************************/
input clk_i;
input rst_i;

/****************************************
*          Internal signal              *
****************************************/

/**** IF stage ****/
//control signal...
wire [32-1:0] pc_in, pc_out;
wire [32-1:0] instr;
wire [32-1:0] IF_ID_reg;

/**** ID stage ****/
//control signal...
wire [32-1:0] ID_EX_Rs_data, ID_EX_Rt_data, sign_imm;
wire [5-1:0] RDaddr;
wire WB, MemRead, MemWrite, MemtoReg;
wire [3-1:0] ALUop;
wire ALUSrc, RegDst;
wire [126-1:0] ID_EX_reg;  

/**** EX stage ****/
//control signal...
wire [32-1:0] src1, src2, EX_MEM_result, EX_Rt_Data, result;
wire [4-1:0] ALUCtrl;
wire [73-1:0] EX_MEM_reg;

/**** MEM stage ****/
//control signal...
wire [32-1:0] MEM_data;
wire [71-1:0] MEM_WB_reg;  

/**** WB stage ****/
//control signal...
wire [32-1:0] MEM_WB_Rd_data;

/**** Data hazard ****/
//control signal...
wire [2-1:0] ForwardA, ForwardB;

/****************************************
*       Instantiate modules             *
****************************************/
//Instantiate the components in IF stage
ProgramCounter PC(
	.clk_i(clk_i),
	.rst_i(rst_i),
	.pc_in_i(pc_in),
	.pc_out_o(pc_out)
        );

Instr_Memory IM(
	.pc_addr_i(pc_out),
	.instr_o(instr)
	    );
			
Adder Add_pc(
	.src1_i(pc_out),
	.src2_i(32'd4),
	.result_o(pc_in)
		);
		
Pipe_Reg #(.size(32)) IF_ID(       
	.rst_i(rst_i),
	.clk_i(clk_i),
	.data_i(instr),
	.data_o(IF_ID_reg) // IF/ID_reg = instr
		);
		
//Instantiate the components in ID stage
Reg_File RF(
	.clk_i(clk_i),
	.rst_i(rst_i),
	.RSaddr_i(IF_ID_reg[25:21]), // IF_ID_Rs_addr
	.RTaddr_i(IF_ID_reg[20:16]), // IF_ID_Rt_addr
	.RDaddr_i(MEM_WB_reg[4:0]), // IF_ID_Rd_addr
	.RDdata_i(MEM_WB_Rd_data), // MEM_WB_Rd_data
	.RegWrite_i(MEM_WB_reg[70]), // WB
	.RSdata_o(ID_EX_Rs_data), // ID_EX_Rs_data
	.RTdata_o(ID_EX_Rt_data) // ID_EX_Rt_data
		);

Decoder Control(
	.instr_op_i(IF_ID_reg[31:26]), // opcode
	.WB_o(WB), // WB
	.MemRead_o(MemRead), // MemRead
	.MemWrite_o(MemWrite), // MemWrite
	.MemtoReg_o(MemtoReg), // MemtoReg
	.ALU_op_o(ALUop), // ALUop
	.ALUSrc_o(ALUSrc), // ALUSrc
	.RegDst_o(RegDst) // RegDst
		);

Sign_Extend Sign_Extend(
	.data_i(IF_ID_reg[15:0]), // imm
	.data_o(sign_imm) // sign_imm
		);	

Pipe_Reg #(.size(126)) ID_EX(
	.rst_i(rst_i),
	.clk_i(clk_i),
	// ID_EX_reg = WB + M + EX + ID/EX_Rs_data + ID/EX_Rt_data + sign_imm + IF_ID_Rs + IF_ID_Rt + IF_ID_Rd
	.data_i({WB, MemRead, MemWrite, MemtoReg, ALUop, ALUSrc, RegDst, IF_ID_reg[5:0]
				, ID_EX_Rs_data, ID_EX_Rt_data, sign_imm, IF_ID_reg[25:11]}),
	.data_o(ID_EX_reg)
		);
		
//Instantiate the components in EX stage	   
ForwardinUnit FU(
	.EX_MEMRegWrite(EX_MEM_reg[72]), // EX/MEM_WB
	.MEM_WBRegWrite(MEM_WB_reg[70]), // MEM/WB_WB
	.EX_MEMRegisterRd(EX_MEM_reg[4:0]), // EX/MEM_Rd
	.MEM_WBRegisterRd(MEM_WB_reg[4:0]), // MEM/WB_Rd
	.ID_EXRegisterRs(ID_EX_reg[14:10]), // ID/EX_Rs
	.ID_EXRegisterRt(ID_EX_reg[9:5]), // ID/EX_Rt
	.ForwardA(ForwardA), // ForwardA (Rs)
	.ForwardB(ForwardB) // ForwardB (Rt)	
);

ALU ALU(
	.src1_i(src1),
	.src2_i(src2),
	.ctrl_i(ALUCtrl),
	.result_o(result)
		);
		
ALU_Ctrl ALU_Control(
	.funct_i(ID_EX_reg[116:111]), // funct
	.ALUop_i(ID_EX_reg[121:119]), // ALUop
	.ALUCtrl_o(ALUCtrl) // ALUCtrl
		);

MUX_2to1 #(.size(5)) Mux_Write_Reg( // choose rt or rd be written
	.data0_i(ID_EX_reg[9:5]), // rt addr
	.data1_i(ID_EX_reg[4:0]), // rd addr
	.select_i(ID_EX_reg[117]), // RegDst
	.data_o(RDaddr)
);

MUX_2to1 #(.size(32)) Mux_ALUSrc( // choose rt or sign_imm be ALUed
	.data0_i(ID_EX_reg[78:47]), // rt data
	.data1_i(ID_EX_reg[46:15]), // sign_imm
	.select_i(ID_EX_reg[118]), // ALUSrc
	.data_o(EX_Rt_Data)
);

MUX_3to1 #(.size(32)) Mux1( // choose ID/EX_Rs_data, result, mem_result as src1
	.data0_i(EX_MEM_reg[68:37]), // EX_MEM_result
	.data1_i(MEM_WB_Rd_data), // MEM_WB_result
	.data2_i(ID_EX_reg[110:79]), // ID/EX_Rs_data
	.select_i(ForwardA),
	.data_o(src1)
        );
		
MUX_3to1 #(.size(32)) Mux2( // choose ID/EX_Rt_data, result, mem_result as src2
	.data0_i(EX_MEM_reg[68:37]), // ALU result
	.data1_i(MEM_WB_Rd_data), // Memory access result
	.data2_i(EX_Rt_Data), // EX_Rt_data
	.select_i(ForwardB),
	.data_o(src2)
        );

Pipe_Reg #(.size(73)) EX_MEM(
	.rst_i(rst_i),
	.clk_i(clk_i),
	// EX_MEM_reg = WB + M + result + src2 + EX_MEM_Rd
	.data_i({ID_EX_reg[125:122],result,ID_EX_reg[78:47],RDaddr}),
	.data_o(EX_MEM_reg)
		);
			   
//Instantiate the components in MEM stage
Data_Memory DM(
	.clk_i(clk_i),
	.rst_i(rst_i),
	.addr_i(EX_MEM_reg[68:37]), // result
	.data_i(EX_MEM_reg[36:5]), // src2
	.MemRead_i(EX_MEM_reg[71]), // MemRead
	.MemWrite_i(EX_MEM_reg[70]), // MemWrite
	.data_o(MEM_data)
	    );

Pipe_Reg #(.size(71)) MEM_WB(
    .rst_i(rst_i),
	.clk_i(clk_i),
	// MEM_WB_reg = WB + MemtoReg + MEM_data + result + MEM_WB_Rd
	.data_i({EX_MEM_reg[72],EX_MEM_reg[69],MEM_data,EX_MEM_reg[68:37],EX_MEM_reg[4:0]}),
	.data_o(MEM_WB_reg)
		);

//Instantiate the components in WB stage
MUX_2to1 #(.size(32)) Mux_Write_Back( // choose MEM_data or ALU result to write back
	.data0_i(MEM_WB_reg[36:5]), // ALU result
	.data1_i(MEM_WB_reg[68:37]), // MEM_data
	.select_i(MEM_WB_reg[69]), // MemtoReg
	.data_o(MEM_WB_Rd_data)
        );

/****************************************
*         Signal assignment             *
****************************************/
	
endmodule

