module control(new_multiplicand, ctrl_bits, multiplicand);
    input [2:0] ctrl_bits;
    input [31:0] multiplicand;
    output [31:0] new_multiplicand;

    wire [31:0] negative_m, negative_shifted_m, shifted_m;

    // all possibilities
    add_32 sub_gate(.A(32'b0), .B(~multiplicand), .Cin(1'b1), .Sout(negative_m), .Cout(overflow));
    assign negative_shifted_m = negative_m << 1;
    assign shifted_m = multiplicand << 1;

    mux_8_32 mux(.out(new_multiplicand), .select(ctrl_bits), .in0(32'b0), .in1(multiplicand), .in2(multiplicand), .in3(shifted_m), .in4(negative_shifted_m), .in5(negative_m), .in6(negative_m), .in7(32'b0));
endmodule