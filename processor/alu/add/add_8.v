module add_8(A, B, Cin, Sout, Gout, Pout);
    input [7:0] A, B;
    input Cin;
    output [7:0] Sout;
    output Gout, Pout;

    xor s0(Sout[0], Cin, A[0], B[0]);
    and g0(w_g0, A[0], B[0]);
    or p0(w_p0, A[0], B[0]);
    and p0_Cin(w_p0_Cin, w_p0, Cin);
    or c1(w_c1, w_g0, w_p0_Cin);

    xor s1(Sout[1], w_c1, A[1], B[1]);
    and g1(w_g1, A[1], B[1]);
    or p1(w_p1, A[1], B[1]);
    and p1_c1(w_p1_c1, w_p1, w_c1);
    or c2(w_c2, w_g1, w_p1_c1);

    xor s2(Sout[2], w_c2, A[2], B[2]);
    and g2(w_g2, A[2], B[2]);
    or p2(w_p2, A[2], B[2]);
    and p2_c2(w_p2_c2, w_p2, w_c2);
    or c3(w_c3, w_g2, w_p2_c2);

    xor s3(Sout[3], w_c3, A[3], B[3]);
    and g3(w_g3, A[3], B[3]);
    or p3(w_p3, A[3], B[3]);
    and p3_c3(w_p3_c3, w_p3, w_c3);
    or c4(w_c4, w_g3, w_p3_c3);

    xor s4(Sout[4], w_c4, A[4], B[4]);
    and g4(w_g4, A[4], B[4]);
    or p4(w_p4, A[4], B[4]);
    and p4_c4(w_p4_c4, w_p4, w_c4);
    or c5(w_c5, w_g4, w_p4_c4);
    
    xor s5(Sout[5], w_c5, A[5], B[5]);
    and g5(w_g5, A[5], B[5]);
    or p5(w_p5, A[5], B[5]);
    and p5_c5(w_p5_c5, w_p5, w_c5);
    or c6(w_c6, w_g5, w_p5_c5);
    
    xor s6(Sout[6], w_c6, A[6], B[6]);
    and g6(w_g6, A[6], B[6]);
    or p6(w_p6, A[6], B[6]);
    and p6_c6(w_p6_c6, w_p6, w_c6);
    or c7(w_c7, w_g6, w_p6_c6);
    
    xor s7(Sout[7], w_c7, A[7], B[7]);
    and g7(w_g7, A[7], B[7]);
    or p7(w_p7, A[7], B[7]);
    and p7_c7(w_p7_c7, w_p7, w_c7);
    or c8(w_c8, w_g7, w_p7_c7);        

    and p(Pout, w_p0, w_p1, w_p2, w_p3, w_p4, w_p5, w_p6, w_p7);
    and p7_g6(w_p7_g6, w_p7, w_g6);
    and p7_g5(w_p7_g5, w_p7, w_p6, w_g5);
    and p7_g4(w_p7_g4, w_p7, w_p6, w_p5, w_g4);
    and p7_g3(w_p7_g3, w_p7, w_p6, w_p5, w_p4, w_g3);
    and p7_g2(w_p7_g2, w_p7, w_p6, w_p5, w_p4, w_p3, w_g2);
    and p7_g1(w_p7_g1, w_p7, w_p6, w_p5, w_p4, w_p3, w_p2, w_g1);
    and p7_g0(w_p7_g0, w_p7, w_p6, w_p5, w_p4, w_p3, w_p2, w_p1, w_g0);
    or g(Gout, w_g7, w_p7_g6, w_p7_g5, w_p7_g4, w_p7_g3, w_p7_g2, w_p7_g1, w_p7_g0);
endmodule