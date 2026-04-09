// morse_encoder.v
module morse_encoder (
    input [7:0]  char_in,
    output reg [9:0] morse_pattern,
    output reg [2:0] morse_len
);

    localparam DOT = 2'b01;
    localparam DASH = 2'b10;
    localparam NONE = 2'b00;

    always @(*) begin
        morse_pattern = 10'b0;
        morse_len = 3'b0;

        case (char_in)
            "A", "a": begin morse_pattern = {NONE, NONE, NONE, DASH, DOT};  morse_len = 2; end
            "B", "b": begin morse_pattern = {NONE, DOT, DOT, DOT, DASH};  morse_len = 4; end
            "C", "c": begin morse_pattern = {NONE, DOT, DASH, DOT, DASH};  morse_len = 4; end
            "D", "d": begin morse_pattern = {NONE, NONE, DOT, DOT, DASH};  morse_len = 3; end
            "E", "e": begin morse_pattern = {NONE, NONE, NONE, NONE, DOT};  morse_len = 1; end
            "F", "f": begin morse_pattern = {NONE, DOT, DASH, DOT, DOT};  morse_len = 4; end
            "G", "g": begin morse_pattern = {NONE, NONE, DOT, DASH, DASH};  morse_len = 3; end
            "H", "h": begin morse_pattern = {NONE, DOT, DOT, DOT, DOT};  morse_len = 4; end
            "I", "i": begin morse_pattern = {NONE, NONE, NONE, DOT, DOT};  morse_len = 2; end
            "J", "j": begin morse_pattern = {NONE, DASH, DASH, DASH, DOT}; morse_len = 4; end
            "K", "k": begin morse_pattern = {NONE, NONE, DOT, DASH, DASH}; morse_len = 3; end
            "L", "l": begin morse_pattern = {NONE, DOT, DOT, DASH, DOT};  morse_len = 4; end
            "M", "m": begin morse_pattern = {NONE, NONE, NONE, DASH, DASH}; morse_len = 2; end
            "N", "n": begin morse_pattern = {NONE, NONE, NONE, DOT, DASH};  morse_len = 2; end
            "O", "o": begin morse_pattern = {NONE, NONE, DASH, DASH, DASH}; morse_len = 3; end
            "P", "p": begin morse_pattern = {NONE, DOT, DASH, DASH, DOT};  morse_len = 4; end
            "Q", "q": begin morse_pattern = {NONE, DOT, DASH, DASH, DASH}; morse_len = 4; end
            "R", "r": begin morse_pattern = {NONE, NONE, DOT, DASH, DOT};  morse_len = 3; end
            "S", "s": begin morse_pattern = {NONE, NONE, DOT, DOT, DOT};  morse_len = 3; end
            "T", "t": begin morse_pattern = {NONE, NONE, NONE, NONE, DASH}; morse_len = 1; end
            "U", "u": begin morse_pattern = {NONE, NONE, DASH, DOT, DOT};  morse_len = 3; end
            "V", "v": begin morse_pattern = {NONE, NONE, DASH, DOT, DOT};  morse_len = 4; end
            "W", "w": begin morse_pattern = {NONE, NONE, DASH, DASH, DOT};  morse_len = 3; end
            "X", "x": begin morse_pattern = {NONE, DASH, DOT, DOT, DASH};  morse_len = 4; end
            "Y", "y": begin morse_pattern = {NONE, DASH, DOT, DASH, DASH}; morse_len = 4; end
            "Z", "z": begin morse_pattern = {NONE, DOT, DOT, DASH, DASH};  morse_len = 4; end
            "0": begin morse_pattern = {DASH, DASH, DASH, DASH, DASH}; morse_len = 5; end
            "1": begin morse_pattern = {DASH, DASH, DASH, DASH, DOT};  morse_len = 5; end
            "2": begin morse_pattern = {DASH, DASH, DASH, DOT, DOT};   morse_len = 5; end
            "3": begin morse_pattern = {DASH, DASH, DOT, DOT, DOT};    morse_len = 5; end
            "4": begin morse_pattern = {DASH, DOT, DOT, DOT, DOT};     morse_len = 5; end
            "5": begin morse_pattern = {DOT, DOT, DOT, DOT, DOT};      morse_len = 5; end
            "6": begin morse_pattern = {DOT, DOT, DOT, DOT, DASH};     morse_len = 5; end
            "7": begin morse_pattern = {DOT, DOT, DOT, DASH, DASH};    morse_len = 5; end
            "8": begin morse_pattern = {DOT, DOT, DASH, DASH, DASH};   morse_len = 5; end
            "9": begin morse_pattern = {DOT, DASH, DASH, DASH, DASH};  morse_len = 5; end
            default: begin
                morse_pattern = 10'b0;
                morse_len = 0;
            end
        endcase
    end
endmodule