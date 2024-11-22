module top(input rst, input clk, input x, output reg y);

reg [1:0] ps,ns;
parameter S0='b00, S1=2'b01,S2=2'b10,S3=2'b11;

initial ps<=S0;

always@(posedge clk)
begin
if(rst)
ps<=S0;
else
ps<=ns;
end

always@(ps or x)
begin

case(ps)
S0: begin ns=(x==1)?S1:S0;
          y=0; end
S1: begin ns=(x==1)?S2:S3;
          y=(x==1)?1:0; end
S2: begin ns=(x==1)?S2:S3;
          y=1; end
S3: begin ns=(x==1)?S1:S0;
          y=(x==1)?1:0; end
default : begin ns=S0; y=0; end
endcase
end

endmodule
