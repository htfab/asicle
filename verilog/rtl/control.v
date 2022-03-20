// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2022 Tamas Hubai

`default_nettype none

module control(
    input clk,
    input rst,
    input btn_up,
    input btn_left,
    input btn_right,
    input btn_down,
    input btn_guess,
    input btn_new,
    input [55:0] debug_in,
    input [55:0] debug_in_mask,
    output reg [239:0] status,
    output [102:0] debug_out
    );

wire btn_up_db, btn_left_db, btn_right_db, btn_down_db, btn_guess_db, btn_new_db;
wire btn_up_pe, btn_left_pe, btn_right_pe, btn_down_pe, btn_guess_pe, btn_new_pe;
debounce debounce_inst (
    .clk(clk),
    .rst(rst),
    .raw({btn_up, btn_left, btn_right, btn_down, btn_guess, btn_new}),
    .debounced({btn_up_db, btn_left_db, btn_right_db, btn_down_db, btn_guess_db, btn_new_db}),
    .pos_edge({btn_up_pe, btn_left_pe, btn_right_pe, btn_down_pe, btn_guess_pe, btn_new_pe})
);

reg [24:0] word;
reg [14:0] style;
reg [2:0] hindex;
reg [2:0] vindex;

wire word_full = ~word[24:20] && ~word[19:15] && ~word[14:10] && ~word[9:5] && ~word[4:0];
wire wl_ready;
wire wl_valid;
wire [24:0] wl_picked;
wire [11:0] wl_picked_num;

wordlist wordlist_inst (
    .clk(clk),
    .rst(rst),
    .question(word),
    .ready(wl_ready),
    .valid(wl_valid),
    .picked(wl_picked),
    .picked_num(wl_picked_num)
);

reg [24:0] solution;
reg [11:0] solution_num;
reg solution_delayed;

wire [9:0] colors;
eval eval_inst (
    .clk(clk),
    .rst(rst),
    .guess(word),
    .solution(solution),
    .colors(colors)
);

reg new_game;
reg finished;
always @(posedge clk) begin
    new_game <= rst | btn_new_pe;
end

always @(posedge clk) begin
    if (new_game) begin
        solution = 25'b0;
        solution_num = ~12'b0;
        solution_delayed = 1'b1;
    end else if (solution_delayed && word_full) begin
        solution = wl_picked;
        solution_num = wl_picked_num;    
        solution_delayed = 1'b0;
    end
    solution = (solution & ~debug_in_mask[55:31]) | (debug_in[55:31] & debug_in_mask[55:31]);
end

reg advance;
reg nonword;
reg [4:0] cur_letter;
reg [2:0] i;
always @(posedge clk) begin
    if (new_game) begin
        word = {5{5'b11111}};
        style = {{4{3'b100}}, 3'b101};
        hindex = 3'b0;
        vindex = 3'b0;
        finished = 1'b0;
        advance = 1'b0;
        nonword = 1'b0;
    end else if (finished) begin
       // do nothing
    end else if (advance) begin
        advance = 1'b0;
        if (vindex == 5 || style == {5{3'b011}}) begin
            finished = 1'b1;
        end else begin
            vindex = (vindex + 1) % 3'd6;
            hindex = 0;
            word = {5{5'b11111}};
            style = {{4{3'b100}}, 3'b101};
            nonword = 1'b0;
        end            
    end else if (btn_guess_pe && word_full && wl_ready && wl_valid) begin
        style = {1'b0, colors[9:8], 1'b0, colors[7:6], 1'b0, colors[5:4],
                  1'b0, colors[3:2], 1'b0, colors[1:0]}; 
        advance = 1'b1;    
    end else begin
        advance = 1'b0;
        if (btn_guess_pe) begin
            nonword = 1'b1;
        end
        if (btn_up_pe) begin
            cur_letter = word[5'd5 * hindex +: 5];
            if (cur_letter == 5'b11111) begin
                cur_letter = 5'b11001;
            end else begin
                cur_letter = cur_letter - 1;
            end
            word[5'd5 * hindex +: 5] = cur_letter;
            nonword = 1'b0;
        end
        if (btn_down_pe) begin
            cur_letter = word[5'd5 * hindex +: 5];
            if (cur_letter == 5'b11001) begin
                cur_letter = 5'b11111;
            end else begin
                cur_letter = cur_letter + 1;
            end
            word[5'd5 * hindex +: 5] = cur_letter;
            nonword = 1'b0;
        end
        if (btn_right_pe) begin
            if (hindex < 3'd4) begin
                style[5'd3 * hindex] = 1'b0;
                style[5'd3 * hindex + 5'd3] = 1'b1;
                hindex = hindex + 1;
            end
        end
        if (btn_left_pe) begin
            if (hindex > 3'd0) begin
                style[5'd3 * hindex] = 1'b0;
                style[5'd3 * hindex - 5'd3] = 1'b1;
                hindex = hindex - 1;
            end
        end
        if (nonword) begin
            for (i=0; i<5; i=i+1) begin
                style[5'd3 * i + 5'd1] = 1'b1;
            end
        end else begin
            for (i=0; i<5; i=i+1) begin
                style[5'd3 * i + 5'd1] = 1'b0;
            end
        end
    end
    vindex = (vindex & ~debug_in_mask[2:0]) | (debug_in[2:0] & debug_in_mask[2:0]);
    hindex = (hindex & ~debug_in_mask[5:3]) | (debug_in[5:3] & debug_in_mask[5:3]);
    word = (word & ~debug_in_mask[30:6]) | (debug_in[30:6] & debug_in_mask[30:6]);
end

always @(posedge clk) begin
    if (new_game) begin
        status <= {30{8'b10011111}};
    end else begin
        status[8'd40 * vindex +: 40] <= {
            style[14:12], word[24:20],
            style[11:9], word[19:15],
            style[8:6], word[14:10],
            style[5:3], word[9:5],
            style[2:0], word[4:0]};
    end
end

assign debug_out[2:0] = vindex;
assign debug_out[5:3] = hindex;
assign debug_out[30:6] = word;
assign debug_out[55:31] = solution;
assign debug_out[62:56] = solution_num[6:0];
assign debug_out[72:63] = colors;
assign debug_out[73] = word_full;
assign debug_out[74] = wl_ready;
assign debug_out[75] = wl_valid;
assign debug_out[76] = finished;
assign debug_out[77] = advance;
assign debug_out[78] = nonword;
assign debug_out[79] = new_game;
assign debug_out[80] = solution_delayed;
assign debug_out[96:81] = status[15:0];
assign debug_out[97] = btn_up_db;
assign debug_out[98] = btn_left_db;
assign debug_out[99] = btn_right_db;
assign debug_out[100] = btn_down_db;
assign debug_out[101] = btn_guess_db;
assign debug_out[102] = btn_new_db;

endmodule
`default_nettype wire
