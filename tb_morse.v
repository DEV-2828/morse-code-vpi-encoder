// tb_morse.v
`timescale 1ns/1ps

module tb_morse;

    reg  [7:0] char_in;
    wire [9:0] morse_pattern;
    wire [2:0] morse_len;

    morse_encoder dut (
        .char_in(char_in),
        .morse_pattern(morse_pattern),
        .morse_len(morse_len)
    );

    task $print_morse;
        input [9:0] pattern;
        input [2:0] len;
    endtask

    initial begin
        $display("Converting: 'SOS 123'");
        $display("Morse Code: ");

        char_in = "S"; #1; $print_morse(morse_pattern, morse_len);
        char_in = "O"; #1; $print_morse(morse_pattern, morse_len);
        char_in = "S"; #1; $print_morse(morse_pattern, morse_len);
        char_in = " "; #1; $print_morse(morse_pattern, morse_len);
        char_in = "1"; #1; $print_morse(morse_pattern, morse_len);
        char_in = "2"; #1; $print_morse(morse_pattern, morse_len);
        char_in = "3"; #1; $print_morse(morse_pattern, morse_len);

        $display("\nSimulation finished.");
        $finish;
    end

endmodule
