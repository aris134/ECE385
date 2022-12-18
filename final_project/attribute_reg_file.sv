module attribute_reg_file (input Clk, Reset, Load,
									input [2:0] select,
									input [7:0] Data_in,
									output [7:0] Dout0, Dout1, Dout2, Dout3,
													 Dout4, Dout5, Dout6, Dout7);

// load signals
logic attr_load0, attr_load1, attr_load2, attr_load3, attr_load4, attr_load5, attr_load6, attr_load7;

// attribute decoder
decoder8 AttrDecoder(.Din(Load), .select(select),
						  .Dout0(attr_load0), .Dout1(attr_load1), .Dout2(attr_load2), .Dout3(attr_load3),
						  .Dout4(attr_load4), .Dout5(attr_load5), .Dout6(attr_load6), .Dout7(attr_load7));

// attribute registers
reg8 Sprite0(.*,.Load(attr_load0),.Data_In(Data_in),.Data_Out(Dout0));
reg8 Sprite1(.*,.Load(attr_load1),.Data_In(Data_in),.Data_Out(Dout1));
reg8 Sprite2(.*,.Load(attr_load2),.Data_In(Data_in),.Data_Out(Dout2));
reg8 Sprite3(.*,.Load(attr_load3),.Data_In(Data_in),.Data_Out(Dout3));
reg8 Sprite4(.*,.Load(attr_load4),.Data_In(Data_in),.Data_Out(Dout4));
reg8 Sprite5(.*,.Load(attr_load5),.Data_In(Data_in),.Data_Out(Dout5));
reg8 Sprite6(.*,.Load(attr_load6),.Data_In(Data_in),.Data_Out(Dout6));
reg8 Sprite7(.*,.Load(attr_load7),.Data_In(Data_in),.Data_Out(Dout7));

endmodule