module modulus_check (
    input logic [6:0] dividend,
    input logic [3:0] divisor,
    input logic [3:0] answer,
    output logic is_correct
);

always_comb begin
    if (dividend % divisor == answer) is_correct = 1'b1;
    else is_correct = 1'b0;
end

endmodule