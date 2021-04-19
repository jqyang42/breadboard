module decoder (onehot, shift);
    input [4:0] shift;

    output [31:0] onehot;

    integer i = 1;
    sll_barrel shifted(.A(i), .shiftamt(shift), .out(onehot));
endmodule