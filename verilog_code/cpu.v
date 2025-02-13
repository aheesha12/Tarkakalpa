`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ECE-VCET
// Engineer: G A AHEESHA SHABARAYA
// 
// Create Date: 02/09/2025 10:25:09 AM
// Design Name: 
// Module Name: cpu
// Project Name: Tarkakalpa
// Target Devices: 
// Tool Versions: FPGA BASYS 3
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


// CPU Module with Extended Instruction Set
module cpu (
    input clk,
    input rst,
    input [7:0] instruction,   // 8-bit instruction: [7:4] opcode,
    input [3:0] immediate,
    output [6:0] seg,      // Seven-segment display segments
    output [3:0] an,        // Seven-segment display anodes
    //output reg [3:0] R1,       // Register 1
    //output reg [3:0] R2,       // Register 2
    output reg Z_flag,         // Zero Flag
    output reg C_flag,         // Carry Flag
    output reg N_flag          // Negative Flag
);
    //reg [3:0] immediate;       // Immediate value extracted from instruction
    reg [3:0] alu_in1, alu_in2;
    wire [3:0] alu_result;
    wire alu_carry_out;
    reg alu_sel;               // ALU Control: 0 for addition, 1 for subtraction
    reg [3:0] R1,R2;
    reg [3:0] memory [0:15];   // 4-bit memory with 16 locations
    wire clk_1hz, clk_display;

    // Instantiate the 4-bit Adder/Subtractor
    adder_subtractor_4bit alu_unit (
        .A(alu_in1),
        .B(alu_in2),
        .Cin(alu_sel),
        .Sum(alu_result),
        .Cout(alu_carry_out)
    );
    
    //1hz clock for manupulation
    clock_divider_1hz clk_div_1hz (
        .clk_in(clk),
        .reset(rst),
        .clk_out(clk_1hz)
    );
    
    // Instantiate the 1 kHz clock divider for display
        clock_divider_1khz clk_div_display (
            .clk_in(clk),
            .reset(rst),
            .clk_out(clk_display)
        );
        
      // Instantiate the display controller using clk_display
      display_controller display_inst (
            .clk(clk_display),
            .rst(rst),
            .A(R1),
            .B(R2),
            .seg(seg),
            .an(an)
        );
        
    // Task to Update Flags
    task update_flags;
        input [3:0] result;
        input cout;
        begin
            Z_flag = (result == 4'b0000);  // Zero Flag
            C_flag = cout;                 // Carry/Borrow Flag
            N_flag = result[3];            // Negative Flag (MSB)
        end
    endtask

    // Instruction Decode and Execution
    always @(posedge clk_1hz or posedge rst) begin
        if (rst) begin
            // Reset Registers and Flags
            R1 <= 4'b0000;
            R2 <= 4'b0000;
            Z_flag <= 1'b0;
            C_flag <= 1'b0;
            N_flag <= 1'b0;
        end else begin
            // Extract Immediate from Instruction
            //immediate = instruction[3:0];
            case (instruction[7:0])
                // Copy Instructions
                8'b0000_0000: begin // 0x00: #IMM COPY R1
                    R1 <= immediate;
                    update_flags(R1, 1'b0);
                end
                8'b0000_0001: begin // 0x01: R2 COPY R1
                    R1 <= R2;
                    update_flags(R1, 1'b0);
                end
                8'b0000_0010: begin // 0x02: R1 COPY R2
                    R2 <= R1;
                    update_flags(R2, 1'b0);
                end
                8'b0000_0011: begin // 0x03: #IMM COPY R2
                    R2 <= immediate;
                    update_flags(R2, 1'b0);
                end

                // Fetch Pointer Instructions
                8'b0000_0101: begin // 0x05: [R2] FETCHPTR R1
                    R1 <= memory[R2];
                    update_flags(R1, 1'b0);
                end
                8'b0000_0110: begin // 0x06: [R1] FETCHPTR R2
                    R2 <= memory[R1];
                    update_flags(R2, 1'b0);
                end

                // Write Pointer Instructions
                8'b0000_1001: begin // 0x09: R1 WRTPTR [R2]
                    memory[R2] <= R1;
                end
                8'b0000_1010: begin // 0x0A: R2 WRTPTR [R1]
                    memory[R1] <= R2;
                end

                // PLUSI Instructions
                default: begin
                    case (instruction[7:4])
                        4'b0001: begin // PLUSI (Addition)
                            alu_sel = 1'b0; // Select Addition
                            case (instruction[3:0])
                                4'b0001: begin // 0x11: R1 = R1 + R2
                                    alu_in1 = R1;
                                    alu_in2 = R2;
                                    R1 <= alu_result;
                                    update_flags(alu_result, alu_carry_out);
                                end
                                4'b0010: begin // 0x12: R2 = R2 + R1
                                    alu_in1 = R2;
                                    alu_in2 = R1;
                                    R2 <= alu_result;
                                    update_flags(alu_result, alu_carry_out);
                                end
                                4'b0000: begin // 0x10: R1 = R1 + #IMM
                                    alu_in1 = R1;
                                    alu_in2 = immediate;
                                    R1 <= alu_result;
                                    update_flags(alu_result, alu_carry_out);
                                end
                                4'b0011: begin // 0x13: R2 = R2 + #IMM
                                    alu_in1 = R2;
                                    alu_in2 = immediate;
                                    R2 <= alu_result;
                                    update_flags(alu_result, alu_carry_out);
                                end
                            endcase
                        end

                        // DIFF Instructions
                        4'b0010: begin // DIFF (Subtraction)
                            alu_sel = 1'b1; // Select Subtraction
                            case (instruction[3:0])
                                4'b0000: begin // 0x20: R1 = R1 - #IMM
                                    alu_in1 = R1;
                                    alu_in2 = immediate;
                                    R1 <= alu_result;
                                    update_flags(alu_result, alu_carry_out);
                                end
                                4'b0011: begin // 0x23: R2 = R2 - #IMM
                                    alu_in1 = R2;
                                    alu_in2 = immediate;
                                    R2 <= alu_result;
                                    update_flags(alu_result, alu_carry_out);
                                end
                                4'b0001: begin // 0x21: R1 = R1 - R2
                                    alu_in1 = R1;
                                    alu_in2 = R2;
                                    R1 <= alu_result;
                                    update_flags(alu_result, alu_carry_out);
                                end
                                4'b0010: begin // 0x22: R2 = R2 - R1
                                    alu_in1 = R2;
                                    alu_in2 = R1;
                                    R2 <= alu_result;
                                    update_flags(alu_result, alu_carry_out);
                                end
                            endcase
                        end
                        default: ; // No Operation
                    endcase
                end
            endcase
        end
    end
endmodule


