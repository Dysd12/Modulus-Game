module top (
    input  logic        rst_n,
    input  logic [3:0]  col,
    output logic [3:0]  row,
    output logic [3:0]  led
);
    logic clk_48MHz;

    SB_HFOSC #(
        .CLKHF_DIV("0b00")     // 48 MHz
    ) osc_inst (
        .CLKHFPU (1'b1),
        .CLKHFEN (1'b1),
        .CLKHF   (clk_48MHz)
    );

    logic [15:0] div_cnt;
    logic        scan_clk;

    always_ff @(posedge clk_48MHz or negedge rst_n) begin
        if (!rst_n) begin
            div_cnt  <= 16'd0;
            scan_clk <= 1'b0;
        end else if (div_cnt == 16'd23999) begin
            div_cnt  <= 16'd0;
            scan_clk <= ~scan_clk;
        end else begin
            div_cnt <= div_cnt + 1;
        end
    end

    logic        key_valid;
    logic [3:0]  key_code;

    keypad_4x4 u_keypad (
        .clk       (scan_clk),
        .rst_n     (rst_n),
        .col       (col),
        .row       (row),
        .key_valid (key_valid),
        .key_code  (key_code)
    );

    assign led = key_valid ? key_code : 4'b0000;

endmodule
