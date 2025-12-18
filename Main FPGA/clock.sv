module clock (
    input logic clk,
    input logic reset,
    input logic stop,
    output logic [9:0] seconds
);

logic [26:0] count;

always_ff @(posedge clk) begin
    if (!reset) begin
        count <= 27'd0;
        seconds <= 10'd0;
    end
    else if (count >= 27'd12000000) begin
        count <= 27'd0;
        seconds <= seconds + 1'b1;
    end
    else if (!stop) begin
        count <= count + 1'b1;
    end
end

endmodule
