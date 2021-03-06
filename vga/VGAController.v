`timescale 1 ns/ 100 ps
module VGAController(     
	input clk, 			// 100 MHz System Clock
	input reset, 		// Reset Signal
	output hSync, 		// H Sync Signal
	output vSync, 		// Veritcal Sync Signal
	output[3:0] VGA_R,  // Red Signal Bits
	output[3:0] VGA_G,  // Green Signal Bits
	output[3:0] VGA_B,  // Blue Signal Bits
	inout ps2_clk,
	inout ps2_data,
	input p1_up,
	input p1_down,
	input p1_left,
	input p1_right,
	input p2_up,
	input p2_down,
	input p2_left,
	input p2_right,
	output [6:0] cathodes,
	output reg [7:0] anodes,
	output ball_inSq, 
	output active_on,
	output screenEnd_on);

	// Lab Memory Files Location
	// localparam FILES_PATH = "//tsclient/ECE350/breadboard/vga/"; 
	localparam FILES_PATH = "C:/Users/Jessica Yang/Documents/ece350/breadboard/vga/";
	

	// Clock divider 100 MHz -> 25 MHz
	wire clk25; // 25MHz clock

	reg[1:0] pixCounter = 0;      // Pixel counter to divide the clock
    assign clk25 = pixCounter[1]; // Set the clock high whenever the second bit (2) is high
	always @(posedge clk) begin
		pixCounter <= pixCounter + 1; // Since the reg is only 3 bits, it will reset every 8 cycles
	end
	
	reg [2:0] clk_seg;  // 1 KHz	
	reg[31:0] clk25_counter = 0;
	always @(posedge clk25) begin
	   if (clk25_counter == 31'd25000) begin
			if (clk_seg == 3'd7)
				clk_seg <= 0;
			else
	    		clk_seg <= clk_seg + 1;
	       clk25_counter <= 0;
	   end
	   else
	       clk25_counter <= clk25_counter + 1;
	end

	// VGA Timing Generation for a Standard VGA Screen
	localparam 
		VIDEO_WIDTH = 640,  // Standard VGA Width
		VIDEO_HEIGHT = 480; // Standard VGA Height

	
	wire active, screenEnd;
	wire[31:0] ball_x, ball_y;
	assign active_on = ball_x == 32'd330;
	assign screenEnd_on = ball_y == 32'd250;
	wire[9:0] x;
	wire[8:0] y;

	// p1 paddle creation
	reg[9:0] p1_xRef = 80;
	reg[8:0] p1_yRef = 240;

	wire[9:0] p1_leftBound, p1_rightBound;
	wire[8:0] p1_topBound, p1_bottomBound;
	reg p1_inSquare = 0;
	assign p1_leftBound = p1_xRef - 25;
	assign p1_rightBound = p1_xRef + 25;
	assign p1_topBound = p1_yRef - 33;
	assign p1_bottomBound = p1_yRef + 33;

	always @(x or y) begin
		if (x > p1_leftBound && x < p1_rightBound && y > p1_topBound && y < p1_bottomBound)
			p1_inSquare <= 1'b1;
		else
			p1_inSquare <= 1'b0;
	end
	
	// p2 paddle creation
	reg[9:0] p2_xRef = 560;
	reg[8:0] p2_yRef = 240;

	wire[9:0] p2_leftBound, p2_rightBound;
	wire[8:0] p2_topBound, p2_bottomBound;
	reg p2_inSquare = 0;
	assign p2_leftBound = p2_xRef - 25;
	assign p2_rightBound = p2_xRef + 25;
	assign p2_topBound = p2_yRef - 33;
	assign p2_bottomBound = p2_yRef + 33;

	always @(x or y) begin
		if (x > p2_leftBound && x < p2_rightBound && y > p2_topBound && y < p2_bottomBound)
			p2_inSquare <= 1'b1;
		else
			p2_inSquare <= 1'b0;
	end

	// ball creation
	wire[31:0] ball_xlim, ball_xinit, ball_xmin;
	wire[31:0] ball_ylim, ball_yinit, ball_ymin;
	wire[9:0] ball_radius, ball_radius_sqr;

	assign ball_xmin = 32'd12;
	assign ball_ymin = 32'd17;
	assign ball_xlim = 32'd628;
	assign ball_ylim = 32'd463;
	assign ball_xinit = 32'd320;
	assign ball_yinit = 32'd240;

	wire[9:0] ball_leftBound, ball_rightBound;
	wire[8:0] ball_topBound, ball_bottomBound;
	reg ball_inHitBox = 0;
	
    reg[31:0] ball_xRef;
	reg[31:0] ball_yRef;
	reg[31:0] ball_xdir, ball_ydir;
	reg[31:0] ball_xdir_factor, ball_ydir_factor;
// WINNER STATS
	reg[13:0] p1_score, p2_score; //winner of round (player 1 v. 2; can change to increment score later)


	initial begin
		ball_xRef = 0;
		ball_yRef = 0;
		ball_xdir = 1;
		ball_ydir = 1;
		ball_xdir_factor = 1;
		ball_ydir_factor = 1;
		p1_score = 0;
		p2_score = 0;
	end
	
	assign ball_leftBound = ball_xRef - 10;
	assign ball_rightBound = ball_xRef + 10;
	assign ball_topBound = ball_yRef - 15;
	assign ball_bottomBound = ball_yRef + 15;


	reg[31:0] ball_x_term;
	reg[31:0] ball_y_term;
	reg[31:0] ball_total_pos_term;

	// ball disply calculation
	always @(x or y) begin
		ball_x_term <= (x - ball_xRef) * (x - ball_xRef);
		ball_y_term <= (y - ball_yRef) * (y - ball_yRef);
		ball_total_pos_term <= (ball_x_term * 225) + (ball_y_term * 100);
		if (ball_total_pos_term < 22500)
			ball_inHitBox <= 1'b1;
		else
			ball_inHitBox <= 1'b0;
	end

	// segment win creation
	reg[9:0] segLeft_xRef = 2;
	reg[8:0] segLeft_yRef = 240;
	
	wire[9:0] segLeft_leftBound, segLeft_rightBound;
	wire[8:0] segLeft_topBound, segLeft_bottomBound;
	reg segLeft_inSquare = 0;
	assign segLeft_leftBound = segLeft_xRef - 2;
	assign segLeft_rightBound = segLeft_xRef + 2;
	assign segLeft_topBound = segLeft_yRef - 60;
	assign segLeft_bottomBound = segLeft_yRef + 60;

	always @(x or y) begin
		if (x > segLeft_leftBound && x < segLeft_rightBound && y > segLeft_topBound && y < segLeft_bottomBound)
			segLeft_inSquare <= 1'b1;
		else
			segLeft_inSquare <= 1'b0;
	end

	// segment win creation
	reg[9:0] segRight_xRef = 638;
	reg[8:0] segRight_yRef = 240;
	
	wire[9:0] segRight_leftBound, segRight_rightBound;
	wire[8:0] segRight_topBound, segRight_bottomBound;
	reg segRight_inSquare = 0;
	assign segRight_leftBound = segRight_xRef - 2;
	assign segRight_rightBound = segRight_xRef + 2;
	assign segRight_topBound = segRight_yRef - 60;
	assign segRight_bottomBound = segRight_yRef + 60;

	always @(x or y) begin
		if (x > segRight_leftBound && x < segRight_rightBound && y > segRight_topBound && y < segRight_bottomBound)
			segRight_inSquare <= 1'b1;
		else
			segRight_inSquare <= 1'b0;
	end

	// p1 and p2 movement logic
	wire[9:0] screenMiddle, p1_xBound;
	assign screenMiddle = VIDEO_WIDTH/2.0;
	assign p1_xBound = screenMiddle - 50;
	assign p2_xBound = 370;

	reg ball_inSq = 0;
	reg [13:0] p1_prevScore, p2_prevScore;
    
	// ball collisions
	always @(posedge screenEnd) begin
		ball_xRef <= ball_x;
		ball_yRef <= ball_y;

		p1_prevScore <= p1_score;
		p2_prevScore <= p2_score;

		// BALL DIRECTIONALITY WITH WALLS
		//right wall
		if(ball_xRef+10 >= ball_xlim) begin
			if(ball_yRef-10 < segRight_bottomBound && ball_yRef+10 > segRight_topBound) begin
				p1_score <= p1_prevScore + 1;
			end
			ball_xdir <= -1;
			ball_inSq <= 1;
		end
		else if(ball_xRef-10 <= ball_xmin) begin
			if(ball_yRef-10 < segLeft_bottomBound && ball_yRef+10 > segLeft_topBound) begin
				p2_score <= p2_prevScore + 1;
			end
			ball_xdir <= 1;
			ball_inSq <= 1;
		end
		if(ball_yRef - 15 <= ball_ymin) begin
			ball_ydir <= 1;
			ball_inSq <= 1;
		end
		else if(ball_yRef+15 >= ball_ylim) begin
			ball_ydir <= -1;
			ball_inSq <= 1;
		end
		
		//BALL DIRECTIONALITY WITH PADDLE INFO
		// PLAYER 1 COLLISIONS
		if(ball_xRef+10 >= p1_xRef-25 && ball_xRef-10 < p1_xRef-25) begin
			if(ball_yRef-15 < p1_yRef-33 && p1_yRef < ball_yRef+15) begin
				ball_xdir <= -1;
				ball_inSq <= 1;
			end else if(p1_yRef+33 < ball_yRef+15 && ball_yRef < p1_yRef+33) begin
				ball_xdir <= -1;
				ball_inSq <= 1;
			end else if(ball_yRef-15 >= p1_yRef-33 && p1_yRef+33 >= ball_yRef+15) begin
				ball_xdir <= -1;
				ball_inSq <= 1;
			end
		end else if(p1_xRef+25 >= ball_xRef-10 && p1_xRef+25 < ball_xRef+10) begin
			if(ball_yRef-15 < p1_yRef-33 && p1_yRef < ball_yRef+15) begin
				ball_xdir <= 1;
				ball_inSq <= 1;
			end else if(p1_yRef+33 < ball_yRef+15 && ball_yRef < p1_yRef+33) begin
				ball_xdir <= 1;
				ball_inSq <= 1;
			end else if(ball_yRef-15 >= p1_yRef-33 && p1_yRef+33 >= ball_yRef+15) begin
				ball_xdir <= 1;
				ball_inSq <= 1;
			end
		end else if(ball_yRef+15 >= p1_yRef-33 && ball_yRef-15 < p1_yRef-33) begin
			if(p1_xRef-25 < ball_xRef+10 && ball_xRef-10 < p1_xRef-25) begin
				ball_ydir <= -1;
				ball_inSq <= 1;
			end else if(ball_xRef-10 < p1_xRef+33 && p1_xRef+33 < ball_xRef+10) begin
				ball_ydir <= -1;
				ball_inSq <= 1;
			end else if(ball_xRef-10 >= p1_xRef-33 && p1_xRef+33 >= ball_xRef+10) begin
				ball_ydir <= -1;
				ball_inSq <= 1;
			end
		end else if(p1_yRef+33 >= ball_yRef-15 && p1_yRef+33 < ball_yRef+15) begin
			if(p1_xRef-25 < ball_xRef+10 && ball_xRef-10 < p1_xRef-25) begin
				ball_ydir <= 1;
				ball_inSq <= 1;
			end else if(ball_xRef-10 < p1_xRef+33 && p1_xRef+33 < ball_xRef+10) begin
				ball_ydir <= 1;
				ball_inSq <= 1;
			end else if(ball_xRef-10 >= p1_xRef-33 && p1_xRef+33 >= ball_xRef+10) begin
				ball_ydir <= 1;
				ball_inSq <= 1;
			end
		end

		// PLAYER 2 COLLISIONS
		else if(ball_xRef+10 >= p2_xRef-25 && ball_xRef-10 < p2_xRef-25) begin
			if(ball_yRef-15 < p2_yRef-33 && p2_yRef < ball_yRef+15) begin
				ball_xdir <= -1;
				ball_inSq <= 1;
			end else if(p2_yRef+33 < ball_yRef+15 && ball_yRef < p2_yRef+33) begin
				ball_xdir <= -1;
				ball_inSq <= 1;
			end else if(ball_yRef-15 >= p2_yRef-33 && p2_yRef+33 >= ball_yRef+15) begin
				ball_xdir <= -1;
				ball_inSq <= 1;
			end
		end else if(p2_xRef+25 >= ball_xRef-10 && p2_xRef+25 < ball_xRef+10) begin
			if(ball_yRef-15 < p2_yRef-33 && p2_yRef < ball_yRef+15) begin
				ball_xdir <= 1;
				ball_inSq <= 1;
			end else if(p2_yRef+33 < ball_yRef+15 && ball_yRef < p2_yRef+33) begin
				ball_xdir <= 1;
				ball_inSq <= 1;
			end else if(ball_yRef-15 >= p2_yRef-33 && p2_yRef+33 >= ball_yRef+15) begin
				ball_xdir <= 1;
				ball_inSq <= 1;
			end
		end else if(ball_yRef+15 >= p2_yRef-33 && ball_yRef-15 < p2_yRef-33) begin
			if(p2_xRef-25 < ball_xRef+10 && ball_xRef-10 < p2_xRef-25) begin
				ball_ydir <= -1;
				ball_inSq <= 1;
			end else if(ball_xRef-10 < p2_xRef+33 && p2_xRef+33 < ball_xRef+10) begin
				ball_ydir <= -1;
				ball_inSq <= 1;
			end else if(ball_xRef-10 >= p2_xRef-33 && p2_xRef+33 >= ball_xRef+10) begin
				ball_ydir <= -1;
				ball_inSq <= 1;
			end
		end else if(p2_yRef+33 >= ball_yRef-15 && p2_yRef+33 < ball_yRef+15) begin
			if(p2_xRef-25 < ball_xRef+10 && ball_xRef-10 < p2_xRef-25) begin
				ball_ydir <= 1;
				ball_inSq <= 1;
			end else if(ball_xRef-10 < p2_xRef+33 && p2_xRef+33 < ball_xRef+10) begin
				ball_ydir <= 1;
				ball_inSq <= 1;
			end else if(ball_xRef-10 >= p2_xRef-33 && p2_xRef+33 >= ball_xRef+10) begin
				ball_ydir <= 1;
				ball_inSq <= 1;
			end
		end
		//NO CHANGE IN DIRECTION
		else begin
			ball_inSq <= 0;
		end

		//PADDLE MOVEMENT CALCULATION
		if(p1_xRef <= p1_xBound && p1_xRef > 25 ) begin
			if (p1_left)
				p1_xRef <= p1_xRef - 1;
			if (p1_right)
				p1_xRef <= p1_xRef + 1;
		end
		else begin
			p1_xRef <= (p1_xRef > p1_xBound) ? p1_xBound : 26;
		end
		if(p1_yRef > 33 && p1_yRef < (VIDEO_HEIGHT - 33)) begin
			if (p1_up)
				p1_yRef <= p1_yRef - 1;
			if (p1_down)
				p1_yRef <= p1_yRef + 1;
		end
		else begin
			p1_yRef <= (p1_yRef >= VIDEO_HEIGHT - 33) ? VIDEO_HEIGHT - 34 : 34;
		end
		if(p2_xRef >= 370 && p2_xRef < VIDEO_WIDTH-25) begin
			if (p2_left)
				p2_xRef <= p2_xRef - 1;
			if (p2_right)
				p2_xRef <= p2_xRef + 1;
		end
		else begin
			p2_xRef <= (p2_xRef < 370) ? 370 : VIDEO_WIDTH-26;
		end
		if(p2_yRef > 33 && p2_yRef < 447) begin
			if (p2_up)
				p2_yRef <= p2_yRef - 1;
			if (p2_down)
				p2_yRef <= p2_yRef + 1;
		end
		else begin
			p2_yRef <= (p2_yRef >= 447) ? 446 : 34;
		end
	end

	VGATimingGenerator #(
		.HEIGHT(VIDEO_HEIGHT), // Use the standard VGA Values
		.WIDTH(VIDEO_WIDTH))
	Display( 
		.clk25(clk25),  	   // 25MHz Pixel Clock
		.reset(reset),		   // Reset Signal
		.screenEnd(screenEnd), // High for one cycle when between two frames
		.active(active),	   // High when drawing pixels
		.hSync(hSync),  	   // Set Generated H Signal
		.vSync(vSync),		   // Set Generated V Signal
		.x(x), 				   // X Coordinate (from left)
		.y(y)); 			   // Y Coordinate (from top)	   

	// Image Data to Map Pixel Location to Color Address
	localparam 
		PIXEL_COUNT = VIDEO_WIDTH*VIDEO_HEIGHT, 	             // Number of pixels on the screen
		PIXEL_ADDRESS_WIDTH = $clog2(PIXEL_COUNT) + 1,           // Use built in log2 command
		BITS_PER_COLOR = 12, 	  								 // Nexys A7 uses 12 bits/color
		PALETTE_COLOR_COUNT = 256, 								 // Number of Colors available
		PALETTE_ADDRESS_WIDTH = $clog2(PALETTE_COLOR_COUNT) + 1; // Use built in log2 Command

	wire[PIXEL_ADDRESS_WIDTH-1:0] imgAddress;  	 // Image address for the image data
	wire[PALETTE_ADDRESS_WIDTH-1:0] colorAddr; 	 // Color address for the color palette
	assign imgAddress = x + 640*y;				 // Address calculated coordinate

	RAM #(		
		.DEPTH(PIXEL_COUNT), 				     // Set RAM depth to contain every pixel
		.DATA_WIDTH(PALETTE_ADDRESS_WIDTH),      // Set data width according to the color palette
		.ADDRESS_WIDTH(PIXEL_ADDRESS_WIDTH),     // Set address with according to the pixel count
		.MEMFILE({FILES_PATH, "image.mem"})) // Memory initialization
	ImageData(
		.clk(clk), 						 // Falling edge of the 100 MHz clk
		.addr(imgAddress),					 // Image data address
		.dataOut(colorAddr),				 // Color palette address
		.wEn(1'b0)); 						 // We're always reading

	// Color Palette to Map Color Address to 12-Bit Color
	wire[BITS_PER_COLOR-1:0] colorData; // 12-bit color data at current pixel

	RAM #(
		.DEPTH(PALETTE_COLOR_COUNT), 		       // Set depth to contain every color		
		.DATA_WIDTH(BITS_PER_COLOR), 		       // Set data width according to the bits per color
		.ADDRESS_WIDTH(PALETTE_ADDRESS_WIDTH),     // Set address width according to the color count
		.MEMFILE({FILES_PATH, "colors.mem"}))  // Memory initialization
	ColorPalette(
		.clk(clk), 							   	   // Rising edge of the 100 MHz clk
		.addr(colorAddr),					       // Address from the ImageData RAM
		.dataOut(colorData),				       // Color at current pixel
		.wEn(1'b0)); 						       // We're always reading
	

	// Assign to output color from register if active
	wire[BITS_PER_COLOR-1:0] colorOut; 			  // Output color
	 
	assign colorOut= active ? ((p1_inSquare || p2_inSquare || ball_inHitBox || segLeft_inSquare || segRight_inSquare) ? 12'd24 : colorData) : 12'd0; // When not active, output black

	// Quickly assign the output colors to their channels using concatenation
	assign {VGA_R, VGA_G, VGA_B} = colorOut;

	// // Processor wrapper module
	// output: ball x, y, winner
	// input: paddles' bounds, ball limits, and winning segment y - val, initial ball x, y

	// Wrapper proc(clk25, reset, screenEnd, winner, ball_x, ball_y, ball_xinit, ball_yinit,
	// 			ball_xdir_factor, ball_ydir_factor,
	// 			ball_xlim, ball_ylim, segLeft_topBound, segLeft_bottomBound, 
	// 			segRight_topBound, segRight_bottomBound);
	// wire write_en_stall;
	// assign write_en_stall = screenEnd && ;
	Wrapper proc(clk25, reset, screenEnd, ball_x, ball_y, ball_xdir, ball_ydir);
	
	always @(clk_seg) begin
        case(clk_seg)    // 0 - 3 = player 1
            3'd0: anodes = 8'b01111111;
            3'd1: anodes = 8'b10111111;
            3'd2: anodes = 8'b11011111;
            3'd3: anodes = 8'b11101111;
            3'd4: anodes = 8'b11110111;
            3'd5: anodes = 8'b11111011;
            3'd6: anodes = 8'b11111101;
            3'd7: anodes = 8'b11111110;
        endcase
    end

	reg [3:0] digit;
	always @(clk_seg) begin
        case(clk_seg)    // ABCDEFG
            4'd0: digit = p1_score % 10;
            4'd1: digit = ((p1_score % 100) - (p1_score % 10)) / 10;
            4'd2: digit = ((p1_score % 1000) - (p1_score % 100)) / 100;
            4'd3: digit = (p1_score - (p1_score % 1000)) / 1000;
            4'd4: digit = p2_score % 10;
            4'd5: digit = ((p2_score % 100) - (p2_score % 10)) / 10;
            4'd6: digit = ((p2_score % 1000) - (p2_score % 100)) / 100;
            4'd7: digit = (p2_score - (p2_score % 1000)) / 1000;
        endcase
    end
    // assign anodes = clk_seg ? 8'b11101111 : 8'b11111110; 
    // wire[2:0] score = clk_seg ? p1_score : p2_score;
    new_segment_decoder seg_number(.number(digit), .cathodes(cathodes));
endmodule