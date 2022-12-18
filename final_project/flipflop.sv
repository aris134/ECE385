module flipflop
(
	input		Clk,
	input		Reset,
	input		D,
	output	Q
);

logic q;
assign Q = q;

always_ff @ (posedge Clk or posedge Reset)
begin
if (Reset)
	q <= 1'b0;
else
	q <= D;
end

endmodule