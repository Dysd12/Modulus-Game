module health (
    input logic clk,
    input logic reset,
    input logic [26:0] health_rate, 
    input logic add_health,

    output logic [6:0] current_health,
    output logic no_health
);

logic [26:0] count;

always_comb begin
    if (current_health == 4'd0) no_health = 1'b1;
    else                        no_health = 1'b0;
end

always_ff @(posedge clk) begin
    /* Handles Reset first */
    if (!reset) begin
        current_health <= 7'd20;
        count <= 27'd0;
    end
    else begin
        /* Counter Logic */
        if (count >= health_rate) count <= 27'd0;
        else count <= count + 1'b1;

        /* Handle Health Logic */
        if (add_health) begin
            current_health <= current_health + 1'b1;
        end
        else if (count >= health_rate) 
            if (current_health > 4'd0) 
                current_health <= current_health - 1'b1;
        
        else 
            current_health <= current_health;
    end
end
endmodule

