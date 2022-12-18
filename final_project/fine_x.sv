module fine_x (input Clk, Reset, IncX,Load2005,WT_out,
					input [2:0] Scroll3,
					output [2:0] Count);
					
logic [2:0] count;
assign Count = count;

always_ff @ (posedge Clk or posedge Reset)
begin
if (Reset)
	count <= 3'b000;
else if (IncX)
	count <= count + 1'b1;
else if (WT_out == 1'b0 && Load2005 == 1'b1)
	count <= Scroll3;
end
endmodule