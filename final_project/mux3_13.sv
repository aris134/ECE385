module mux3_13 (input [12:0] Din0, Din1, Din2,
				 input [1:0] select,
				 output [12:0] Dout);
				 
logic [12:0] Dout_wire;
assign Dout = Dout_wire;
always @ (Din0 or Din1 or Din2 or select)		// inputs to mux
begin
	case(select)								// select truth table
	2'b00		   :Dout_wire = Din0; 
	2'b01			:Dout_wire = Din1;
	default  	:Dout_wire = Din2; 
	endcase
end
endmodule 