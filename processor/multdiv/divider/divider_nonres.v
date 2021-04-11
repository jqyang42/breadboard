module divider_nonres(total_quotient, prev_total_quotient, dividend, divisor, clock);
    input [63:0] prev_total_quotient;
    input [31:0] dividend, divisor;
    input clock, clear;

    output [63:0] total_quotient;

    wire[63:0] shifted_total_quotient = prev_total_quotient << 1;
    wire[31:0] shifted_remainder = shifted_total_quotient[63:32];
    wire[31:0] shifted_quotient = shifted_total_quotient[31:0];

    wire[31:0] neg_divisor;
    add_32 sub_gate(.A(32'b0), .B(~divisor), .Cin(1'b1), .Sout(neg_divisor), .Cout(overflow));

    wire[31:0] to_add_divisor = shifted_remainder[31] ? divisor : neg_divisor;

    wire[31:0] sum_remainder;
    add_32 dividend_add(.A(to_add_divisor), .B(shifted_remainder), .Cin(1'b0), .Sout(sum_remainder), .Cout(overflow));

    wire[63:0] write_total_quotient;
    assign write_total_quotient[63:32] = sum_remainder;
    assign write_total_quotient[31:1] = shifted_quotient[31:1];
    assign write_total_quotient[0] = !sum_remainder[31];

    register_64 register(.outA(total_quotient), .clk(clock), .ie(1'b1), .oeA(1'b1), .clr(1'b0), .in(write_total_quotient), .write_ctrl(1'b1));
endmodule