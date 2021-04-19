module segment_decoder(number, ca, cb, cc, cd, ce, cf, cg);
    input[1:0] number;
    output ca, cb, cc, cd, ce, cf, cg;

    assign ca = !((number == 3'd0) || (number == 3'd2));
    assign cb = !((number == 3'd0) || (number == 3'd1) || (number == 3'd2));
    assign cc = !((number == 3'd0) || (number == 3'd1));
    assign cd = !((number == 3'd0) || (number == 3'd2));
    assign ce = !((number == 3'd0) || (number == 3'd2));
    assign cf = !((number == 3'd0));
    assign cg = !((number == 3'd2));
endmodule