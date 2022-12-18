module mux2_5 (input [4:0] Din0, Din1,
				   input select,
				   output [4:0] Dout);
				 
logic [4:0] Dout_wire;
assign Dout = Dout_wire;
always @ (Din0 or Din1 or select)		// inputs to mux
begin
	case(select)								// select truth table
	1'b0		:Dout_wire = Din0; 
	default  	:Dout_wire = Din1; 
	endcase
end
endmodule 