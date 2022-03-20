// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2022 Tamas Hubai

`default_nettype none

// pipeline takes 3 clock cycles

module square(
    input clk,
    input rst,
    input [6:0] x,
    input [6:0] y,
    input [2:0] style,
    input [4:0] letter,
    output reg [11:0] color    
    );

(* rom_style = "block" *)
reg [3:0] font [0:33695];
initial $readmemh("font.mem", font);

reg [5:0] p1_letter_x;
reg [5:0] p1_letter_y;
reg [4:0] p1_letter;
reg p1_border;
reg [2:0] p1_style;
always @(posedge clk) begin
    p1_letter_x <= 0;
    p1_letter_y <= 0;
    p1_letter <= 5'd0;
    if (x >= 7'd20 && x < 7'd56 && y >= 7'd20 && y < 7'd56 && letter < 5'd26) begin
        p1_letter_x <= x - 7'd20;
        p1_letter_y <= y - 7'd20;
        p1_letter <= letter;
        {p1_border, p1_style} <= {1'b0, style};
    end else if (x >= 7'd6 && x < 7'd70 && y >= 7'd6 && y < 7'd70) begin
        {p1_border, p1_style} <= {1'b0, style};
    end else if (x >= 7'd3 && x < 7'd73 && y >= 7'd3 && y < 7'd73) begin
        {p1_border, p1_style} <= {1'b1, style};
    end else begin
        {p1_border, p1_style} <= 4'b0100;
    end
end

reg [15:0] font_line;
reg [5:0] p2_letter_x;
reg [11:0] p2_color;
reg p2_redtext;
always @(posedge clk) begin
    font_line <= p1_letter * 16'd36 + p1_letter_y;
    p2_letter_x <= p1_letter_x;
    case (p1_style)
        3'b000: p2_color <= 12'ha44;
        3'b001: p2_color <= 12'h444;
        3'b010: p2_color <= 12'hba4;
        3'b011: p2_color <= 12'h595;
        3'b100, 3'b110: p2_color <= p1_border ? 12'h444 : 12'h000;
        3'b101, 3'b111: p2_color <= p1_border ? 12'h777 : 12'h000;        
        default: p2_color <= 12'h000;
    endcase
    p2_redtext <= (p1_style | 3'b001) == 3'b111;
end

reg [15:0] font_index;
reg [11:0] p3_color;
reg p3_redtext;
always @(posedge clk) begin
    font_index <= font_line * 16'd36 + p2_letter_x;
    p3_color <= p2_color;
    p3_redtext <= p2_redtext;
end

reg [3:0] font_pixel;
reg [3:0] p4_red;
reg [3:0] p4_green;
reg [3:0] p4_blue;
reg p4_redtext;
always @(posedge clk) begin
    font_pixel <= font[font_index];
    {p4_red, p4_green, p4_blue} <= p3_color;
    p4_redtext <= p3_redtext;
end

reg [3:0] font_pixel_weak;
reg [3:0] red;
reg [3:0] green;
reg [3:0] blue;
always @(posedge clk) begin
    font_pixel_weak = p4_redtext ? {1'b1, font_pixel[3:1]} : font_pixel;
    red = ~(({4'b0, ~p4_red} * {4'b0, font_pixel}) / 8'hf);
    green = ~(({4'b0, ~p4_green} * {4'b0, font_pixel_weak}) / 8'hf);
    blue = ~(({4'b0, ~p4_blue} * {4'b0, font_pixel_weak}) / 8'hf);
    color <= {red, green, blue};
end

endmodule
`default_nettype wire
