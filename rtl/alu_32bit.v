// alu_32bit.v
// 32-bit ALU with arithmetic + logical operations
// opcode mapping:
// 000 : ADD
// 001 : SUB
// 010 : AND
// 011 : OR
// 100 : XOR
// 101 : NAND
// 110 : NOT (unary, uses only A)
// 111 : PASS A (useful for testing)

module alu_32bit (
    input  wire [31:0] A,
    input  wire [31:0] B,
    input  wire  [2:0] opcode,
    output reg  [31:0] result,
    output reg         zero,
    output reg         carry_out,
    output reg         overflow
);

    // Wide add/sub for carry detection
    wire [32:0] add_sum = {1'b0, A} + {1'b0, B};
    wire [32:0] sub_sum = {1'b0, A} - {1'b0, B};

    always @(*) begin
        // defaults
        result    = 32'b0;
        zero      = 1'b0;
        carry_out = 1'b0;
        overflow  = 1'b0;

        case (opcode)
            3'b000: begin // ADD
                result    = add_sum[31:0];
                carry_out = add_sum[32];
                overflow  = (A[31] == B[31]) && (result[31] != A[31]);
            end

            3'b001: begin // SUB
                result    = sub_sum[31:0];
                carry_out = sub_sum[32];
                overflow  = (A[31] != B[31]) && (result[31] != A[31]);
            end

            3'b010: result = A & B;           // AND
            3'b011: result = A | B;           // OR
            3'b100: result = A ^ B;           // XOR
            3'b101: result = ~(A & B);        // NAND
            3'b110: result = ~A;              // NOT (unary)
            3'b111: result = A;               // PASS A

            default: result = 32'b0;
        endcase

        zero = (result == 32'b0);
    end

endmodule
