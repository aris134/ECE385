module x_counter_file (input Clk, Reset, Load, Start,
							  input [2:0] select,
							  input [7:0] Data_in,
							  input [9:0] dot,
							  output Shift0, Shift1, Shift2, Shift3,
										Shift4, Shift5, Shift6, Shift7);
										
// load and shift signals
logic shift_load0, shift_load1, shift_load2, shift_load3, shift_load4, shift_load5, shift_load6, shift_load7;
logic shift_out0, shift_out1, shift_out2, shift_out3, shift_out4, shift_out5, shift_out6, shift_out7;

assign Shift0 = shift_out0;
assign Shift1 = shift_out1;
assign Shift2 = shift_out2;
assign Shift3 = shift_out3;
assign Shift4 = shift_out4;
assign Shift5 = shift_out5;
assign Shift6 = shift_out6;
assign Shift7 = shift_out7;

// counter decoder
decoder8 CounterDecoder(.Din(Load), .select(select),
								.Dout0(shift_load0), .Dout1(shift_load1), .Dout2(shift_load2), .Dout3(shift_load3),
								.Dout4(shift_load4), .Dout5(shift_load5), .Dout6(shift_load6), .Dout7(shift_load7));
								
// counter registers - figure out what start is connected to
tile_decrementor8 Counter0(.*,.dot(dot),.Load(shift_load0),.Data_In(Data_in),.Shift_Signal(shift_out0));
tile_decrementor8 Counter1(.*,.dot(dot),.Load(shift_load1),.Data_In(Data_in),.Shift_Signal(shift_out1));
tile_decrementor8 Counter2(.*,.dot(dot),.Load(shift_load2),.Data_In(Data_in),.Shift_Signal(shift_out2));
tile_decrementor8 Counter3(.*,.dot(dot),.Load(shift_load3),.Data_In(Data_in),.Shift_Signal(shift_out3));
tile_decrementor8 Counter4(.*,.dot(dot),.Load(shift_load4),.Data_In(Data_in),.Shift_Signal(shift_out4));
tile_decrementor8 Counter5(.*,.dot(dot),.Load(shift_load5),.Data_In(Data_in),.Shift_Signal(shift_out5));
tile_decrementor8 Counter6(.*,.dot(dot),.Load(shift_load6),.Data_In(Data_in),.Shift_Signal(shift_out6));
tile_decrementor8 Counter7(.*,.dot(dot),.Load(shift_load7),.Data_In(Data_in),.Shift_Signal(shift_out7));

endmodule