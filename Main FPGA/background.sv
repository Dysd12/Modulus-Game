/* background_gen.sv
 * Parameter: None
 * Input: visible signal, column and row positions
 * Description: This module generates background pixel data based on the
 *              current column and row positions. It uses a ROM module to
 *              retrieve pixel data for the background image.
 * Output: bg_rgb - 6-bit background pixel data
 */
module bg_display (
    input  logic [9:0] col,
    input  logic [9:0] row,
    output logic [5:0] rgb
);
    logic [7:0] bg_x; 
    logic [6:0] bg_y;
    logic [14:0] address; 
    logic [7:0] mem [0:19119];

    /* Makes every BG pixel span 4 rows and 4 cols on the 640x480 display. */
    assign bg_x = col[9:2];
    assign bg_y = row[9:2];
    assign address = bg_y * 160 + bg_x; 
    assign rgb = mem[address][5:0];

    initial begin
        $readmemh("mem File/bg2.mem", mem);
    end

endmodule