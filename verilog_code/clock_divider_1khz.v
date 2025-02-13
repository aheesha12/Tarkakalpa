`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/09/2025 03:30:58 PM
// Design Name: 
// Module Name: clock_divider_1khz
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module clock_divider_1khz (
    input clk_in,      // 100 MHz input clock
    input reset,       // Reset signal (active high)
    output reg clk_out // 1 kHz output clock
);
    reg [16:0] counter; // 17-bit counter to count up to 50,000

    parameter DIVIDE_BY = 50000; // Divide by 50,000

    always @(posedge clk_in or posedge reset) begin
        if (reset) begin
            counter <= 17'd0;
            clk_out <= 1'b0;
        end else begin
            if (counter == (DIVIDE_BY - 1)) begin
                counter <= 17'd0;
                clk_out <= ~clk_out; // Toggle the output clock
            end else begin
                counter <= counter + 17'd1;
            end
        end
    end
endmodule