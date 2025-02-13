`timescale 1ns / 1ps
module full_adder (
    input A,
    input B,
    input Cin,
    output Sum,
    output Cout
);
    wire A_xor_B, A_and_B, A_xor_B_and_Cin;

    // Compute Sum
    xor (A_xor_B, A, B);
    xor (Sum, A_xor_B, Cin);

    // Compute Carry Out
    and (A_and_B, A, B);
    and (A_xor_B_and_Cin, A_xor_B, Cin);
    or  (Cout, A_and_B, A_xor_B_and_Cin);
endmodule
