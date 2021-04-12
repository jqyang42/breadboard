module register_7(outA, clk, ie, oeA, clr, in, write_ctrl);
    input clk, ie, oeA, clr, write_ctrl;
    input [6:0] in;

    output [6:0] outA;
    
    wire [6:0] dff_out;

    and input_enable(w_ie, ie, write_ctrl);

    dffe_ref dffe0(.q(dff_out[0]), .d(in[0]), .clk(clk), .en(w_ie), .clr(clr));
    dffe_ref dffe1(.q(dff_out[1]), .d(in[1]), .clk(clk), .en(w_ie), .clr(clr));
    dffe_ref dffe2(.q(dff_out[2]), .d(in[2]), .clk(clk), .en(w_ie), .clr(clr));
    dffe_ref dffe3(.q(dff_out[3]), .d(in[3]), .clk(clk), .en(w_ie), .clr(clr));
    dffe_ref dffe4(.q(dff_out[4]), .d(in[4]), .clk(clk), .en(w_ie), .clr(clr));
    dffe_ref dffe5(.q(dff_out[5]), .d(in[5]), .clk(clk), .en(w_ie), .clr(clr));
    dffe_ref dffe6(.q(dff_out[6]), .d(in[6]), .clk(clk), .en(w_ie), .clr(clr));

    tri_state outputA0(.out(outA[0]), .in(dff_out[0]), .oe(oeA));
    tri_state outputA1(.out(outA[1]), .in(dff_out[1]), .oe(oeA));
    tri_state outputA2(.out(outA[2]), .in(dff_out[2]), .oe(oeA));
    tri_state outputA3(.out(outA[3]), .in(dff_out[3]), .oe(oeA));
    tri_state outputA4(.out(outA[4]), .in(dff_out[4]), .oe(oeA));
    tri_state outputA5(.out(outA[5]), .in(dff_out[5]), .oe(oeA));
    tri_state outputA6(.out(outA[6]), .in(dff_out[6]), .oe(oeA));
endmodule