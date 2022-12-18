module flip_flop (input logic Clk, Reset, Load, D,
						output logic Q);
logic q;
assign Q = q;
		always_ff @ (posedge Clk or posedge Reset)
		begin
			if (Reset)
				q <= 1'b0;
			else if (Load)
				q <= D;
		end
endmodule