module sll_8(A, out);
    input [31:0] A;
    output [31:0] out;

    assign out[0] = 0;
    assign out[1] = 0;
    assign out[2] = 0;
    assign out[3] = 0;
    assign out[4] = 0;
    assign out[5] = 0;
    assign out[6] = 0;
    assign out[7] = 0;
    assign out[8] = A[0];
    assign out[9] = A[1];
    assign out[10] = A[2];
    assign out[11] = A[3];
    assign out[12] = A[4];
    assign out[13] = A[5];
    assign out[14] = A[6];
    assign out[15] = A[7];
    assign out[16] = A[8];
    assign out[17] = A[9];
    assign out[18] = A[10];
    assign out[19] = A[11];
    assign out[20] = A[12];
    assign out[21] = A[13];
    assign out[22] = A[14];
    assign out[23] = A[15];
    assign out[24] = A[16];
    assign out[25] = A[17];
    assign out[26] = A[18];
    assign out[27] = A[19];
    assign out[28] = A[20];
    assign out[29] = A[21];
    assign out[30] = A[22];
    assign out[31] = A[23];
endmodule