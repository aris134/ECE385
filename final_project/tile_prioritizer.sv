module tile_prioritizer (input Clk, Reset, LoadUB, LoadLB,
							 input [7:0] Attr0, Attr1, Attr2, Attr3, Attr4, Attr5, Attr6, Attr7,
							 //input [1:0] Palette0, Palette1, Palette2, Palette3, Palette4, Palette5, Palette6, Palette7, // not sure why I put this here
							 input Shift0, Shift1, Shift2, Shift3, Shift4, Shift5, Shift6, Shift7,
							 input [2:0] select,
							 input [7:0] Data_in,
							 output [4:0] Data_out,
							 output BGselect, SpriteZero);
							 
// logic wires
logic [1:0] reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7;
logic [2:0] mux_select;
logic [7:0] select_logic;
logic bgselect;							  
logic select_none;
assign BGselect = bgselect;
logic tile_loadUB0, tile_loadLB0, tile_loadUB1, tile_loadLB1, tile_loadUB2, tile_loadLB2, tile_loadUB3, tile_loadLB3,
		tile_loadUB4, tile_loadLB4, tile_loadUB5, tile_loadLB5, tile_loadUB6, tile_loadLB6, tile_loadUB7, tile_loadLB7;
assign SpriteZero = select_logic[7];

// decoders
decoder8 TileDecoderUB(.Din(LoadUB), .select(select),
								.Dout0(tile_loadUB0), .Dout1(tile_loadUB1), .Dout2(tile_loadUB2), .Dout3(tile_loadUB3),
								.Dout4(tile_loadUB4), .Dout5(tile_loadUB5), .Dout6(tile_loadUB6), .Dout7(tile_loadUB7));
								
decoder8 TileDecoderLB(.Din(LoadLB), .select(select),
								.Dout0(tile_loadLB0), .Dout1(tile_loadLB1), .Dout2(tile_loadLB2), .Dout3(tile_loadLB3),
								.Dout4(tile_loadLB4), .Dout5(tile_loadLB5), .Dout6(tile_loadLB6), .Dout7(tile_loadLB7));
								
// shift registers
shift_reg8 TileReg0UB(.*,.Load(tile_loadUB0),.Shift_Enable(Shift0),.Data_In(Data_in),.Data_Out(reg0[1]));
shift_reg8 TileReg0LB(.*,.Load(tile_loadLB0),.Shift_Enable(Shift0),.Data_In(Data_in),.Data_Out(reg0[0]));
shift_reg8 TileReg1UB(.*,.Load(tile_loadUB1),.Shift_Enable(Shift1),.Data_In(Data_in),.Data_Out(reg1[1]));
shift_reg8 TileReg1LB(.*,.Load(tile_loadLB1),.Shift_Enable(Shift1),.Data_In(Data_in),.Data_Out(reg1[0]));
shift_reg8 TileReg2UB(.*,.Load(tile_loadUB2),.Shift_Enable(Shift2),.Data_In(Data_in),.Data_Out(reg2[1]));
shift_reg8 TileReg2LB(.*,.Load(tile_loadLB2),.Shift_Enable(Shift2),.Data_In(Data_in),.Data_Out(reg2[0]));
shift_reg8 TileReg3UB(.*,.Load(tile_loadUB3),.Shift_Enable(Shift3),.Data_In(Data_in),.Data_Out(reg3[1]));
shift_reg8 TileReg3LB(.*,.Load(tile_loadLB3),.Shift_Enable(Shift3),.Data_In(Data_in),.Data_Out(reg3[0]));
shift_reg8 TileReg4UB(.*,.Load(tile_loadUB4),.Shift_Enable(Shift4),.Data_In(Data_in),.Data_Out(reg4[1]));
shift_reg8 TileReg4LB(.*,.Load(tile_loadLB4),.Shift_Enable(Shift4),.Data_In(Data_in),.Data_Out(reg4[0]));
shift_reg8 TileReg5UB(.*,.Load(tile_loadUB5),.Shift_Enable(Shift5),.Data_In(Data_in),.Data_Out(reg5[1]));
shift_reg8 TileReg5LB(.*,.Load(tile_loadLB5),.Shift_Enable(Shift5),.Data_In(Data_in),.Data_Out(reg5[0]));
shift_reg8 TileReg6UB(.*,.Load(tile_loadUB6),.Shift_Enable(Shift6),.Data_In(Data_in),.Data_Out(reg6[1]));
shift_reg8 TileReg6LB(.*,.Load(tile_loadLB6),.Shift_Enable(Shift6),.Data_In(Data_in),.Data_Out(reg6[0]));
shift_reg8 TileReg7UB(.*,.Load(tile_loadUB7),.Shift_Enable(Shift7),.Data_In(Data_in),.Data_Out(reg7[1]));
shift_reg8 TileReg7LB(.*,.Load(tile_loadLB7),.Shift_Enable(Shift7),.Data_In(Data_in),.Data_Out(reg7[0]));

// sprite pixel mux
mux8_5 PixelMux(.Din0({1'b1,Attr0[1:0],reg0}),.Din1({1'b1,Attr1[1:0],reg1}),.Din2({1'b1,Attr2[1:0],reg2}),.Din3({1'b1,Attr3[1:0],reg3}),
					 .Din4({1'b1,Attr4[1:0],reg4}),.Din5({1'b1,Attr5[1:0],reg5}),.Din6({1'b1,Attr6[1:0],reg6}),.Din7({1'b1,Attr7[1:0],reg7}),
					 .select(mux_select),.Dout(Data_out));
					 
// priority mux
prioritymux PriorityMux(.Din0(Attr0[5]),.Din1(Attr1[5]),.Din2(Attr2[5]),.Din3(Attr3[5]),
						 .Din4(Attr4[5]),.Din5(Attr5[5]),.Din6(Attr6[5]),.Din7(Attr7[5]),
						 .select(mux_select),
						 .inactive(select_none),.Dout(bgselect));
						 
// mux select logic
assign select_logic = {reg0[1] | reg0[0], reg1[1] | reg1[0], reg2[1] | reg2[0], reg3[1] | reg3[0],
							  reg4[1] | reg4[0], reg5[1] | reg5[0], reg6[1] | reg6[0], reg7[1] | reg7[0]};


always_comb
begin
select_none = 1'b0;
mux_select = 3'b000;
if (Attr0[5] == 1'b0 && Shift0)
	mux_select = 3'b000;
else
begin
if (Attr1[5] == 1'b0 && Shift1)
	mux_select = 3'b001;
else
begin
if (Attr2[5] == 1'b0 && Shift2)
	mux_select = 3'b010;
else
begin
if (Attr3[5] == 1'b0 && Shift3)
	mux_select = 3'b011;
else
begin
if (Attr4[5] == 1'b0 && Shift4)
	mux_select = 3'b100;
else
begin
if (Attr5[5] == 1'b0 && Shift5)
	mux_select = 3'b101;
else
begin
if (Attr6[5] == 1'b0 && Shift6)
	mux_select = 3'b110;
else if (Attr7[5] == 1'b0 && Shift7)
	mux_select = 3'b111;
else
	select_none = 1'b1;
end
end
end
end
end
end
end

endmodule