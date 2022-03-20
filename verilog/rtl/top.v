// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2022 Tamas Hubai

`default_nettype none

module top(
    input clk,
    input rst,
    input btn_up,
    input btn_left,
    input btn_right,
    input btn_down,
    input btn_guess,
    input btn_new,
    input [127:0] la_data_in,
    input [127:0] la_oenb,
    output [3:0] vga_red,
    output [3:0] vga_green,
    output [3:0] vga_blue,
    output vga_hsync,
    output vga_vsync,
    output [127:0] la_data_out
    );

wire [239:0] status;

control control_inst (
    .clk(clk),
    .rst(rst),
    .btn_up(btn_up),
    .btn_left(btn_left),
    .btn_right(btn_right),
    .btn_down(btn_down),
    .btn_guess(btn_guess),
    .btn_new(btn_new),
    .debug_in(la_data_in[55:0]),
    .debug_in_mask(~la_oenb[55:0]),
    .status(status),
    .debug_out(la_data_out[102:0])
);

display display_inst (
    .clk(clk),
    .rst(rst),
    .status(status),
    .red(vga_red),
    .green(vga_green),
    .blue(vga_blue),
    .hsync(vga_hsync),
    .vsync(vga_vsync),
    .debug_out(la_data_out[127:103])
);

endmodule
`default_nettype wire
