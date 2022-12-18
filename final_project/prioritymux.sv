module prioritymux (input Din0, Din1, Din2, Din3, Din4, Din5, Din6, Din7,
				 input [2:0] select,
				 input inactive,
				 output Dout);
				 
logic Dout_wire;
assign Dout = Dout_wire;
always @ (Din0 or Din1 or Din2 or Din3 or Din4 or
Din5 or Din6 or Din7 or inactive or select)		// inputs to mux
begin
	if (inactive)
		Dout_wire = 1'b1;
	else
	begin
	case(select)								// select truth table
	3'b000		:Dout_wire = Din0; 
	3'b001		:Dout_wire = Din1;
	3'b010		:Dout_wire = Din2;
	3'b011		:Dout_wire = Din3;
	3'b100		:Dout_wire = Din4;
	3'b101		:Dout_wire = Din5;
	3'b110		:Dout_wire = Din6;
	default  	:Dout_wire = Din7; 
	endcase
	end
end
endmodule 
