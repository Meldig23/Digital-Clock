`timescale 1ns / 1ps

module buttons(input clk,input btn_in,output btn_out);

reg temp1,temp2,temp3;

always@(posedge clk)
    begin
        temp1<=btn_in;
        temp2<=temp1;
        temp3<=temp2;
    end

assign btn_out = temp3;    
endmodule