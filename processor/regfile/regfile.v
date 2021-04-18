module regfile (
	clock,
	ctrl_writeEnable, ctrl_reset, ctrl_writeReg,
	ctrl_readRegA, ctrl_readRegB, data_writeReg,
	data_readRegA, data_readRegB, posEdgeScreenEnd,
	winner, ball_x, ball_y, ball_xinit, ball_yinit,
	p1_leftBound, p1_rightBound, p1_topBound, p1_bottomBound, 
	p2_leftBound, p2_rightBound, p2_topBound, p2_bottomBound,
	ball_xlim, ball_ylim, segLeft_topBound, segLeft_bottomBound, 
	segRight_topBound, segRight_bottomBound
);

	input clock, ctrl_writeEnable, ctrl_reset, posEdgeScreenEnd;
	input [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	input [31:0] data_writeReg;
	input [9:0] ball_xlim, ball_xinit, p1_leftBound, p1_rightBound, p2_leftBound, p2_rightBound;
	input [8:0] ball_ylim, ball_yinit, p1_topBound, p1_bottomBound, p2_topBound, p2_bottomBound,
				segLeft_topBound, segLeft_bottomBound, segRight_topBound, segRight_bottomBound;

	output [31:0] data_readRegA, data_readRegB;
	output [1:0] winner;
	output [9:0] ball_x;
	output [8:0] ball_y;

	wire [31:0] d_write, d_readA, d_readB;
	// add your code here
	decoder decode_write(.onehot(d_write), .shift(ctrl_writeReg));
	decoder decode_readA(.onehot(d_readA), .shift(ctrl_readRegA));
	decoder decode_readB(.onehot(d_readB), .shift(ctrl_readRegB));

	/* 
	# $r3 = stall logic for game loop (stall while $r6 !- 0)

	# INPUT (write into register)
	# $r5, $r6 = initial ball x, y
	# $r7, $r8 = left edge goal top ycoord, bottom ycoord
	# $r9, $r10 = right edge goal top ycoord, bottom ycoord
	# $r11, $r12 = ball xlim, ylim
	# $r13, $r14, $r15, $r16 = p1 paddle bounds
	# $r17, $r18, $r19, $r20 = p2 paddle bounds

	# OUTPUT (read from register)
	# $r21 = winner (0 none, 1 p1, 2 p2)
	# $r22, $r23 = ball x,y
	*/
	register_32 reg0(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(1'b0), .write_ctrl(d_write[0]), .oeA(d_readA[0]), .oeB(d_readB[0]), .clr(ctrl_reset), .in(data_writeReg));
	register_32 reg1(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(ctrl_writeEnable), .write_ctrl(d_write[1]), .oeA(d_readA[1]), .oeB(d_readB[1]), .clr(ctrl_reset), .in(data_writeReg));
	register_32 reg2(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(ctrl_writeEnable), .write_ctrl(d_write[2]), .oeA(d_readA[2]), .oeB(d_readB[2]), .clr(ctrl_reset), .in(data_writeReg));
	register_32 reg3(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(1'b1), .write_ctrl(1'b1), .oeA(d_readA[3]), .oeB(d_readB[3]), .clr(ctrl_reset), .in(posEdgeScreenEnd));
	register_32 reg4(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(ctrl_writeEnable), .write_ctrl(d_write[4]), .oeA(d_readA[4]), .oeB(d_readB[4]), .clr(ctrl_reset), .in(data_writeReg));
	register_32 reg5(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(1'b1), .write_ctrl(1'b1), .oeA(d_readA[5]), .oeB(d_readB[5]), .clr(ctrl_reset), .in(ball_xinit));
	register_32 reg6(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(1'b1), .write_ctrl(1'b1), .oeA(d_readA[6]), .oeB(d_readB[6]), .clr(ctrl_reset), .in(ball_yinit));
	register_32 reg7(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(1'b1), .write_ctrl(1'b1), .oeA(d_readA[7]), .oeB(d_readB[7]), .clr(ctrl_reset), .in(segLeft_topBound));
	register_32 reg8(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(1'b1), .write_ctrl(1'b1), .oeA(d_readA[8]), .oeB(d_readB[8]), .clr(ctrl_reset), .in(segLeft_bottomBound));
	register_32 reg9(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(1'b1), .write_ctrl(1'b1), .oeA(d_readA[9]), .oeB(d_readB[9]), .clr(ctrl_reset), .in(segRight_topBound));
	register_32 reg10(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(1'b1), .write_ctrl(1'b1), .oeA(d_readA[10]), .oeB(d_readB[10]), .clr(ctrl_reset), .in(segRight_bottomBound));
	register_32 reg11(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(1'b1), .write_ctrl(1'b1), .oeA(d_readA[11]), .oeB(d_readB[11]), .clr(ctrl_reset), .in(ball_xlim));
	register_32 reg12(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(1'b1), .write_ctrl(1'b1), .oeA(d_readA[12]), .oeB(d_readB[12]), .clr(ctrl_reset), .in(ball_ylim));
	register_32 reg13(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(1'b1), .write_ctrl(1'b1), .oeA(d_readA[13]), .oeB(d_readB[13]), .clr(ctrl_reset), .in(p1_topBound));
	register_32 reg14(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(1'b1), .write_ctrl(1'b1), .oeA(d_readA[14]), .oeB(d_readB[14]), .clr(ctrl_reset), .in(p1_bottomBound));
	register_32 reg15(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(1'b1), .write_ctrl(1'b1), .oeA(d_readA[15]), .oeB(d_readB[15]), .clr(ctrl_reset), .in(p1_leftBound));
	register_32 reg16(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(1'b1), .write_ctrl(1'b1), .oeA(d_readA[16]), .oeB(d_readB[16]), .clr(ctrl_reset), .in(p1_rightBound));
	register_32 reg17(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(1'b1), .write_ctrl(1'b1), .oeA(d_readA[17]), .oeB(d_readB[17]), .clr(ctrl_reset), .in(p2_topBound));
	register_32 reg18(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(1'b1), .write_ctrl(1'b1), .oeA(d_readA[18]), .oeB(d_readB[18]), .clr(ctrl_reset), .in(p2_bottomBound));
	register_32 reg19(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(1'b1), .write_ctrl(1'b1), .oeA(d_readA[19]), .oeB(d_readB[19]), .clr(ctrl_reset), .in(p2_leftBound));
	register_32 reg20(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(1'b1), .write_ctrl(1'b1), .oeA(d_readA[20]), .oeB(d_readB[20]), .clr(ctrl_reset), .in(p2_bottomBound));
	register_32 reg21(.outA(winner), .outB(winner), .clk(clock), .ie(ctrl_writeEnable), .write_ctrl(d_write[21]), .oeA(1'b1), .oeB(1'b1), .clr(ctrl_reset), .in(data_writeReg));
	register_32 reg22(.outA(ball_x), .outB(ball_x), .clk(clock), .ie(ctrl_writeEnable), .write_ctrl(d_write[22]), .oeA(1'b1), .oeB(1'b1), .clr(ctrl_reset), .in(data_writeReg));
	register_32 reg23(.outA(ball_y), .outB(ball_y), .clk(clock), .ie(ctrl_writeEnable), .write_ctrl(d_write[23]), .oeA(1'b1), .oeB(1'b1), .clr(ctrl_reset), .in(data_writeReg));
	register_32 reg24(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(ctrl_writeEnable), .write_ctrl(d_write[24]), .oeA(d_readA[24]), .oeB(d_readB[24]), .clr(ctrl_reset), .in(data_writeReg));
	register_32 reg25(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(ctrl_writeEnable), .write_ctrl(d_write[25]), .oeA(d_readA[25]), .oeB(d_readB[25]), .clr(ctrl_reset), .in(data_writeReg));
	register_32 reg26(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(ctrl_writeEnable), .write_ctrl(d_write[26]), .oeA(d_readA[26]), .oeB(d_readB[26]), .clr(ctrl_reset), .in(data_writeReg));
	register_32 reg27(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(ctrl_writeEnable), .write_ctrl(d_write[27]), .oeA(d_readA[27]), .oeB(d_readB[27]), .clr(ctrl_reset), .in(data_writeReg));
	register_32 reg28(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(ctrl_writeEnable), .write_ctrl(d_write[28]), .oeA(d_readA[28]), .oeB(d_readB[28]), .clr(ctrl_reset), .in(data_writeReg));
	register_32 reg29(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(ctrl_writeEnable), .write_ctrl(d_write[29]), .oeA(d_readA[29]), .oeB(d_readB[29]), .clr(ctrl_reset), .in(data_writeReg));
	register_32 reg30(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(ctrl_writeEnable), .write_ctrl(d_write[30]), .oeA(d_readA[30]), .oeB(d_readB[30]), .clr(ctrl_reset), .in(data_writeReg));
	register_32 reg31(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(ctrl_writeEnable), .write_ctrl(d_write[31]), .oeA(d_readA[31]), .oeB(d_readB[31]), .clr(ctrl_reset), .in(data_writeReg));
endmodule
