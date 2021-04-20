/**
 * READ THIS DESCRIPTION!
 *
 * This is your processor module that will contain the bulk of your code submission. You are to implement
 * a 5-stage pipelined processor in this module, accounting for hazards and implementing bypasses as
 * necessary.
 *
 * Ultimately, your processor will be tested by a master skeleton, so the
 * testbench can see which controls signal you active when. Therefore, there needs to be a way to
 * "inject" imem, dmem, and regfile interfaces from some external controller module. The skeleton
 * file, Wrapper.v, acts as a small wrapper around your processor for this purpose. Refer to Wrapper.v
 * for more details.
 *
 * As a result, this module will NOT contain the RegFile nor the memory modules. Study the inputs 
 * very carefully - the RegFile-related I/Os are merely signals to be sent to the RegFile instantiated
 * in your Wrapper module. This is the same for your memory elements. 
 *
 *
 */
module processor(
    // Control signals
    clock,                          // I: The master clock
    reset,                          // I: A reset signal

    // Imem
    address_imem,                   // O: The address of the data to get from imem
    q_imem,                         // I: The data from imem

    // Dmem
    address_dmem,                   // O: The address of the data to get or put from/to dmem
    data,                           // O: The data to write to dmem
    wren,                           // O: Write enable for dmem
    q_dmem,                         // I: The data from dmem

    // Regfile
    ctrl_writeEnable,               // O: Write enable for RegFile
    ctrl_writeReg,                  // O: Register to write to in RegFile
    ctrl_readRegA,                  // O: Register to read from port A of RegFile
    ctrl_readRegB,                  // O: Register to read from port B of RegFile
    data_writeReg,                  // O: Data to write to for RegFile
    data_readRegA,                  // I: Data from port A of RegFile
    data_readRegB                   // I: Data from port B of RegFile
	 
	);

	// Control signals
	input clock, reset;
	
	// Imem
    output [31:0] address_imem;
	input [31:0] q_imem;

	// Dmem
	output [31:0] address_dmem, data;
	output wren;
	input [31:0] q_dmem;

	// Regfile
	output ctrl_writeEnable;
	output [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	output [31:0] data_writeReg;
	input [31:0] data_readRegA, data_readRegB;

	/* YOUR CODE STARTS HERE */

    /*
        Custom instruction information
        * beq - 11111 - I - if ($rd == $rs) PC = PC + 1 + N
        * bgt - 11110 - I - if ($rd > $rs) PC = PC + 1 + N
        * stall - 11101 - I - if $rd != $rs + N then stall
    */
    // original program counter    
	wire [31:0] base_pc;
    wire [31:0] incremented_pc;
    wire [31:0] alternate_pc;       
    wire [31:0] next_pc;
    wire overflow_pc;
    wire stall;
    add_32 add_program_counter(.A(base_pc), .B(32'b0), .Cin(!stall), .Sout(incremented_pc), .Cout(overflow_pc));
    assign next_pc =    ((x_opcode == 5'b00001) || (x_opcode == 5'b00011)) ? x_padded_target : (    // j or jal: go to T
                        (x_opcode == 5'b00100) ? jr_branch_pc : (   // jr: go to $rd
                        ((x_opcode == 5'b10110) && x_latched_not_equal) ? x_padded_target : (   // bex go to T
                        (((x_opcode == 5'b00010) && x_latched_not_equal) || ((x_opcode == 5'b00110) && x_latched_less_than) ? branch_pc : ( // bne and blt
                        (((x_opcode == 5'b11111) && !x_latched_not_equal) ? branch_pc : (   // beq
                        ((x_opcode == 5'b11110) && !x_latched_less_than)) ? bgt_branch_pc : (    // bgt
                        incremented_pc)))))));    // pc++
    register_32 base_program_counter(.outA(base_pc), .clk(!clock), .ie(1'b1), .oeA(1'b1), .clr(reset), .in(next_pc), .write_ctrl(1'b1));

    // Fetch
    assign address_imem = base_pc;

    // F/D registers
    wire [31:0] fd_pc;
    wire [31:0] fd_ir;
    wire [31:0] fd_ir_init;
    wire fd_write_enable;
    wire [31:0] fd_ir_actual;
    assign fd_write_enable = !stall;    // clear datapath control signals -> multiplexers
    register_32 fd_program_counter(.outA(fd_pc), .clk(!clock), .ie(1'b1), .oeA(1'b1), .clr(reset), .in(base_pc), .write_ctrl(fd_write_enable));
    register_32 fd_instruction_register(.outA(fd_ir_init), .clk(!clock), .ie(1'b1), .oeA(1'b1), .clr(reset), .in(q_imem), .write_ctrl(fd_write_enable));
    assign fd_ir =  ((x_opcode == 5'b00011) || (x_opcode == 5'b00100) || (((x_opcode == 5'b00010) || (x_opcode == 5'b10110)) && x_latched_not_equal) 
                    || (((x_opcode == 5'b00110) || (m_opcode == 5'b00110)) && x_latched_less_than) || (x_opcode == 5'b00001) 
                    || (((x_opcode == 5'b11111) && !x_latched_not_equal && !x_latched_less_than) || ((x_opcode == 5'b11110) && x_latched_not_equal && !x_latched_less_than))    // beq and bgt
                    || (x_opcode == 5'b00011) || ((m_opcode == 5'b00100) || (m_opcode == 5'b00010) || (m_opcode == 5'b00001)
                    || (m_opcode == 5'b00011) || (m_opcode == 5'b10110))) ? 32'b0 : // write nop into program, flush memory so not writing
                    (fd_ir_init); 

    // Decode
    wire [4:0] d_opcode = fd_ir[31:27];
    wire [4:0] d_rd = fd_ir[26:22];
    wire [4:0] d_rs = fd_ir[21:17];
    wire [4:0] d_rt = fd_ir[16:12];   // start of R only
    wire [4:0] d_shamt = fd_ir[11:7];
    wire [4:0] d_alu_opcode = fd_ir[6:2];
    wire [1:0] d_r_zeroes = fd_ir[1:0];
    wire [16:0] d_immediate = fd_ir[16:0];    // I only
    wire [26:0] d_target = fd_ir[26:0]; // JI only
    wire [21:0] d_jii_zeroes = fd_ir[21:0]; // JII only
    wire [31:0] d_padded_target;
    wire [31:0] d_pc_plus_one;
    wire [4:0] prev_regA;
    wire [4:0] prev_regB;
    assign ctrl_readRegA = stall ? prev_regA : d_rs;    // use prev regA if stalling
    assign ctrl_readRegB =  stall ? prev_regB : (       // use prev regB if stalling
                            (d_opcode == 5'b0) ? d_rt : (
                            d_opcode == 5'b10110 ? 5'd30 : d_rd));
    register_32 prevRegA(.outA(prev_regA), .clk(!clock), .ie(1'b1), .oeA(1'b1), .clr(reset), .in(ctrl_readRegA), .write_ctrl(!stall));    
    register_32 prevRegB(.outA(prev_regB), .clk(!clock), .ie(1'b1), .oeA(1'b1), .clr(reset), .in(ctrl_readRegB), .write_ctrl(!stall));    
    assign d_padded_target[31:27] = 5'b0;
    assign d_padded_target[26:0] = d_target;
    add_32 jal_pc_plus_one(.A(fd_pc), .B(32'b0), .Cin(1'b1), .Sout(d_pc_plus_one), .Cout(overflow_pc));

    // D/X registers
    wire [31:0] dx_pc;
    wire [31:0] dx_ir;
    wire [31:0] dx_a;
    wire [31:0] dx_b;
    wire [31:0] dx_ir_actual;
    wire [31:0] jal_ir;
    assign stall = ((x_opcode == 5'b01000) && ((d_rs == x_rd) || ((d_rt == x_rd) && (d_opcode != 5'b00111)))) 
                    || (multdiv_in_progress) || ((x_latched_not_equal || x_not_equal) && x_opcode == 5'b11101);    // stall while multdiv is calculating, needs to stall
    assign jal_ir[31:27] = fd_ir[31:27];
    assign jal_ir[26:22] = 5'd31;
    assign jal_ir[21:0] = d_pc_plus_one;
    assign dx_ir_actual =   (stall && multdiv_in_progress) ? 32'b0 : (
                            stall ? dx_ir : (
                            fd_ir));
    register_32 dx_program_counter(.outA(dx_pc), .clk(!clock), .ie(1'b1), .oeA(1'b1), .clr(reset), .in(fd_pc), .write_ctrl(1'b1));
    register_32 dx_instruction_register(.outA(dx_ir), .clk(!clock), .ie(1'b1), .oeA(1'b1), .clr(reset), .in(dx_ir_actual), .write_ctrl(1'b1));
    register_32 dx_data_a(.outA(dx_a), .clk(!clock), .ie(1'b1), .oeA(1'b1), .clr(reset), .in(data_readRegA), .write_ctrl(1'b1));
    register_32 dx_data_b(.outA(dx_b), .clk(!clock), .ie(1'b1), .oeA(1'b1), .clr(reset), .in(data_readRegB), .write_ctrl(1'b1));

    // eXecute
    wire [4:0] x_opcode = dx_ir[31:27];
    wire [4:0] x_rd = dx_ir[26:22];
    wire [4:0] x_rs = dx_ir[21:17];
    wire [4:0] x_rt = dx_ir[16:12];   // start of R only
    wire [4:0] x_shamt = dx_ir[11:7];
    wire [4:0] x_alu_opcode = dx_ir[6:2];
    wire [1:0] x_r_zeroes = dx_ir[1:0];
    wire [16:0] x_immediate = dx_ir[16:0];    // I only
    wire [26:0] x_target = dx_ir[26:0]; // JI only
    wire [21:0] x_jii_zeroes = dx_ir[21:0]; // JII only
    wire [31:0] x_sx_immediate;
    wire [31:0] branch_pc;
    wire [31:0] bgt_branch_pc;
    wire [31:0] x_padded_target;
    wire mx_jr_bypassing;
    wire [31:0] jr_branch_pc;
    wire [31:0] stall_compare;
    wire x_not_equal;
    wire x_less_than;
    sign_extend_17 x_extended_immediate(.out(x_sx_immediate), .in(x_immediate));
    add_32 branch_pc_calc(.A(dx_pc), .B(x_sx_immediate), .Cin(1'b1), .Sout(branch_pc), .Cout(overflow_pc));
    assign bgt_branch_pc = x_sx_immediate;
    assign x_padded_target[31:27] = 5'b0;
    assign x_padded_target[26:0] = x_target;
    assign mx_jr_bypassing = (m_rd == x_rd) && (x_opcode == 5'b00100);
    assign jr_branch_pc = mx_jr_bypassing ? xm_o : dx_b;
    add_32 stall_compare_calc(.A(dx_a), .B(x_sx_immediate), .Cin(1'b0), .Sout(stall_compare), .Cout(overflow_pc));

    wire [4:0] x_alu_opcode_actual;
    wire [31:0] x_a_bypassing;
    wire [31:0] x_b_bypassing;
    wire mx_a_bypassing;
    wire wx_a_bypassing;
    wire mx_b_bypassing;
    wire wx_b_bypassing;
    wire mx_rd_bypassing;
    wire wx_rd_bypassing;
    wire bex_bypassing;
    wire [31:0] x_alu_a_input;
    wire [31:0] x_alu_b_input;    
    wire [31:0] x_alu_result;
    wire x_alu_overflow;
    assign x_alu_opcode_actual = (x_opcode == 5'b0) ? x_alu_opcode : 5'b0;  // R vs I
    assign mx_a_bypassing = (m_rd == x_rs) && !(m_rd == 5'b00000); // 1 stage lag for a
    assign wx_a_bypassing = (w_rd == x_rs) && !(w_rd == 5'b00000) && w_opcode != 5'b00111; // 2 stage lag for a; sw won't affect registers
    assign mx_b_bypassing = (m_rd == x_rt) && !(m_rd == 5'b00000); // 1 stage lag for b
    assign wx_b_bypassing = (w_rd == x_rt) && !(w_rd == 5'b00000) && w_opcode != 5'b00111; // 2 stage lag for b; sw won't affect registers
    assign mx_rd_bypassing = (x_rd == m_rd) && ((x_opcode == 5'b00010) || (x_opcode == 5'b00110) || (x_opcode == 5'b11111) || (x_opcode == 5'b11110) || (x_opcode == 5'b11101));  // bne, blt, beq, bgt, stall_instr
    assign wx_rd_bypassing = (x_rd == w_rd) && ((x_opcode == 5'b00010) || (x_opcode == 5'b00110) || (x_opcode == 5'b11111) || (x_opcode == 5'b11110) || (x_opcode == 5'b11101));  // bne, blt, beq, bgt, stall_instr
    assign bex_bypassing = (x_opcode == 5'b10110) && (m_opcode == 5'b10101);    // if bex immediately after setx
    assign x_a_bypassing =  (mx_a_bypassing) ? xm_o : (   // mx vs wx bypassing 
                            wx_a_bypassing ? data_writeReg : (
                            dx_a));  
    assign x_b_bypassing =  (mx_b_bypassing || mx_rd_bypassing || bex_bypassing) ? xm_o : (   //  mx vs wx bypassing
                            (wx_b_bypassing || wx_rd_bypassing) ? data_writeReg : (
                            (x_opcode == 5'b00101) || (x_opcode == 5'b00111) || (x_opcode == 5'b01000)) ? x_sx_immediate : (    // lw/sw/addi
                            dx_b));   
    assign x_alu_a_input =  ((x_opcode == 5'b00010) || (x_opcode == 5'b00110) || (x_opcode == 5'b10110) || (x_opcode == 5'b11111) || (x_opcode == 5'b11110) || (x_opcode == 5'b11101)) ? x_b_bypassing : ( // if blt, bne, bex, beq, bgt, stall_instr, a = $rd
                            (x_opcode == 5'b11101) ? stall_compare : (  // stall instr
                            x_a_bypassing));
    assign x_alu_b_input =  ((x_opcode == 5'b00010) || (x_opcode == 5'b00110) || (x_opcode == 5'b11111) || (x_opcode == 5'b11110) || (x_opcode == 5'b11101)) ? x_a_bypassing : (   // if blt, bne, beq, bgt, stall_instr, b = $rs
                            (x_opcode == 5'b10110) ? 32'b0 : (  // if bex, b = 0
                            x_b_bypassing));
    alu x_alu(  .data_result(x_alu_result), .overflow(x_alu_overflow), .isNotEqual(x_not_equal), .isLessThan(x_less_than), 
                .data_operandA(x_alu_a_input), .data_operandB(x_alu_b_input), 
                .ctrl_ALUopcode(x_alu_opcode_actual), .ctrl_shiftamt(x_shamt));
    
    wire x_latched_less_than;
    register_32 less_than(.outA(x_latched_less_than), .clk(clock), .ie((x_opcode == 5'b00110) || (x_opcode == 5'b11110) || (x_opcode == 5'b11111)), .oeA(1'b1), .clr(1'b0), .in(x_less_than), .write_ctrl(1'b1));
    wire x_latched_not_equal;
    register_32 not_equal(.outA(x_latched_not_equal), .clk(clock), .ie((x_opcode == 5'b11101) || (x_opcode == 5'b00010) || (x_opcode == 5'b10110) || (x_opcode == 5'b11110) || (x_opcode == 5'b11111)), .oeA(1'b1), .clr(1'b0), .in(x_not_equal), .write_ctrl(1'b1));

    wire [31:0] x_multdiv_result;
    wire isMult;
    wire isDiv;
    wire prev_multdiv_in_progress;
    wire multdiv_in_progress;
    wire [31:0] x_multdiv_a;
    wire [31:0] x_multdiv_b;
    wire x_multdiv_overflow;
    wire x_multdiv_ready;
    wire x_multdiv_ready_actual;
    assign isMult = (x_opcode == 5'b0) && (x_alu_opcode == 5'b00110);
    assign isDiv = (x_opcode == 5'b0) && (x_alu_opcode == 5'b00111);
    register_32 multdiv_progress(.outA(multdiv_in_progress), .clk(clock), .ie(1'b1), .oeA(1'b1), .clr(x_multdiv_ready), .in(1'b1), .write_ctrl(isMult || isDiv));
    register_32 prev_multdiv_progress(.outA(prev_multdiv_in_progress), .clk(!clock), .ie(1'b1), .oeA(1'b1), .clr(1'b0), .in(multdiv_in_progress), .write_ctrl(1'b1));
    register_32 multdiv_a(.outA(x_multdiv_a), .clk(!clock), .ie(1'b1), .oeA(1'b1), .clr(reset), .in(x_alu_a_input), .write_ctrl(isMult || isDiv));
    register_32 multdiv_b(.outA(x_multdiv_b), .clk(!clock), .ie(1'b1), .oeA(1'b1), .clr(reset), .in(x_alu_b_input), .write_ctrl(isMult || isDiv));
    multdiv x_multdiv(.data_operandA(x_multdiv_a), .data_operandB(x_multdiv_b), 
                    .ctrl_MULT(isMult), .ctrl_DIV(isDiv), .clock(!clock),
                    .data_result(x_multdiv_result), .data_exception(x_multdiv_overflow), .data_resultRDY(x_multdiv_ready));
    assign x_multdiv_ready_actual = prev_multdiv_in_progress && !multdiv_in_progress;

    wire [4:0] rstatus_opcode;
    wire [16:0] rstatus_val;
    wire [31:0] rstatus_ir;
    assign rstatus_opcode = (x_opcode == 5'b00000) ? x_alu_opcode : x_opcode;
    assign rstatus_val = (rstatus_opcode == 5'd0) ? 17'd1 : (
        (rstatus_opcode == 5'b00101) ? 17'd2 : (
        (rstatus_opcode == 5'b00001) ? 17'd3 : (
        (rstatus_opcode == 5'b00110) ? 17'd4 : (
        (rstatus_opcode == 5'b00111) ? 17'd5 : (
        (rstatus_opcode == 5'b10101) ? x_target : 17'd0))))); // add rstatus for setx
    assign rstatus_ir[31:27] = x_opcode;
    assign rstatus_ir[26:22] = 5'd30;       // $rd = $r30
    assign rstatus_ir[21:17] = 5'd0;        // $rs = $r0
    assign rstatus_ir[16:0] = rstatus_val;  // immediate = rstatus_val
    assign x_overflow = x_multdiv_ready_actual ? x_multdiv_overflow : x_alu_overflow;

    // P/W registers
    wire [31:0] pw_ir;
    wire [4:0] p_rd = pw_ir[26:22];
    wire pw_write_enable;
    assign pw_write_enable = isDiv || isMult;   // write only on first 
    register_32 pw_instruction_register(.outA(pw_ir), .clk(!clock), .ie(1'b1), .oeA(1'b1), .clr(reset), .in(dx_ir), .write_ctrl(pw_write_enable)); // include overflow?

    // X/M registers
    wire [31:0] xm_ir;
    wire [31:0] xm_o;
    wire [31:0] xm_b;
    wire [31:0] xm_ir_actual;
    wire [31:0] xm_o_actual;
    wire [31:0] xm_o_latched;
    assign xm_ir_actual =   (x_overflow || (x_opcode == 5'b10101)) ? rstatus_ir : (
                            (d_opcode == 5'b00011)) ? jal_ir : dx_ir;   // use new jal instruction
    assign xm_o_actual =    (x_overflow || (x_opcode == 5'b10101)) ? rstatus_val : (
                            (x_opcode == 5'b00100) || (x_opcode == 5'b00010) || (x_opcode == 5'b00110) || (x_opcode == 5'b11111) || (x_opcode == 5'b11110) || (x_opcode == 5'b11101)) ? xm_o_latched : x_alu_result;  //jr, bne, blt, beq, bgt, stall_instr
    register_32 latched_xm_o(.outA(xm_o_latched), .clk(!clock), .ie(!((x_opcode == 5'b00100) || (x_opcode == 5'b00010) || (x_opcode == 5'b00110 || (x_opcode == 5'b11111) || (x_opcode == 5'b11110)))), .oeA(1'b1), .clr(reset), .in(xm_o_actual), .write_ctrl(1'b1));
    register_32 xm_instruction_register(.outA(xm_ir), .clk(!clock), .ie(1'b1), .oeA(1'b1), .clr(reset), .in(xm_ir_actual), .write_ctrl(1'b1));
    register_32 xm_ouput(.outA(xm_o), .clk(!clock), .ie(1'b1), .oeA(1'b1), .clr(reset), .in(xm_o_actual), .write_ctrl(1'b1));
    register_32 xm_written_b(.outA(xm_b), .clk(!clock), .ie(1'b1), .oeA(1'b1), .clr(reset), .in(dx_b), .write_ctrl(1'b1));

    // Memory
    wire [4:0] m_opcode = xm_ir[31:27];
    wire [4:0] m_rd = xm_ir[26:22];
    wire [4:0] m_rs = xm_ir[21:17];
    wire [4:0] m_rt = xm_ir[16:12];   // start of R only
    wire [4:0] m_shamt = xm_ir[11:7];
    wire [4:0] m_alu_opcode = xm_ir[6:2];
    wire [1:0] m_r_zeroes = xm_ir[1:0];
    wire [16:0] m_immediate = xm_ir[16:0];    // I only
    wire [26:0] m_target = xm_ir[26:0]; // JI only
    wire [21:0] m_jii_zeroes = xm_ir[21:0]; // JII only
    wire wm_bypassing;
    assign wren = (m_opcode == 5'b00111);    // enable writing to data mem when sw
    assign address_dmem = xm_o;
    assign wm_bypassing = (m_rd == w_rd ) && (m_opcode == 5'b00111);  // wm bypassing if storing immediately after some instruction
    assign data = wm_bypassing ? data_writeReg : xm_b;

    // M/W registers
    wire [31:0] mw_ir;
    wire [31:0] mw_o;
    wire [31:0] mw_d;
    register_32 mw_instruction_register(.outA(mw_ir), .clk(!clock), .ie(1'b1), .oeA(1'b1), .clr(reset), .in(xm_ir), .write_ctrl(1'b1));
    register_32 mw_ouput(.outA(mw_o), .clk(!clock), .ie(1'b1), .oeA(1'b1), .clr(reset), .in(xm_o), .write_ctrl(1'b1));
    register_32 mw_data(.outA(mw_d), .clk(!clock), .ie(1'b1), .oeA(1'b1), .clr(reset), .in(q_dmem), .write_ctrl(1'b1));

    // Writeback
    wire [4:0] w_opcode = mw_ir[31:27];
    wire [4:0] w_rd = mw_ir[26:22];
    wire [4:0] w_rs = mw_ir[21:17];
    wire [4:0] w_rt = mw_ir[16:12];   // start of R only
    wire [4:0] w_shamt = mw_ir[11:7];
    wire [4:0] w_alu_opcode = mw_ir[6:2];
    wire [1:0] w_r_zeroes = mw_ir[1:0];
    wire [16:0] w_immediate = mw_ir[16:0];    // I only
    wire [26:0] w_target = mw_ir[26:0]; // JI only
    wire [21:0] w_jii_zeroes = mw_ir[21:0]; // JII only
    assign ctrl_writeEnable = !(w_opcode == 5'b00111) && !(w_opcode == 5'b00100) && !(w_opcode == 5'b00010) && !(w_opcode == 5'b00110)  && !(w_opcode == 5'b11111) && !(w_opcode == 5'b11110) && !(w_opcode == 5'b11101); // write when not sw, bne, blt, beq, bgt, stall_instr
    assign ctrl_writeReg = x_multdiv_ready_actual ? p_rd : w_rd;    // write to $ra or write to multdiv reg when ready
    assign data_writeReg =  (w_opcode == 5'b00011) ? w_jii_zeroes : // use last 22 bits if jal
                            (x_multdiv_ready_actual ? x_multdiv_result : ((w_opcode == 5'b01000) ? mw_d : mw_o));    // write from memory when lw; from pw_p when multdiv
	/* END CODE */
endmodule
