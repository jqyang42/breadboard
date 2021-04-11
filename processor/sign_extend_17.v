module sign_extend_17(out, in);
    input [16:0] in;
    output [31:0] out;

    genvar i;
    generate
        for (i = 17; i < 32; i = i + 1)
        begin
            assign out[i] = in[16];
        end
    endgenerate

    assign out[16:0] = in;

endmodule