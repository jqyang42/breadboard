module sra_barrel(A, shiftamt, out);
    input [31:0] A;
    input [4:0] shiftamt;
    output [31:0] out;
    wire [31:0] shift16, shift8, shift4, shift2, shift1, bit4, bit3, bit2, bit1;

    // shift A by 16
    sra_16 left_4(.out(shift16), .A(A));
    // bit4 = select A or shifted A
    mux_2_32 bit_4(.out(bit4), .select(shiftamt[4]), .in1(shift16), .in0(A));
    // shift bit4 by 8
    sra_8 left_3(.out(shift8), .A(bit4));
    // bit3 = select bit4 or shifted bit4
    mux_2_32 bit_3(.out(bit3), .select(shiftamt[3]), .in1(shift8), .in0(bit4));
    sra_4 left_2(.out(shift4), .A(bit3));
    mux_2_32 bit_2(.out(bit2), .select(shiftamt[2]), .in1(shift4), .in0(bit3));
    sra_2 left_1(.out(shift2), .A(bit2));
    mux_2_32 bit_1(.out(bit1), .select(shiftamt[1]), .in1(shift2), .in0(bit2));
    sra_1 left_0(.out(shift1), .A(bit1));
    mux_2_32 bit_0(.out(out), .select(shiftamt[0]), .in1(shift1), .in0(bit1));
endmodule