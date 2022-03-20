// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2022 Tamas Hubai

`default_nettype none

// pipeline takes 5 clock cycles

module frame(
    input clk,
    input rst,
    input [10:0] x,
    input [10:0] y,
    input [239:0] status,
    output [11:0] color
    );

reg [10:0] shift_x;
reg [10:0] shift_y;
reg [2:0] col;
reg [2:0] line;
reg [7:0] index;
reg [6:0] sub_x;
reg [6:0] sub_y;
reg valid;
always @(posedge clk) begin
    if (x >= 11'd130 && x < 11'd510 && y >= 11'd12 && y < 11'd468) begin
        shift_x = x - 11'd130;
        shift_y = y - 11'd12;
        col = shift_x / 11'd76;
        line = shift_y / 11'd76;
        index <= line * 8'd40 + col * 8'd8;
        sub_x <= shift_x % 11'd76;
        sub_y <= shift_y % 11'd76;
        valid <= 1'b1;
    end else begin
        shift_x = 11'd0;
        shift_y = 11'd0;
        col = 3'd0;
        line = 3'd0;
        index <= 8'd0;
        sub_x <= 7'd0;
        sub_y <= 7'd0;
        valid <= 1'b0;
    end   
end

reg [2:0] style;
reg [4:0] letter;
reg [6:0] p2_sub_x;
reg [6:0] p2_sub_y;
always @(posedge clk) begin
    if (valid) begin
        {style, letter} <= status[index +: 8];
    end else begin
        {style, letter} <= 8'h1f;
    end
    p2_sub_x <= sub_x;
    p2_sub_y <= sub_y;
end

wire [11:0] square_color;
square square_inst (
    .clk(clk),
    .rst(rst),
    .x(p2_sub_x),
    .y(p2_sub_y),
    .style(style),
    .letter(letter),
    .color(color)
);

endmodule
`default_nettype wire
