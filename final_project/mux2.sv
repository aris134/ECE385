module mux2 (input Din0, Din1,select,
				 output Dout);
				 
logic Dout_wire;
assign Dout = Dout_wire;
always @ (Din0 or Din1 or select)		// inputs to mux
begin
	case(select)								// select truth table
	1'b0		:Dout_wire = Din0; 
	default  	:Dout_wire = Din1; 
	endcase
end
endmodule 