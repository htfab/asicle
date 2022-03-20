// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2022 Tamas Hubai

`default_nettype none

module debounce(
    input clk,
    input rst,
    input [5:0] raw,
    output reg [5:0] debounced,
    output reg [5:0] pos_edge
    );

reg [17:0] counter;
reg [5:0] last;

always @(posedge clk) begin
    if (rst) begin
        debounced <= 6'b0;
        pos_edge <= 6'b0;
        counter <= 18'b0;
        last <= 6'b0;
    end else begin
        pos_edge <= 6'b0;
        if (!counter) begin
            pos_edge <= raw & last & ~debounced;
            debounced <= ((raw | last) & debounced) | (raw & last);
            last <= raw;
        end
        counter <= counter + 1;
    end
end

endmodule
`default_nettype wire
