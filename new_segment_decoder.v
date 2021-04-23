module new_segment_decoder(number, cathodes);
    input[2:0] number;
    output reg [6:0] cathodes;

    always @(number) begin
        case(number)
            3'd0: cathodes = 7'b0000001;
            3'd1: cathodes = 7'b1001111;
            3'd2: cathodes = 7'b0010010;
            3'd3: cathodes = 7'b0000110;
            3'd4: cathodes = 7'b1001100;
            3'd5: cathodes = 7'b0100100;
            3'd6: cathodes = 7'b0100000;
            3'd7: cathodes = 7'b0001111;
            3'd8: cathodes = 7'b0000000;
            3'd9: cathodes = 7'b0000100;
        endcase
    end
endmodule