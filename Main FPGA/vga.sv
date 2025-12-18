/*
 * Updates the col and row every clock cycle.
 * Assigns hsync, vsync, and visible at the appropriate col and row position.
 */

module vga(
    input  logic clk,
    output logic hsync,
    output logic vsync,
    output logic [9:0] col,
    output logic [9:0] row,
    output logic visible
);

    // column position
    always_ff @(posedge clk) begin
        if (col == 799)
            col <= 0;
        else
            col <= col + 1;
    end

    // row position
    always_ff @(posedge clk) begin
        if (col == 799) begin
            if (row == 524)
                row <= 0;
            else
                row <= row + 1;
        end
    end

    // sync signals
    assign hsync = ~((col >= 656) && (col < 752));
    assign vsync = ~((row >= 490) && (row < 492));
    assign visible = (col < 640) && (row < 480);

endmodule

/**
 * PLL configuration
 *
 * This Verilog module was generated automatically
 * using the icepll tool from the IceStorm project.
 * Use at your own risk.
 *
 * Given input frequency:        12.000 MHz
 * Requested output frequency:   25.175 MHz
 * Achieved output frequency:    25.125 MHz
 */

module mypll(
	input  clock_in,
	output clock_out,
	output locked
	);

SB_PLL40_CORE #(
		.FEEDBACK_PATH("SIMPLE"),
		.DIVR(4'b0000),		// DIVR =  0
		.DIVF(7'b1000010),	// DIVF = 66
		.DIVQ(3'b101),		// DIVQ =  5
		.FILTER_RANGE(3'b001)	// FILTER_RANGE = 1
	) uut (
		.LOCK(locked),
		.RESETB(1'b1),
		.BYPASS(1'b0),
		.REFERENCECLK(clock_in),
		.PLLOUTCORE(clock_out)
		);

endmodule




