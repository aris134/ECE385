module counter4 (input Clk, Reset, Increment, Decrement,
					  output [3:0] Data_out);
					  
logic [3:0] count;
assign Data_out = count;

always_ff @ (posedge Clk or posedge Reset)
begin
if (Reset)
	count <= 4'b0000;
else if (Increment)
	count <= count + 1'b1;
else if (Decrement)
	count <= count - 1'b1;
end

endmodule