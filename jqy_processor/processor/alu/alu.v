module alu(data_operandA, data_operandB, ctrl_ALUopcode, ctrl_shiftamt, data_result, isNotEqual, isLessThan, overflow);
        
    input [31:0] data_operandA, data_operandB;
    input [4:0] ctrl_ALUopcode, ctrl_shiftamt;

    output [31:0] data_result;
    output isNotEqual, isLessThan, overflow;

    // added code!!!
    wire [31:0] w_add, w_sub, w_and, w_or, w_sll, w_sra, w_notB;
    wire w_add_overflow, w_sub_overflow;

    // addition
    add_32 add_gate(.A(data_operandA), .B(data_operandB), .Cin(1'b0), .Sout(w_add), .Cout(w_add_overflow));
    // subtraction
    not_gate not_B(.out(w_notB), .A(data_operandB));
    add_32 sub_gate(.A(data_operandA), .B(w_notB), .Cin(1'b1), .Sout(w_sub), .Cout(w_sub_overflow));
    // bitwise and
    and_gate and_g(.out(w_and), .A(data_operandA), .B(data_operandB));
    // bitwise or
    or_gate or_g(.out(w_or), .A(data_operandA), .B(data_operandB));
    // logical left shift
    sll_barrel sll_gate(.out(w_sll), .A(data_operandA), .shiftamt(ctrl_shiftamt));
    // arithmetic right shift
    sra_barrel sra_gate(.out(w_sra), .A(data_operandA), .shiftamt(ctrl_shiftamt));
    
    or not_eq(isNotEqual, w_sub[31], w_sub[30], w_sub[29], w_sub[28], w_sub[27], w_sub[26], w_sub[25], w_sub[24], w_sub[23], w_sub[22], w_sub[21], w_sub[20], w_sub[19], w_sub[18], w_sub[17], w_sub[16], w_sub[15], w_sub[14], w_sub[13], w_sub[12], w_sub[11], w_sub[10], w_sub[9], w_sub[8], w_sub[7], w_sub[6], w_sub[5], w_sub[4], w_sub[3], w_sub[2], w_sub[1], w_sub[0]);
    and temp_less_than(w_temp_less_than, w_sub[31], 1'b1);
    not not_temp_less_than(w_not_temp_less_than, w_temp_less_than);
    assign isLessThan = overflow ? w_not_temp_less_than : w_temp_less_than;

    // overflow detection
    not not_a(w_not_a, data_operandA[31]);
    not not_b(w_not_b, data_operandB[31]);
    not not_sub(w_not_sub, w_sub[31]);
    not not_add(w_not_add, w_add[31]);

    and of_add_1(w_of_add_1, data_operandA[31], data_operandB[31], w_not_add);
    and of_add_2(w_of_add_2, w_not_a, w_not_b, w_add[31]);
    or overflow_add(w_add_overdet, w_of_add_1, w_of_add_2);
    
    and of_sub_1(w_of_sub_1, data_operandA[31], w_not_b, w_not_sub);
    and of_sub_2(w_of_sub_2, w_not_a, data_operandB[31], w_sub[31]);
    or overflow_sub(w_sub_overdet, w_of_sub_1, w_of_sub_2);

    mux_8_32 final_out(data_result, ctrl_ALUopcode[2:0], w_add, w_sub, w_and, w_or, w_sll, w_sra, x, x);
    //mux_8_32 overflow_out(overflow, ctrl_ALUopcode[2:0], w_add_overdet, w_sub_overdet, x, x, x, x, x, x);
    mux_2_32 overflow_out(overflow, ctrl_ALUopcode[2:0], w_add_overdet, w_sub_overdet);
endmodule