`timescale 1ns / 1ps
module clkDivider(clk, clkout);
input clk;
output reg clkout=0;

reg [31:0] count = 0;

always@(posedge clk)
begin
    if (count == 49999999)
    //if (count == 9)
    begin
        clkout <= ~clkout;
        count <= 0;
    end
    else
        count <= count + 1;
end
endmodule