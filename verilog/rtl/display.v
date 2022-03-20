// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2022 Tamas Hubai

`default_nettype none

module display(
    input clk,
    input rst,
    input [239:0] status,
    output reg [3:0] red,
    output reg [3:0] green,
    output reg [3:0] blue,
    output reg hsync,
    output reg vsync,
    output [24:0] debug_out
    );

wire clk_vga = clk;

wire [10:0] vga_x;
wire [10:0] vga_y;
wire vga_hsync;
wire vga_vsync;
wire vga_blank;
vga vga_inst (
    .clk(clk_vga),
    .rst(rst),
    .x(vga_x),
    .y(vga_y),
    .hsync(vga_hsync),
    .vsync(vga_vsync),
    .blank(vga_blank)  
);

wire [11:0] frame_color;
frame frame_inst (
    .clk(clk),
    .rst(rst),
    .x(vga_x),
    .y(vga_y),
    .status(status),
    .color(frame_color)
);

reg [4:0] hsync_pipe;
reg [4:0] vsync_pipe;
reg [3:0] blank_pipe;
reg frame_blank;
always @(posedge clk) begin
    {hsync, hsync_pipe} <= {hsync_pipe, vga_hsync};
    {vsync, vsync_pipe} <= {vsync_pipe, vga_vsync};
    {frame_blank, blank_pipe} <= {blank_pipe, vga_blank};
    if (frame_blank) begin
        {red, green, blue} <= 12'h000;
    end else begin
        {red, green, blue} <= frame_color;
    end
end

assign debug_out[10:0] = vga_x;
assign debug_out[21:11] = vga_y;
assign debug_out[22] = vga_hsync;
assign debug_out[23] = vga_vsync;
assign debug_out[24] = vga_blank;

endmodule
`default_nettype wire
