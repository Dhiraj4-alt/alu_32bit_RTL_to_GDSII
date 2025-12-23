// alu_32bit_tb.v
// Testbench for alu_32bit
`timescale 1ns/1ps

module alu_32bit_tb;

    reg  [31:0] A, B;
    reg  [2:0]  opcode;
    wire [31:0] result;
    wire        zero, carry_out, overflow;

    // Instantiate DUT
    alu_32bit dut (
        .A(A), .B(B), .opcode(opcode),
        .result(result), .zero(zero),
        .carry_out(carry_out), .overflow(overflow)
    );

    initial begin
        $dumpfile("alu_32bit.vcd");
        $dumpvars(0, alu_32bit_tb);

        // 1) ADD
        A = 32'd5; B = 32'd3; opcode = 3'b000; #10;

        // 2) SUB
        A = 32'd5; B = 32'd7; opcode = 3'b001; #10;

        // 3) AND
        A = 32'hF0F0F0F0; B = 32'h0FF00FF0; opcode = 3'b010; #10;

        // 4) OR
        opcode = 3'b011; #10;

        // 5) XOR
        opcode = 3'b100; #10;

        // 6) NAND
        opcode = 3'b101; #10;

        // 7) NOT (unary)
        A = 32'h0000F0F0; B = 32'h0; opcode = 3'b110; #10;

        // 8) PASS A
        A = 32'h12345678; opcode = 3'b111; #10;

        $finish;
    end

endmodule
