// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2022 Tamas Hubai

`default_nettype none

module vga(
    input clk,
    input rst,
    output reg [10:0] x,
    output reg [10:0] y,
    output hsync,
    output vsync,
    output blank
    );

// 640 x 480 @ 60 Hz, 25.175 MHz pixel freq
parameter H_FPORCH = 11'd640;
parameter H_SYNC   = 11'd656;
parameter H_BPORCH = 11'd752;
parameter H_NEXT   = 11'd799;
parameter V_FPORCH = 11'd480;
parameter V_SYNC   = 11'd490;
parameter V_BPORCH = 11'd492;
parameter V_NEXT   = 11'd524;

always @(posedge clk) begin
    if (rst) begin
        x <= 0;
        y <= 0;
    end else begin
        if (x == H_NEXT) begin
            x <= 0;
            if (y == V_NEXT) begin
                y <= 0;
            end else begin
                y <= y+1;
            end
        end else begin
            x <= x+1;
        end
    end
end

// negate hsync & vsync for 640 x 480 @ 60 Hz standard mode
assign hsync = !(x >= H_SYNC && x < H_BPORCH);
assign vsync = !(y >= V_SYNC && y < V_BPORCH);
assign blank = x >= H_FPORCH || y >= V_FPORCH;

endmodule
`default_nettype wire
