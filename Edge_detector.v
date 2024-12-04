module top_module (
    input clk,
    input [7:0] in,
    output [7:0] anyedge
);
    initial
        begin
            temp=0;
            anyedge=0;
        end
    reg [7:0] temp;
    always@(posedge clk)
        begin
            anyedge<=(~temp&in)|(temp&~in);
            temp<=in;
        end
endmodule
