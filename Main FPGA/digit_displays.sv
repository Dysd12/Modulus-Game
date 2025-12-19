module one_digit_display #(
    parameter int X0 = 0, // X coordinate of the top left corner
    parameter int Y0 = 0, // Y coordinate of the top left corner
    parameter int W = 20, // Width of the number sprite
    parameter int H = 30 // Height of the number sprite
)(
    input logic [9:0]  col,
    input logic [9:0]  row,
    input logic [3:0]  digit,
    output logic       on,
    output logic [5:0] rgb
);
    logic [4:0]  sprite_x; // 2^5 = 32
    logic [4:0]  sprite_y; // 2^5 = 32
    logic [9:0]  sprite_index; // 2^10 = 1024
    logic [12:0] address; // 2^13 = 8192
    logic [7:0]  mem [0:5999];

    /* Checks if the sprite is inside the box. */
    assign on = (col >= X0) && (col < X0 + W) && (row >= Y0) && (row < Y0 + H);
    // Get the local coords inside the sprite
    assign sprite_x = col - X0;
    assign sprite_y = row - Y0;
    /* Gets the pixel index inside the (20x30) sprite  */
    assign sprite_index = sprite_y * 5'd20 + sprite_x;
    /* Navigates to the address in mem file. Each number takes 600 bytes */
    assign address = digit * 15'd600 + sprite_index;
    /* Accesses RGB values for sprites 0-9 from mem. */
    assign rgb = mem[address][5:0];

    initial begin
        $readmemh("mem File/digits_trans.mem", mem);
    end
    
endmodule

module two_digit_display #(
    parameter int X0 = 0,
    parameter int Y0 = 0
)(
    input  logic [9:0] col,
    input  logic [9:0] row,
    input  logic [6:0] value, // 2^7 = 128
    output logic       on,
    output logic [5:0] rgb
);
    /* Splits the number into 2 digits. */
    logic [3:0] tens_value, ones_value;
    logic tens_on, ones_on;
    logic [5:0] tens_rgb, ones_rgb;

    assign tens_value = value / 10;
    assign ones_value = value % 10;

    one_digit_display #(.X0(X0), .Y0(Y0)) u_tens (
        .col   (col),
        .row   (row),
        .digit (tens_value),
        .on    (tens_on),
        .rgb   (tens_rgb)
    );
    one_digit_display #(.X0(X0 + 20), .Y0(Y0)) u_ones (
        .col   (col),
        .row   (row),
        .digit (ones_value),
        .on    (ones_on),
        .rgb   (ones_rgb)
    );

    always_comb begin
        on  = 1'b0;
        rgb = 6'd0;

        if (tens_on) begin
            on  = 1'b1;
            rgb = tens_rgb;
        end else if (ones_on) begin
            on  = 1'b1;
            rgb = ones_rgb;
        end
    end

endmodule

module three_digit_display #(
    parameter int X0 = 0,
    parameter int Y0 = 0
)(
    input  logic [9:0] col,
    input  logic [9:0] row,
    input  logic [9:0] value, // 2^10 = 1024
    output logic       on,
    output logic [5:0] rgb
);
    /* Split the number into 3 digits. */
    logic [3:0] hundreds_value, tens_value, ones_value;
    logic hundreds_on, tens_on, ones_on;
    logic [5:0] hundreds_rgb, tens_rgb, ones_rgb;

    assign hundreds_value = value / 100;
    assign tens_value     = (value / 10) % 10;
    assign ones_value     = value % 10;

    one_digit_display #(.X0(X0), .Y0(Y0)) u_hundreds (
        .col        (col),
        .row        (row),
        .digit      (hundreds_value),
        .on         (hundreds_on),
        .rgb        (hundreds_rgb)
    );
    one_digit_display #(.X0(X0 + 20), .Y0(Y0)) u_tens (
        .col        (col),
        .row        (row),
        .digit      (tens_value),
        .on         (tens_on),
        .rgb        (tens_rgb)
    );
    one_digit_display #(.X0(X0 + 40), .Y0(Y0)) u_ones (
        .col        (col),
        .row        (row),
        .digit      (ones_value),
        .on         (ones_on),
        .rgb        (ones_rgb)
    );

    always_comb begin
        on  = 1'b0;
        rgb = 6'd0;

        if (hundreds_on) begin
            on  = 1'b1;
            rgb = hundreds_rgb;
        end else if (tens_on) begin
            on  = 1'b1;
            rgb = tens_rgb;
        end else if (ones_on) begin
            on  = 1'b1;
            rgb = ones_rgb;
        end
    end

endmodule