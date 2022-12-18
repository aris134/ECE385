module mux9 (input Din0, Din1, Din2,Din3,Din4,Din5,Din6,Din7,Din8,
				 input [3:0] select,
				 output Dout);
				 
logic Dout_wire;
assign Dout = Dout_wire;
always @ (Din0 or Din1 or Din2 or Din3 or Din4 or Din5 or Din6 or Din7 or Din8 or select)		// inputs to mux
begin
	case(select)								// select truth table
	4'b0000		   :Dout_wire = Din0; 
	4'b0001			:Dout_wire = Din1;
	4'b0010			:Dout_wire = Din2;
	4'b0011			:Dout_wire = Din3;
	4'b0100			:Dout_wire = Din4;
	4'b0101			:Dout_wire = Din5;
	4'b0110			:Dout_wire = Din6;
	4'b0111			:Dout_wire = Din7;
	default  		:Dout_wire = Din8; 
	endcase
end
endmodule 