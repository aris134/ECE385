module decoder8 (input Din,
				 input [2:0] select,
				 output Dout0, Dout1, Dout2, Dout3, Dout4, Dout5, Dout6, Dout7);

logic Din_wire;
assign Din_wire = Din;
logic D0,D1,D2,D3,D4,D5,D6,D7;
assign Dout0 = D0;
assign Dout1 = D1;
assign Dout2 = D2;
assign Dout3 = D3;
assign Dout4 = D4;
assign Dout5 = D5;
assign Dout6 = D6;
assign Dout7 = D7;
always @ (Din_wire or select)		// inputs to mux
begin
	D0 = 0;
	D1 = 0;
	D2 = 0;
	D3 = 0;
	D4 = 0;
	D5 = 0;
	D6 = 0;
	D7 = 0;
	case(select)								// select truth table
	3'b000		:D0 = Din_wire;
	3'b001		:D1 = Din_wire;
	3'b010		:D2 = Din_wire;
	3'b011		:D3 = Din_wire;
	3'b100		:D4 = Din_wire;
	3'b101		:D5 = Din_wire;
	3'b110		:D6 = Din_wire;
	default  	:D7 = Din_wire;
	endcase
end
endmodule 
