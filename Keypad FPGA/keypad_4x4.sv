module keypad_4x4 (
    input logic clk,
    input logic rst_n,
    input logic [3:0] col,
    output logic [3:0] row,
    output logic key_valid,
    output logic [3:0] key_code
);

    logic [1:0] row_idx;
    logic frame_valid;
    logic [3:0] frame_code;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            row_idx <= 2'd0;
        else
            row_idx <= row_idx + 2'd1;
    end

    always_comb begin
        row = 4'b1111;
        row[row_idx] = 1'b0;
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            key_valid   <= 1'b0;
            key_code    <= 4'h0;
            frame_valid <= 1'b0;
            frame_code  <= 4'h0;
        end else begin
            if (row_idx == 2'd0) begin
                key_valid   <= frame_valid;
                key_code    <= frame_code;
                frame_valid <= 1'b0;
            end

            case ({row_idx, col})
                6'b00_1110: begin frame_valid <= 1'b1; frame_code <= 4'h1; end
                6'b00_1101: begin frame_valid <= 1'b1; frame_code <= 4'h2; end
                6'b00_1011: begin frame_valid <= 1'b1; frame_code <= 4'h3; end
                6'b00_0111: begin frame_valid <= 1'b1; frame_code <= 4'hA; end

                6'b01_1110: begin frame_valid <= 1'b1; frame_code <= 4'h4; end
                6'b01_1101: begin frame_valid <= 1'b1; frame_code <= 4'h5; end
                6'b01_1011: begin frame_valid <= 1'b1; frame_code <= 4'h6; end
                6'b01_0111: begin frame_valid <= 1'b1; frame_code <= 4'hB; end

                6'b10_1110: begin frame_valid <= 1'b1; frame_code <= 4'h7; end
                6'b10_1101: begin frame_valid <= 1'b1; frame_code <= 4'h8; end
                6'b10_1011: begin frame_valid <= 1'b1; frame_code <= 4'h9; end
                6'b10_0111: begin frame_valid <= 1'b1; frame_code <= 4'hC; end

                6'b11_1110: begin frame_valid <= 1'b1; frame_code <= 4'hE; end
                6'b11_1101: begin frame_valid <= 1'b1; frame_code <= 4'h0; end
                6'b11_1011: begin frame_valid <= 1'b1; frame_code <= 4'hF; end
                6'b11_0111: begin frame_valid <= 1'b1; frame_code <= 4'hD; end
            endcase
        end
    end

endmodule