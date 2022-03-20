// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2022 Tamas Hubai

`default_nettype none

module user_project (
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,

    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb,

    // IRQ
    output [2:0] irq
);

// clock & reset
wire clk = wb_clk_i;
wire rst = wb_rst_i;

// pin assignment
wire btn_up = io_in[12];
wire btn_left = io_in[13];
wire btn_right = io_in[14];
wire btn_down = io_in[15];
wire btn_guess = io_in[16];
wire btn_new = io_in[17];
wire [3:0] vga_red;
wire [3:0] vga_green;
wire [3:0] vga_blue;
wire vga_hsync;
wire vga_vsync;
assign io_out[17:0] = 18'b0;
assign io_out[21:18] = vga_red;
assign io_out[25:22] = vga_green;
assign io_out[29:26] = vga_blue;
assign io_out[30] = vga_hsync;
assign io_out[31] = vga_vsync;
assign io_out[37:32] = 6'b0;
assign io_oeb[17:0] = {18{1'b1}};  // input
assign io_oeb[31:18] = {14{1'b0}}; // output
assign io_oeb[37:32] = {6{1'b1}};  // input

// logic analyzer
// passed through to top_inst

// irq is unused
assign irq = 3'b0;

top top_inst (
    .clk(clk),
    .rst(rst),
    .btn_up(btn_up),
    .btn_left(btn_left),
    .btn_right(btn_right),
    .btn_down(btn_down),
    .btn_guess(btn_guess),
    .btn_new(btn_new),
    .la_data_in(la_data_in),
    .la_oenb(la_oenb),
    .vga_red(vga_red),
    .vga_green(vga_green),
    .vga_blue(vga_blue),
    .vga_hsync(vga_hsync),
    .vga_vsync(vga_vsync),
    .la_data_out(la_data_out)
);

endmodule
`default_nettype wire
