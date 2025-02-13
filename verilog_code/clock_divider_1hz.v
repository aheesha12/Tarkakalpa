`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/09/2025 03:29:32 PM
// Design Name: 
// Module Name: clock_divider_1hz
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


module clock_divider_1hz (
    input clk_in,      // 100 MHz input clock
    input reset,       // Reset signal (active high)
    output reg clk_out // 1 Hz output clock
);
    reg [25:0] counter; // 26-bit counter

    parameter DIVIDE_BY = 50000000; // Divide by 50,000,000

    always @(posedge clk_in or posedge reset) begin
        if (reset) begin
            counter <= 26'd0;
            clk_out <= 1'b0;
        end else begin
            if (counter == (DIVIDE_BY - 1)) begin
                counter <= 26'd0;
                clk_out <= ~clk_out;
            end else begin
                counter <= counter + 26'd1;
            end
        end
    end
endmodule
