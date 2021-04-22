`timescale 1ns / 1ps
/**
 * 
 * READ THIS DESCRIPTION:
 *
 * This is the Wrapper module that will serve as the header file combining your processor, 
 * RegFile and Memory elements together.
 *
 * This file will be used to test your processor for functionality.
 * We have provided a sibling file, Wrapper_tb.v so that you can test your processor's functionality.
 * 
 * We will be using our own separate Wrapper_tb.v to test your code. 
 * You are allowed to make changes to the Wrapper files 
 * for your own individual testing, but we expect your final processor.v 
 * and memory modules to work with the Wrapper interface as provided.
 * 
 * Refer to Lab 5 documents for detailed instructions on how to interface 
 * with the memory elements. Each imem and dmem modules will take 12-bit 
 * addresses and will allow for storing of 32-bit values at each address. 
 * Each memory module should receive a single clock. At which edges, is 
 * purely a design choice (and thereby up to you). 
 * 
 * You must set the parameter when compiling to use the memory file of 
 * the test you created using the assembler and load the appropriate 
 * verification file.
 *
 * For example, you would add sample as your parameter after assembling sample.s
 * using the command
 *
 * 	 iverilog -o proc -c processor.txt -s Wrapper_tb -P Wrapper_tb.FILE=\"sample\"
 *
 * Note the backslashes (\) preceding the quotes. These are required.
 *
 **/

module Wrapper_tb #(parameter FILE = "control");

	// FileData
	localparam DIR = "Test Files/";
	localparam MEM_DIR = "Memory Files/";
	localparam OUT_DIR = "Output Files/";
	localparam VERIF_DIR = "Verification Files/";
	localparam DEFAULT_CYCLES = 255;

	// Inputs to the processor
	reg clock = 0, reset = 0, screenEnd = 0;

	// I/O for the processor
	wire rwe, mwe;
	wire[4:0] rd, rs1, rs2;
	wire[31:0] instAddr, instData, 
		rData, regA, regB,
		memAddr, memDataIn, memDataOut;

	// Wires for Test Harness
	wire[4:0] rs1_test, rs1_in;
	reg testMode = 0; 
	reg[7:0] num_cycles = DEFAULT_CYCLES;
	reg[15*8:0] exp_text;
	reg null;

	// Connect the reg to test to the for loop
	assign rs1_test = reg_to_test;

	// Hijack the RS1 value for testing
	assign rs1_in = testMode ? rs1_test : rs1;

	// Expected Value from File
	reg signed [31:0] exp_result;

	// Where to store file error codes
	integer expFile, diffFile, actFile, expScan; 

	// Do Verification
	reg verify = 1;

	// Metadata
	integer errors = 0,
			cycles = 0,
			reg_to_test = 0;

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
	ROM #(.MEMFILE({DIR, MEM_DIR, FILE, ".mem"}))
	InstMem(.clk(clock), 
		.addr(instAddr[11:0]), 
		.dataOut(instData));
	
	// Register File
	// regfile RegisterFile(.clock(clock), 
	// 	.ctrl_writeEnable(rwe), .ctrl_reset(reset), 
	// 	.ctrl_writeReg(rd),
	// 	.ctrl_readRegA(rs1_in), .ctrl_readRegB(rs2), 
	// 	.data_writeReg(rData), .data_readRegA(regA), .data_readRegB(regB));
	
	reg[9:0] p1_xRef = 32'd80;
	reg[8:0] p1_yRef = 32'd240;
	reg[9:0] p2_xRef = 32'd560;
	reg[8:0] p2_yRef = 32'd240;
	
	wire[9:0] p1_leftBound, p1_rightBound;
	wire[8:0] p1_topBound, p1_bottomBound;
	reg p1_inSquare = 1'b0;
	assign p1_leftBound = p1_xRef - 25;
	assign p1_rightBound = p1_xRef + 25;
	assign p1_topBound = p1_yRef - 33;
	assign p1_bottomBound = p1_yRef + 33;

	wire[9:0] p2_leftBound, p2_rightBound;
	wire[8:0] p2_topBound, p2_bottomBound;
	reg p2_inSquare = 0;
	assign p2_leftBound = p2_xRef - 25;
	assign p2_rightBound = p2_xRef + 25;
	assign p2_topBound = p2_yRef - 33;
	assign p2_bottomBound = p2_yRef + 33;

	wire[9:0] ball_xRef, ball_x, ball_xlim, ball_xinit;
	wire[8:0] ball_yRef, ball_y, ball_ylim, ball_yinit;

	assign ball_xinit = 10'd320;
	assign ball_yinit = 9'd240;
	assign ball_xlim = 10'd628;
	assign ball_ylim = 9'd463;
		
	reg[9:0] segLeft_xRef = 10'd2;
	reg[8:0] segLeft_yRef = 9'd240;

	wire[9:0] segLeft_leftBound, segLeft_rightBound;
	wire[8:0] segLeft_topBound, segLeft_bottomBound;
	assign segLeft_leftBound = segLeft_xRef - 2;
	assign segLeft_rightBound = segLeft_xRef + 2;
	assign segLeft_topBound = segLeft_yRef - 40;
	assign segLeft_bottomBound = segLeft_yRef + 40;

	reg[9:0] segRight_xRef = 10'd638;
	reg[8:0] segRight_yRef = 9'd240;

	wire[9:0] segRight_leftBound, segRight_rightBound;
	wire[8:0] segRight_topBound, segRight_bottomBound;
	assign segRight_leftBound = segRight_xRef - 2;
	assign segRight_rightBound = segRight_xRef + 2;
	assign segRight_topBound = segRight_yRef - 40;
	assign segRight_bottomBound = segRight_yRef + 40;

	wire[2:0] winner;

	regfile RegisterFile(.clock(clock), 
	.ctrl_writeEnable(rwe), .ctrl_reset(reset), 
	.ctrl_writeReg(rd),
	.ctrl_readRegA(rs1), .ctrl_readRegB(rs2), 
	.data_writeReg(rData), .data_readRegA(regA), .data_readRegB(regB), .posEdgeScreenEnd(screenEnd),
	.winner(winner), .ball_x(ball_x), .ball_y(ball_y), .ball_xinit(ball_xinit), .ball_yinit(ball_yinit),
	.ball_xdir_factor(32'd1), .ball_ydir_factor(32'b11111111111111111111111111111111),
	.ball_xlim(ball_xlim), .ball_ylim(ball_ylim), .segLeft_topBound(segLeft_topBound), .segLeft_bottomBound(segLeft_bottomBound), 
	.segRight_topBound(segRight_topBound), .segRight_bottomBound(segRight_bottomBound));
						
	// Processor Memory (RAM)
	RAM ProcMem(.clk(clock), 
		.wEn(mwe), 
		.addr(memAddr[11:0]), 
		.dataIn(memDataIn), 
		.dataOut(memDataOut));

	// Create the clock
	always
		#5 clock = ~clock; 
	always 
		#50 screenEnd = ~screenEnd;

	//////////////////
	// Test Harness //
	//////////////////

	initial begin
		// Check if the parameter exists
		if(FILE == 0) begin
			$display("Please specify the test");
			$finish;
		end

		$display({"Loading ", FILE, ".mem\n"});

		// Read the expected file
		expFile = $fopen({DIR, VERIF_DIR, FILE, "_exp.txt"}, "r");

			// Check for any errors in opening the file
		if(!expFile) begin
			$display("Couldn't read the expected file.",
				"\nMake sure there is a %0s_exp.txt file in the \"%0s\" directory.", FILE, {DIR ,VERIF_DIR});
			$display("Continuing for %0d cycles without checking for correctness,\n", DEFAULT_CYCLES);
			verify = 0;
		end

		// Output file name
		$dumpfile({DIR, OUT_DIR, FILE, ".vcd"});
		// Module to capture and what level, 0 means all wires
		$dumpvars(0, Wrapper_tb);

		$display();

		// Create the files to store the output
		actFile = $fopen({DIR, OUT_DIR, FILE, "_actual.txt"},   "w");

		if (verify) begin
			diffFile = $fopen({DIR, OUT_DIR, FILE, "_diff.txt"},  "w");

			// Get the number of cycles from the file
			expScan = $fscanf(expFile, "num cycles:%d", 
				num_cycles);

			// Check that the number of cycles was read
			if(expScan != 1) begin
				$display("Error reading the %0s file.", {FILE, "_exp.txt"});
				$display("Make sure that file starts with \n\tnum cycles:NUM_CYCLES");;
				$display("Where NUM_CYCLES is a positive integer\n");
			end
		end

		// Clear the Processor at the beginning
		reset = 1;
		#1
		reset = 0;

		// Run for the number of cycles specified 
		for (cycles = 0; cycles < num_cycles; cycles = cycles + 1) begin
			
			// Every rising edge, write to the actual file
			@(posedge clock);
			if (rwe && rd != 0) begin
				$fdisplay(actFile, "Cycle %3d: Wrote %0d into register %0d", cycles, rData, rd);
			end
		end

		$fdisplay(actFile, "============== Testing Mode ==============");

		if (verify)
			$display("\t================== Checking Registers ==================");

		// Activate the test harness
		testMode = 1;

		// Check the values in the regfile
		for (reg_to_test = 0; reg_to_test < 32; reg_to_test = reg_to_test + 1) begin
			
			if (verify) begin
				// Obtain the register value
				expScan =  $fscanf(expFile, "%s", exp_text);
				expScan = $sscanf(exp_text, "r%d=%d", null, exp_result);

				// Check for errors when reading
				if (expScan != 2) begin
					$display("Error reading value for register %0d.", reg_to_test);
					$display("Please make sure the value is in the format");
					$display("\tr%0d=EXPECTED_VALUE", reg_to_test);

					// Close the Files
					$fclose(expFile);
					$fclose(actFile);
					$fclose(diffFile);

					#100;
					$finish;
				end
			end 
			
			// Allow the regfile output value to stabilize
			#1;

			// Write the register value to the actual file
			$fdisplay(actFile, "Reg %2d: %11d", rs1_test, regA);
			
			// Compare the Values 
			if (verify) begin
				if (exp_result !== regA) begin
					$fdisplay(diffFile, "Reg: %2d Expected: %11d Actual: %11d",
						rs1_test, $signed(exp_result), $signed(regA));
					$display("\tFAILED Reg: %2d Expected: %11d Actual: %11d",
						rs1_test, $signed(exp_result), $signed(regA));
					errors = errors + 1;
				end else begin
					$display("\tPASSED Reg: %2d", rs1_test);
				end
			end
		end

		// Close the Files
		$fclose(expFile);
		$fclose(actFile);

		if (verify)
			$fclose(diffFile);

		// Display the tests and errors
		if (verify)
			$display("\nFinished %0d cycle%c with %0d error%c", cycles, "s"*(cycles != 1), errors, "s"*(errors != 1));
		else 
			$display("Finished %0d cycle%c", cycles, "s"*(cycles != 1));

		#100;
		$finish;
	end
endmodule
