// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2022 Tamas Hubai

`default_nettype none

module wordlist(
    input clk,
    input rst,
    input [24:0] question,
    output reg ready,
    output reg valid,
    output reg [24:0] picked,
    output reg [11:0] picked_num
    );

parameter NUMWORDS = 16'd12653;
(* rom_style = "block" *)
reg [24:0] words [0:NUMWORDS-1];
initial $readmemh("wordlist.mem", words);

parameter NUMPICKS = 16'd1000;
(* rom_style = "block" *)
reg [13:0] picks [0:NUMPICKS-1];
initial $readmemh("picks.mem", picks);

reg [24:0] lastq;
reg [15:0] search_lo;
reg [15:0] search_hi;
reg [15:0] search;
reg [24:0] search_word;

wire [24:0] lq_rev = {lastq[4:0], lastq[9:5], lastq[14:10], lastq[19:15], lastq[24:20]};
wire [24:0] sw_rev = {search_word[4:0], search_word[9:5], search_word[14:10], search_word[19:15], search_word[24:20]};

reg [15:0] pick_index;
reg [15:0] word_index;

always @(posedge clk) begin
    ready <= 1'b0;
    valid <= 1'b0;
    if (rst) begin
        lastq <= 25'b0;
        search_lo = 16'b0;
        search_hi = NUMWORDS;
    end else if (question != lastq) begin
        lastq <= question;
        search_lo = 16'b0;
        search_hi = NUMWORDS;
    end else if (search_hi == search_lo) begin
        ready <= 1'b1;
        valid <= 1'b0;       
    end else if (search_hi == search_lo + 1) begin
        ready <= 1'b1;
        valid <= lastq == search_word;
    end else if (lq_rev < sw_rev) begin
        search_hi <= search;
    end else begin
        search_lo <= search;
    end
    if (ready) begin
        picked <= words[word_index];
        picked_num <= pick_index;
    end else begin
        search = (search_lo + search_hi) / 2;
        search_word <= words[search];
    end
end

reg [15:0] lfsr;
reg [15:0] shifted [16:0];
reg [15:0] next_pick_index;

reg [4:0] i;
always @(posedge clk) begin
    shifted[0] = lfsr;
    for (i=0; i<16; i=i+1) begin
        shifted[i+1] <= {shifted[i][14:0], ~^(shifted[i] & 16'h8016)};
    end
    lfsr <= shifted[16];
    next_pick_index <= ({16'b0, lfsr} * NUMPICKS) >> 16;
    pick_index <= next_pick_index;
    word_index <= picks[next_pick_index];
end

endmodule
`default_nettype wire
