module regfile (
	clock,
	ctrl_writeEnable, ctrl_reset, ctrl_writeReg,
	ctrl_readRegA, ctrl_readRegB, data_writeReg,
	data_readRegA, data_readRegB, reg15_input
);

	input clock, ctrl_writeEnable, ctrl_reset;
	input [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	input [31:0] data_writeReg, reg15_input;

	output [31:0] data_readRegA, data_readRegB;

	wire [31:0] d_write, d_readA, d_readB;
	// add your code here
	decoder decode_write(.onehot(d_write), .shift(ctrl_writeReg));
	decoder decode_readA(.onehot(d_readA), .shift(ctrl_readRegA));
	decoder decode_readB(.onehot(d_readB), .shift(ctrl_readRegB));

	register_32 reg0(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(1'b0), .write_ctrl(d_write[0]), .oeA(d_readA[0]), .oeB(d_readB[0]), .clr(ctrl_reset), .in(data_writeReg));
	register_32 reg1(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(ctrl_writeEnable), .write_ctrl(d_write[1]), .oeA(d_readA[1]), .oeB(d_readB[1]), .clr(ctrl_reset), .in(data_writeReg));
	register_32 reg2(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(ctrl_writeEnable), .write_ctrl(d_write[2]), .oeA(d_readA[2]), .oeB(d_readB[2]), .clr(ctrl_reset), .in(data_writeReg));
	register_32 reg3(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(ctrl_writeEnable), .write_ctrl(d_write[3]), .oeA(d_readA[3]), .oeB(d_readB[3]), .clr(ctrl_reset), .in(data_writeReg));
	register_32 reg4(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(ctrl_writeEnable), .write_ctrl(d_write[4]), .oeA(d_readA[4]), .oeB(d_readB[4]), .clr(ctrl_reset), .in(data_writeReg));
	register_32 reg5(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(ctrl_writeEnable), .write_ctrl(d_write[5]), .oeA(d_readA[5]), .oeB(d_readB[5]), .clr(ctrl_reset), .in(data_writeReg));
	register_32 reg6(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(ctrl_writeEnable), .write_ctrl(d_write[6]), .oeA(d_readA[6]), .oeB(d_readB[6]), .clr(ctrl_reset), .in(data_writeReg));
	register_32 reg7(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(ctrl_writeEnable), .write_ctrl(d_write[7]), .oeA(d_readA[7]), .oeB(d_readB[7]), .clr(ctrl_reset), .in(data_writeReg));
	register_32 reg8(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(ctrl_writeEnable), .write_ctrl(d_write[8]), .oeA(d_readA[8]), .oeB(d_readB[8]), .clr(ctrl_reset), .in(data_writeReg));
	register_32 reg9(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(ctrl_writeEnable), .write_ctrl(d_write[9]), .oeA(d_readA[9]), .oeB(d_readB[9]), .clr(ctrl_reset), .in(data_writeReg));
	register_32 reg10(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(ctrl_writeEnable), .write_ctrl(d_write[10]), .oeA(d_readA[10]), .oeB(d_readB[10]), .clr(ctrl_reset), .in(data_writeReg));
	register_32 reg11(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(ctrl_writeEnable), .write_ctrl(d_write[11]), .oeA(d_readA[11]), .oeB(d_readB[11]), .clr(ctrl_reset), .in(data_writeReg));
	register_32 reg12(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(ctrl_writeEnable), .write_ctrl(d_write[12]), .oeA(d_readA[12]), .oeB(d_readB[12]), .clr(ctrl_reset), .in(data_writeReg));
	register_32 reg13(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(ctrl_writeEnable), .write_ctrl(d_write[13]), .oeA(d_readA[13]), .oeB(d_readB[13]), .clr(ctrl_reset), .in(data_writeReg));
	register_32 reg14(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(ctrl_writeEnable), .write_ctrl(d_write[14]), .oeA(d_readA[14]), .oeB(d_readB[14]), .clr(ctrl_reset), .in(data_writeReg));
	register_32 reg15(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(1'b1), .write_ctrl(1'b1), .oeA(d_readA[15]), .oeB(d_readB[15]), .clr(ctrl_reset), .in(reg15_input));
	register_32 reg16(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(ctrl_writeEnable), .write_ctrl(d_write[16]), .oeA(d_readA[16]), .oeB(d_readB[16]), .clr(ctrl_reset), .in(data_writeReg));
	register_32 reg17(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(ctrl_writeEnable), .write_ctrl(d_write[17]), .oeA(d_readA[17]), .oeB(d_readB[17]), .clr(ctrl_reset), .in(data_writeReg));
	register_32 reg18(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(ctrl_writeEnable), .write_ctrl(d_write[18]), .oeA(d_readA[18]), .oeB(d_readB[18]), .clr(ctrl_reset), .in(data_writeReg));
	register_32 reg19(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(ctrl_writeEnable), .write_ctrl(d_write[19]), .oeA(d_readA[19]), .oeB(d_readB[19]), .clr(ctrl_reset), .in(data_writeReg));
	register_32 reg20(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(ctrl_writeEnable), .write_ctrl(d_write[20]), .oeA(d_readA[20]), .oeB(d_readB[20]), .clr(ctrl_reset), .in(data_writeReg));
	register_32 reg21(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(ctrl_writeEnable), .write_ctrl(d_write[21]), .oeA(d_readA[21]), .oeB(d_readB[21]), .clr(ctrl_reset), .in(data_writeReg));
	register_32 reg22(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(ctrl_writeEnable), .write_ctrl(d_write[22]), .oeA(d_readA[22]), .oeB(d_readB[22]), .clr(ctrl_reset), .in(data_writeReg));
	register_32 reg23(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(ctrl_writeEnable), .write_ctrl(d_write[23]), .oeA(d_readA[23]), .oeB(d_readB[23]), .clr(ctrl_reset), .in(data_writeReg));
	register_32 reg24(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(ctrl_writeEnable), .write_ctrl(d_write[24]), .oeA(d_readA[24]), .oeB(d_readB[24]), .clr(ctrl_reset), .in(data_writeReg));
	register_32 reg25(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(ctrl_writeEnable), .write_ctrl(d_write[25]), .oeA(d_readA[25]), .oeB(d_readB[25]), .clr(ctrl_reset), .in(data_writeReg));
	register_32 reg26(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(ctrl_writeEnable), .write_ctrl(d_write[26]), .oeA(d_readA[26]), .oeB(d_readB[26]), .clr(ctrl_reset), .in(data_writeReg));
	register_32 reg27(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(ctrl_writeEnable), .write_ctrl(d_write[27]), .oeA(d_readA[27]), .oeB(d_readB[27]), .clr(ctrl_reset), .in(data_writeReg));
	register_32 reg28(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(ctrl_writeEnable), .write_ctrl(d_write[28]), .oeA(d_readA[28]), .oeB(d_readB[28]), .clr(ctrl_reset), .in(data_writeReg));
	register_32 reg29(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(ctrl_writeEnable), .write_ctrl(d_write[29]), .oeA(d_readA[29]), .oeB(d_readB[29]), .clr(ctrl_reset), .in(data_writeReg));
	register_32 reg30(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(ctrl_writeEnable), .write_ctrl(d_write[30]), .oeA(d_readA[30]), .oeB(d_readB[30]), .clr(ctrl_reset), .in(data_writeReg));
	register_32 reg31(.outA(data_readRegA), .outB(data_readRegB), .clk(clock), .ie(ctrl_writeEnable), .write_ctrl(d_write[31]), .oeA(d_readA[31]), .oeB(d_readB[31]), .clr(ctrl_reset), .in(data_writeReg));
endmodule
