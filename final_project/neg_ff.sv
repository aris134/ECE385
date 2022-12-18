module neg_ff (input logic Reset, Trigger,
						output logic Q);
						
		always_ff @ (negedge Trigger or posedge Reset)
		begin
			if (Reset)
				Q <= 1'b0;
			else if (Trigger)
				Q <= 1'b1;
		end
endmodule