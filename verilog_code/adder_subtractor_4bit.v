`timescale 1ns / 1ps
// 4-bit Adder/Subtractor Module at Gate Level
module adder_subtractor_4bit (
    input [3:0] A,     // Operand A
    input [3:0] B,     // Operand B
    input Cin,         // Control: 0 for Add, 1 for Subtract
    output [3:0] Sum,  // Result
    output Cout        // Carry/Borrow Out
);
    wire [3:0] B_comp; // B after XOR with Cin
    wire [3:0] carry;  // Carry wires

    // Two's Complement for Subtraction
    assign B_comp = B ^ {4{Cin}};

    // Full Adder Instances
    full_adder fa0 (.A(A[0]), .B(B_comp[0]), .Cin(Cin),       .Sum(Sum[0]), .Cout(carry[0]));
    full_adder fa1 (.A(A[1]), .B(B_comp[1]), .Cin(carry[0]), .Sum(Sum[1]), .Cout(carry[1]));
    full_adder fa2 (.A(A[2]), .B(B_comp[2]), .Cin(carry[1]), .Sum(Sum[2]), .Cout(carry[2]));
    full_adder fa3 (.A(A[3]), .B(B_comp[3]), .Cin(carry[2]), .Sum(Sum[3]), .Cout(carry[3]));

    assign Cout = carry[3];
endmodule
