/****** alu.sv ******/
typedef enum logic [2:0]{
    ADD = 3'b000, 
    SUB = 3'b001,
    AND = 3'b010,
    OR =  3'b011,
    XOR = 3'b100,
    SHL = 3'b101,
    SHR = 3'b110,
    CMP = 3'b111
} sel_type;

module alu(
    input sel_type select,
    input [15:0] in_a,
    input [15:0] in_b,
    output reg [15:0] alu_out
);
    logic [15:0] res; 

    always @(*) begin
        case (select)
            ADD: res = in_a + in_b;
            SUB: res = in_a - in_b;
            AND: res = in_a & in_b;
            OR:  res = in_a | in_b;
            XOR: res = in_a ^ in_b;
            SHL: res = in_a << (in_b % 32); 
            SHR: res = in_a >> (in_b % 32); 
            CMP: begin
                if(in_a == in_b) begin
                    res = 0;
                end
                else if(in_a > in_b) begin
                    res = 1;
                end
                else begin
                    res = 2;
                end
            end
            default: res = 16'h0000; // Default value as 16-bit zero
        endcase
    end

    assign alu_out = res;

endmodule
