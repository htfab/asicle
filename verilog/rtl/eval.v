// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2022 Tamas Hubai

`default_nettype none

module eval(
    input clk,
    input rst,
    input [24:0] guess,
    input [24:0] solution,
    output reg [9:0] colors
    );

reg [4:0] green;
reg [4:0] yellow;
reg [2:0] count_guess;
reg [2:0] count_solution;
reg [2:0] i;
reg [2:0] j;
always @(posedge clk) begin
    for (i=0; i<5; i=i+1) begin
        green[i] = guess[5*i +: 5] == solution[5*i +: 5];
    end
    for (i=0; i<5; i=i+1) begin
        count_guess = 3'b001;
        count_solution = 3'b000;
        for (j=0; j<5; j=j+1) begin
            if (j != i && !green[j] && guess[5*i +: 5] == solution[5*j +: 5]) begin
                count_solution = count_solution + 1;
            end
            if(j < i && !green[j] && guess[5*i +: 5] == guess[5*j +: 5]) begin
                count_guess = count_guess + 1;
            end
        end
        yellow[i] = !green[i] && count_solution >= count_guess;
    end
    for (i=0; i<5; i=i+1) begin
        colors[2*i +: 2] <= {green[i] || yellow[i], green[i] || !yellow[i]};
    end  
end

endmodule
`default_nettype wire
