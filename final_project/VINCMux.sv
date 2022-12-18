module VINCMux (input [14:0] Din0, Din1, Din2,
				 input [1:0] select,
				 output [14:0] Dout);
				 
logic [14:0] Dout_wire;
assign Dout = Dout_wire;
always @ (Din0 or Din1 or Din2 or select)		// inputs to mux
begin
	case(select)								// select truth table
	2'b10		   :Dout_wire = Din2; 
	2'b11			:Dout_wire = Din1;
	default  	:Dout_wire = Din0; 
	endcase
end
endmodule 