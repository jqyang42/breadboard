module counter_7(current, previous, restart, clock);
    input [6:0] previous;
    input clock, restart;

    output [6:0] current;

    wire [6:0] sum;

    add_32 increment(.A(previous), .B(7'b0), .Cin(1'b1), .Sout(sum), .Cout(overflow));
    register_7 mult_counter(.outA(current), .clk(clock), .ie(1'b1), .oeA(1'b1), .clr(restart), .in(sum), .write_ctrl(1'b1));
endmodule