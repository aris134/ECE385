module mux5 (input Din0, Din1, Din2,Din3,Din4,
				 input [2:0] select,
				 output Dout);
				 
logic Dout_wire;
assign Dout = Dout_wire;
always @ (Din0 or Din1 or Din2 or Din3 or Din4 or select)		// inputs to mux
begin
	case(select)								// select truth table
	2'b000		   :Dout_wire = Din0; 
	2'b001			:Dout_wire = Din1;
	2'b010			:Dout_wire = Din2;
	2'b011			:Dout_wire = Din3;
	default			:Dout_wire = Din4;
	endcase
end
endmodule 