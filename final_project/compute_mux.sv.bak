module compute_mux (input [7:0] ORA, AND, EOR, ADC, SBC, LSR_A, LSR_M,
				 input [7:0] ROL_A, ROL_M, ROR_A, ROR_M, PASS_X, PASS_Y, PASS_M, PASS_A,
				 input [7:0] ASL_A, ASL_M, INC_X, INC_Y, INC_M, DEC_X, DEC_Y, DEC_M,
				 input [4:0] select,
				 output [7:0] Dout);
				 
logic [7:0] Dout_wire;
assign Dout = Dout_wire;
always @ (ORA or AND or EOR or ADC or SBC or
LSR_A or LSR_M or ROL_A or ROL_M or ROR_M or ROR_A or select)		// inputs to mux
begin
	case(select)								
	5'b00000		:Dout_wire = ORA; 
	5'b00001		:Dout_wire = AND;
	5'b00010		:Dout_wire = EOR;
	5'b00011		:Dout_wire = ADC;
	5'b00100		:Dout_wire = SBC;
	5'b00101		:Dout_wire = LSR_A;
	5'b00110		:Dout_wire = LSR_M;
	5'b00111		:Dout_wire = ROL_A;
	5'b01000		:Dout_wire = ROL_M;
	5'b01001		:Dout_wire = ROR_A;
	5'b01010		:Dout_wire = ROR_M;
	5'b01011		:Dout_wire = PASS_X;
	5'b01100		:Dout_wire = PASS_Y;
	5'b01101		:Dout_wire = PASS_M;
	5'b01110		:Dout_wire = PASS_A;
	5'b01111		:Dout_wire = ASL_A;
	5'b10000		:Dout_wire = ASL_M;
	5'b10001		:Dout_wire = INC_X;
	5'b10010		:Dout_wire = INC_Y;
	5'b10011		:Dout_wire = INC_M;
	5'b10100		:Dout_wire = DEC_X;
	5'b10101		:Dout_wire = DEC_Y;
	default  	:Dout_wire = DEC_M;
	endcase
end
endmodule 