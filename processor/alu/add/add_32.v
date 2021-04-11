module add_32(A, B, Cin, Sout, Cout);
    input [31:0] A, B;
    input Cin;
    output [31:0] Sout;
    output Cout;

    add_8 add_7_0(.A(A[7:0]), .B(B[7:0]), .Cin(Cin), .Sout(Sout[7:0]), .Gout(w_G0), .Pout(w_P0));
    and P0_Cin(w_P0_Cin, w_P0, Cin);
    or c8(w_c8, w_G0, w_P0_Cin);

    add_8 add_15_8(.A(A[15:8]), .B(B[15:8]), .Cin(w_c8), .Sout(Sout[15:8]), .Gout(w_G1), .Pout(w_P1));
    and P1_G0(w_P1_G0, w_P1, w_G0);
    and P1_Cin(w_P1_Cin, w_P1, w_P0, Cin);
    or c16(w_c16, w_G1, w_P1_G0, w_P1_Cin);

    add_8 add_23_16(.A(A[23:16]), .B(B[23:16]), .Cin(w_c16), .Sout(Sout[23:16]), .Gout(w_G2), .Pout(w_P2));
    and P2_G1(w_P2_G1, w_P2, w_G1);
    and P2_G0(w_P2_G0, w_P2, w_P1, w_G0);
    and P2_Cin(w_P2_Cin, w_P2, w_P1, w_P0, Cin);
    or c24(w_c24, w_G2, w_P2_G1, w_P2_G0, w_P2_Cin);

    add_8 add_31_24(.A(A[31:24]), .B(B[31:24]), .Cin(w_c24), .Sout(Sout[31:24]), .Gout(w_G3), .Pout(w_P3));
    and P3_G2(w_P3_G2, w_P3, w_G2);
    and P3_G1(w_P3_G1, w_P3, w_P2, w_G1);
    and P3_G0(w_P3_G0, w_P3, w_P2, w_P1, w_G0);
    and P3_Cin(w_P3_Cin, w_P3, w_P2, w_P1, w_P0, Cin);
    or c32(Cout, w_G3, w_P3_G2, w_P3_G1, w_P3_G0, w_P3_Cin);
endmodule