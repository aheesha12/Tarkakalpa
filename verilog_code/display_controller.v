`timescale 1ns / 1ps
module display_controller (
    input clk,              // Clock for display multiplexing (e.g., 1 kHz)
    input rst,
    input [3:0] A,
    input [3:0] B,
    output reg [6:0] seg,
    output reg [3:0] an
);
    reg digit_select;        // Digit selector
    wire [6:0] seg_A, seg_B; // Segment patterns for A and B

    // Instantiate decoders for A and B
    seven_seg_decoder decoder_A (
        .binary_in(A),
        .seg_out(seg_A)
    );

    seven_seg_decoder decoder_B (
        .binary_in(B),
        .seg_out(seg_B)
    );

    // Toggle digit selection on each clock pulse
    always @(posedge clk or posedge rst) begin
        if (rst)
            digit_select <= 1'b0;
        else
            digit_select <= ~digit_select;
    end

    // Multiplexing logic
    always @(*) begin
        if (digit_select == 1'b0) begin
            seg = seg_A;
            an  = 4'b1110; // Activate AN0 (digit 0)
        end else begin
            seg = seg_B;
            an  = 4'b1101; // Activate AN1 (digit 1)
        end
     end
endmodule