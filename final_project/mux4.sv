module mux4 (input [7:0] Din0, Din1, Din2, Din3,
				 input [1:0] select,
				 output [7:0] Dout);
				 
logic [7:0] Dout_wire;
assign Dout = Dout_wire;
always @ (Din0 or Din1 or Din2 or Din3 or select)	
begin
	case(select)								
	2'b00		:Dout_wire = Din0;					
	2'b01		:Dout_wire = Din1;
	2'b10		:Dout_wire = Din2;
	default  :Dout_wire = Din3;					
	endcase
end
endmodule 