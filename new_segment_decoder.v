module new_segment_decoder(number, cathodes);
    input[3:0] number;
    output reg [6:0] cathodes;

    always @(number) begin
        case(number)    // ABCDEFG
            4'd0: cathodes = 7'b0000001;
            4'd1: cathodes = 7'b1001111;
            4'd2: cathodes = 7'b0010010;
            4'd3: cathodes = 7'b0000110;
            4'd4: cathodes = 7'b1001100;
            4'd5: cathodes = 7'b0100100;
            4'd6: cathodes = 7'b0100000;
            4'd7: cathodes = 7'b0001111;
            4'd8: cathodes = 7'b0000000;
            4'd9: cathodes = 7'b0000100;
        endcase
    end
endmodule