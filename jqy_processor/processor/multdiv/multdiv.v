module multdiv(
	data_operandA, data_operandB, 
	ctrl_MULT, ctrl_DIV, 
	clock, 
	data_result, data_exception, data_resultRDY);

    input [31:0] data_operandA, data_operandB;
    input ctrl_MULT, ctrl_DIV, clock;

    output [31:0] data_result;
    output data_exception, data_resultRDY;

    // add your code here
    // check multiply or divide
    wire isDiv;
    dffe_ref check_div(.q(isDiv), .d(ctrl_DIV), .clk(clock), .en(ctrl_DIV), .clr(ctrl_MULT));

    //multiplication
    wire [64:0] new_product, prev_product, first_product;
    assign first_product[64:33] = 32'b0;
    assign first_product[32:1] = data_operandB;
    assign first_product[0] = 1'b0;
    wire [31:0] final_product;
    
    //division
    wire [31:0] negated_A, negated_B, positive_A, positive_B, unsigned_quotient, negative_quotient, final_quotient;
    wire div_negative;
    add_32 negate_A(.A(32'b0), .B(~data_operandA), .Cin(1'b1), .Sout(negated_A), .Cout(overflow));
    add_32 negate_B(.A(32'b0), .B(~data_operandB), .Cin(1'b1), .Sout(negated_B), .Cout(overflow));
    assign positive_A = data_operandA[31] ? negated_A : data_operandA;
    assign positive_B = data_operandB[31] ? negated_B : data_operandB;
    wire [63:0] new_total_quotient, prev_total_quotient, first_total_quotient; 
    assign first_total_quotient[63:32] = 32'b0;
    assign first_total_quotient[31:0] = positive_A;

    // counters
    wire [6:0] curr_counter;
    wire counter_is_32 = (!curr_counter[6] && curr_counter[5] && !curr_counter[4] && !curr_counter[3] && !curr_counter[2] && !curr_counter[1] && !curr_counter[0]);
    assign counter_is_16 = (!curr_counter[6] && !curr_counter[5] && curr_counter[4] && !curr_counter[3] && !curr_counter[2] && !curr_counter[1] && !curr_counter[0]);
    assign counter_is_0 = !(|curr_counter);

    // if curr_counter = 0, set new_product = multiplier
    assign prev_product = counter_is_0 ? first_product : new_product;
    assign prev_total_quotient = counter_is_0 ? first_total_quotient : new_total_quotient;

    counter_7 multdiv_counter(.current(curr_counter), .previous(curr_counter), .restart(ctrl_MULT || ctrl_DIV), .clock(clock));

    mult_booth multiplier(.product(new_product), .prev_product(prev_product), .multiplicand(data_operandA), .multiplier(data_operandB), .clock(clock));
    assign final_product = new_product[32:1];
    
    xor div_sign_gate(div_negative, data_operandA[31], data_operandB[31]);
    divider_nonres divider(.total_quotient(new_total_quotient), .prev_total_quotient(prev_total_quotient), .dividend(positive_A), .divisor(positive_B), .clock(clock));
    assign unsigned_quotient = new_total_quotient[31:0];
    add_32 quotient_sign(.A(32'b0), .B(~unsigned_quotient), .Cin(1'b1), .Sout(negative_quotient), .Cout(overflow));
    assign final_quotient = div_overflow ? 1'b0 : (div_negative ? negative_quotient : unsigned_quotient);

    // multiplication overflow detection - if 0: check sign of product; else check truth table or check overflow into top bits
    wire mult_overflow, mult_upper_registers_overflow, mult_sign_overflow, div_overflow;
    assign mult_overflow = ((!(|data_operandA) || !(|data_operandB)) ? (new_product[32]) : (mult_sign_overflow || mult_upper_registers_overflow));
    assign mult_sign_overflow = ((!data_operandA[31] && !data_operandB[31] && new_product[32]) 
        || (!data_operandA[31] && data_operandB[31] && !new_product[32]) 
        || (data_operandA[31] && !data_operandB[31] && !new_product[32])
        || (data_operandA[31] && data_operandB[31] && new_product[32]));
    assign mult_upper_registers_overflow = |new_product[64:32] && !(&new_product[64:32]);

    assign div_overflow = !(|data_operandB);

    // check data based on which operation is needed
    assign data_result = isDiv ? final_quotient : final_product;
    assign data_resultRDY = isDiv ? counter_is_32 : counter_is_16;
    assign data_exception = (!ctrl_MULT && !ctrl_DIV) ? 1'b0 : (isDiv ? div_overflow : mult_overflow);
endmodule