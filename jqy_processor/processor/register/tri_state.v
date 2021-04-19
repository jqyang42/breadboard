module tri_state (out, in, oe);
    input in, oe;
    output out;

    assign out = oe ? in : 1'bz;
endmodule