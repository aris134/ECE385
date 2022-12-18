module counter3 (input Clk, Reset, Increment,
					  output [2:0] Data_out);
					  
logic [2:0] count;
assign Data_out = count;

always_ff @ (posedge Clk or posedge Reset)
begin
if (Reset)
	count <= 3'b000;
else if (Increment)
	count <= count + 1'b1;
end

endmodule