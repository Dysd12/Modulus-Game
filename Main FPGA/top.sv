module top (
    input logic clk_12MHz,
    input logic reset,
    input logic [3:0] keypad_input,
    input logic check_answer,

    output logic [5:0] rgb,
    output logic hsync,
    output logic vsync
);

/* ============================= VGA SETUP ================================== */
/* Converts the FPGA's internal 12Mhz clock to a 25Mhz clock for 60Hz VGA*/
logic clk_25MHz;
mypll u_pll (
    .clock_in(clk_12MHz),
    .clock_out(clk_25MHz), 
    .locked()
);
/* Updates hsync and vsync to be output to the VGA monitor. 
   Increments col and row, and updates visible for the pattern_gen module. */
logic [9:0] col;
logic [9:0] row;
logic visible;
vga u_vga (
    .clk(clk_25MHz),
    .hsync(hsync),
    .vsync(vsync),
    .col(col),
    .row(row),
    .visible(visible)
);
/* ========================================================================== */


/* ============= DECLARING FSM STATES AND INTERNAL VARIABLES ================ */
/* States for the FSM. */
typedef enum logic [1:0] {
    ST_INITIALIZE, 
    ST_GEN_PROBLEM, 
    ST_WAIT_ANSWER, 
    ST_GAME_OVER
} game_state;
game_state current_state, next_state;

/* Health Management */
logic [26:0] deduct_rate;
logic [6:0] current_health;
logic answer_correct;
logic gain_health;
logic health_zero;

/* Clock Management */
logic [9:0] seconds;

/* Number Generation */
logic [6:0] dividend, ran_dividend, ran_temp_divisor;
logic [3:0] divisor, ran_divisor;
/* ========================================================================== */


/* ================== Sequential and Combinational Logic ==================== */
always_ff @(posedge clk_12MHz) begin
    if (!reset) begin
        current_state <= ST_INITIALIZE;
        deduct_rate <= 27'd36000000;
        dividend <= 7'd0;
        divisor <= 4'd0;
    end else begin
        current_state <= next_state;
    end

    if (current_state == ST_GEN_PROBLEM) begin
        dividend <= ran_dividend;
        divisor <= ran_divisor;
    end
end

always_comb begin
    next_state = current_state;
    gain_health = 1'b0;
    /* Makes sure ran_divisor is between 2-9. */
    ran_divisor = (ran_temp_divisor[2:0] == 3'd0) ? 4'd8 :
                  (ran_temp_divisor[2:0] == 3'd1) ? 4'd9 :
                  {1'b0, ran_temp_divisor[2:0]};

    /* State Logic */
    case (current_state)
        /* Start of game. */
        ST_INITIALIZE:  next_state = ST_GEN_PROBLEM;

        /* Generate the random numbers */
        ST_GEN_PROBLEM: next_state = ST_WAIT_ANSWER;
        /* Wait in this state for an answer. */
        ST_WAIT_ANSWER: begin
            if (health_zero) begin
                next_state = ST_GAME_OVER;
            end else begin
                if (!check_answer && answer_correct) begin
                    next_state = ST_GEN_PROBLEM;
                    gain_health = 1'b1;
                end
            end
        end
        /* End of Game. */
        ST_GAME_OVER:
    endcase

    /* Display Logic. */
    rgb = 6'd0;
    if (visible) begin
        rgb = bg_rgb;
        if (clock_on)         rgb = clock_rgb;
        else if (health_on)   rgb = health_rgb;
        else if (dividend_on) rgb = dividend_rgb;
        else if (divisor_on)  rgb = divisor_rgb;
        else if (keypad_on)   rgb = keypad_rgb;
    end
end
/* ========================================================================== */


/* ============================== Modules =================================== */
/* -------------------------- Game Logic Modules ---------------------------- */
/* Clock Module: Simple clock to show how long the game has been going on. */
clock u_clock (
    .clk(clk_12MHz),
    .reset(reset),
    .stop(health_zero),
    .seconds(seconds)
);

/* Health Module: Manages health by decrementing over time and incrementing. */
health u_health (
    .clk(clk_12MHz),
    .reset(reset),
    .health_rate(deduct_rate),
    .add_health(gain_health),
    .current_health(current_health),
    .no_health(health_zero)
);

/* Modulus Module: Checks if keypad input is correct for given problem. */
modulus_check u_mod_check (
    .dividend(dividend),
    .divisor(divisor),
    .answer(keypad_input),
    .is_correct(answer_correct)
);

/* RNG Module: Generates random 2-digit numbers for the dividend and divisor. */
rng u_rng_dividend (
    .clk           (clk_12MHz),
    .seed          (7'b1010101),
    .random_number (ran_dividend)
);
rng u_rng_divisor (
    .clk           (clk_12MHz),
    .seed          (7'b0110011),
    .random_number (ran_temp_divisor)
);

/* -------------------------- Display Modules ------------------------------- */
/* Background Display. */
logic [5:0] bg_rgb;
bg_display u_bg_display (
    .col (col),
    .row (row),
    .rgb (bg_rgb)
);

/* Clock Three Digit Display. */
logic clock_on;
logic [5:0] clock_rgb;
three_digit_display #(.X0(80), .Y0(37)) u_clock_display (
    .col   (col),
    .row   (row),
    .value (seconds),
    .on    (clock_on),
    .rgb   (clock_rgb)
);

/* Health Two Digit Display. */
logic health_on;
logic [5:0] health_rgb;
two_digit_display #(.X0(80), .Y0(87)) u_health_display (
    .col   (col),
    .row   (row),
    .value (current_health),
    .on    (health_on),
    .rgb   (health_rgb)
);

/* Dividend Two Digit Display. */
logic dividend_on;
logic [5:0] dividend_rgb;
two_digit_display #(.X0(70), .Y0(210)) u_dividend_display (
    .col   (col),
    .row   (row),
    .value (dividend),
    .on    (dividend_on),
    .rgb   (dividend_rgb)
);

/* Divisor One Digit Display. */
logic divisor_on;
logic [5:0] divisor_rgb;
one_digit_display #(.X0(200), .Y0(210)) u_divisor_display (
    .col   (col),
    .row   (row),
    .digit (divisor),
    .on    (divisor_on),
    .rgb   (divisor_rgb)
);

/* Keypad Input One Digit Display. */
logic keypad_on;
logic [5:0] keypad_rgb;
one_digit_display #(.X0(350), .Y0(210)) u_keypad_display (
    .col   (col),
    .row   (row),
    .digit (keypad_input), 
    .on    (keypad_on),
    .rgb   (keypad_rgb)
);
/* ========================================================================== */

endmodule
