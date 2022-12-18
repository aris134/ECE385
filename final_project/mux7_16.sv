module mux7_16 (input [15:0] Din0, Din1, Din2, Din3, Din4,Din5,Din6,
				 input [2:0] select,
				 output [15:0] Dout);
				 
logic [15:0] Dout_wire;
assign Dout = Dout_wire;
always @ (Din0 or Din1 or Din2 or Din3 or Din4 or Din5 or Din6 or select)	
begin
	case(select)								
	3'b000		:Dout_wire = Din0;					
	3'b001		:Dout_wire = Din1;
	3'b010		:Dout_wire = Din2;
	3'b011		:Dout_wire = Din3;
	3'b100		:Dout_wire = Din4;
	3'b101		:Dout_wire = Din5;
	default		:Dout_wire = Din6;					
	endcase
end
endmodule 