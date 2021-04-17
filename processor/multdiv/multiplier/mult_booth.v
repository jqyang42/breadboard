module mult_booth(product, prev_product, multiplicand, multiplier, clock);
    input [64:0] prev_product;
    input [31:0] multiplicand, multiplier;  //multiplier isnt used
    input clock;

    output [64:0] product;

    wire [31:0] new_multiplicand, add_to_multiplicand, prev_multiplicand;
    wire signed [64:0] temp_product, write_product;
    wire [2:0] ctrl_bits;

    assign prev_multiplicand = prev_product[64:33];
    assign ctrl_bits[2:0] = prev_product[2:0];
    control ctrl(.new_multiplicand(add_to_multiplicand), .ctrl_bits(ctrl_bits), .multiplicand(multiplicand));

    add_32 add_multiplicand(.A(prev_multiplicand), .B(add_to_multiplicand), .Cin(1'b0), .Sout(new_multiplicand), .Cout(overflow));
    assign temp_product[64:33] = new_multiplicand;
    assign temp_product[32:0] = prev_product[32:0];
    assign write_product = temp_product >>> 2;

    register_65 register(.outA(product), .clk(clock), .ie(1'b1), .oeA(1'b1), .clr(1'b0), .in(write_product), .write_ctrl(1'b1));
endmodule