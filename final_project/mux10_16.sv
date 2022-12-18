module mux10_16 (input [15:0] Din0, Din1, Din2, Din3, Din4,Din5,Din6,Din7,Din8,Din9,
				 input [3:0] select,
				 output [15:0] Dout);
				 
logic [15:0] Dout_wire;
assign Dout = Dout_wire;
always @ (Din0 or Din1 or Din2 or Din3 or Din4 or Din5 or Din6 or Din7 or Din8 or Din9 or select)	
begin
	case(select)								
	4'b0000		:Dout_wire = Din0;					
	4'b0001		:Dout_wire = Din1;
	4'b0010		:Dout_wire = Din2;
	4'b0011		:Dout_wire = Din3;
	4'b0100		:Dout_wire = Din4;
	4'b0101		:Dout_wire = Din5;
	4'b0110		:Dout_wire = Din6;
	4'b0111		:Dout_wire = Din7;
	4'b1000		:Dout_wire = Din8;
	default  	:Dout_wire = Din9;					
	endcase
end
endmodule 