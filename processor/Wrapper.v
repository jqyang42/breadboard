`timescale 1ns / 1ps
/**
 * 
 * READ THIS DESCRIPTION:
 *
 * This is the Wrapper module that will serve as the header file combining your processor, 
 * RegFile and Memory elements together.
 *
 * This file will be used to generate the bitstream to upload to the FPGA.
 * We have provided a sibling file, Wrapper_tb.v so that you can test your processor's functionality.
 * 
 * We will be using our own separate Wrapper_tb.v to test your code. You are allowed to make changes to the Wrapper files 
 * for your own individual testing, but we expect your final processor.v and memory modules to work with the 
 * provided Wrapper interface.
 * 
 * Refer to Lab 5 documents for detailed instructions on how to interface 
 * with the memory elements. Each imem and dmem modules will take 12-bit 
 * addresses and will allow for storing of 32-bit values at each address. 
 * Each memory module should receive a single clock. At which edges, is 
 * purely a design choice (and thereby up to you). 
 * 
 * You must change line 36 to add the memory file of the test you created using the assembler
 * For example, you would add sample inside of the quotes on line 38 after assembling sample.s
 *
 **/


// output: ball x, y, winner
// input: paddles' bounds, ball limits, and winning segment y - val



// clock, reset, posEdgeScreenEnd, winner, ball_x, ball_y, ball_xinit, ball_yinit,
// 				ball_xdir_factor, ball_ydir_factor,
// 				ball_xlim, ball_ylim, segLeft_topBound, segLeft_bottomBound, 
// 				segRight_topBound, segRight_bottomBound

module Wrapper (clock, reset, screenEnd, ball_x, ball_y, ball_xinit, ball_yinit);


	// input clock, reset, posEdgeScreenEnd;
	// input [9:0] ball_xlim, ball_xinit;
	// input [8:0] ball_ylim, segLeft_topBound, segLeft_bottomBound, segRight_topBound, segRight_bottomBound,  ball_yinit;
	// input [31:0] ball_xdir_factor, ball_ydir_factor;
	// output[1:0] winner;
	// output[9:0] ball_x;
	// output [8:0] ball_y;

	input clock, reset, screenEnd;
	input [31:0] ball_xinit;
	input [31:0] ball_yinit;
	output[31:0] ball_x;
	output [31:0] ball_y;

	wire rwe, mwe;
	wire[4:0] rd, rs1, rs2;
	wire[31:0] instAddr, instData, 
		rData, regA, regB,
		memAddr, memDataIn, memDataOut;


	// ADD YOUR MEMORY FILE HERE
	localparam INSTR_FILE = "logic_basic";
	
	// Main Processing Unit
	processor CPU(.clock(clock), .reset(reset), 
								
		// ROM
		.address_imem(instAddr), .q_imem(instData),
									
		// Regfile
		.ctrl_writeEnable(rwe),     .ctrl_writeReg(rd),
		.ctrl_readRegA(rs1),     .ctrl_readRegB(rs2), 
		.data_writeReg(rData), .data_readRegA(regA), .data_readRegB(regB),
									
		// RAM
		.wren(mwe), .address_dmem(memAddr), 
		.data(memDataIn), .q_dmem(memDataOut)); 
	
	// Instruction Memory (ROM)
	ROM #(.MEMFILE({INSTR_FILE, ".mem"}))
	InstMem(.clk(clock), 
		.addr(instAddr[11:0]), 
		.dataOut(instData));
	
	// Register File
	// regfile RegisterFile(.clock(clock), 
	// 	.ctrl_writeEnable(rwe), .ctrl_reset(reset), 
	// 	.ctrl_writeReg(rd),
	// 	.ctrl_readRegA(rs1), .ctrl_readRegB(rs2), 
	// 	.data_writeReg(rData), .data_readRegA(regA), .data_readRegB(regB), .posEdgeScreenEnd(posEdgeScreenEnd),
	// 	.winner(winner), .ball_x(ball_x), .ball_y(ball_y), .ball_xinit(ball_xinit), .ball_yinit(ball_yinit),
	// 	.ball_xdir_factor(ball_xdir_factor), .ball_ydir_factor(ball_ydir_factor),
	// 	.ball_xlim(ball_xlim), .ball_ylim(ball_ylim), .segLeft_topBound(segLeft_topBound), .segLeft_bottomBound(segLeft_bottomBound), 
	// 	.segRight_topBound(segRight_topBound), .segRight_bottomBound(segRight_bottomBound));

	regfile_basic RegisterFile(.clock(clock), 
		.ctrl_writeEnable(rwe), .ctrl_reset(reset), 
		.ctrl_writeReg(rd),
		.ctrl_readRegA(rs1), .ctrl_readRegB(rs2), 
		.data_writeReg(rData), .data_readRegA(regA), .data_readRegB(regB),
		.screenEnd(screendEnd), .ball_x(ball_x), .ball_y(ball_y), 
		.ball_xinit(ball_xinit), .ball_yinit(ball_yinit));
						
	// Processor Memory (RAM)
	RAM ProcMem(.clk(clock), 
		.wEn(mwe), 
		.addr(memAddr[11:0]), 
		.dataIn(memDataIn), 
		.dataOut(memDataOut));

endmodule
