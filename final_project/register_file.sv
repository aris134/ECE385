module IO_register_file (input CPUClk,Clk, Reset, Load, Plus4, Plus1, OAMADDRCLR,VBLANK_set,VBLANK_clear,PaletteTrue,DMA_select,OAMAddrInc,
								 input [15:0] Address,
								 input [7:0] Data_in_CPU,VRAM_data,Palette_RAM_data,DMA_in,
								 output [7:0] Data_out,PPUCTRL_out,PPUMASK_out,PPUSTATUS_out,OAMDATA_out,PPUSCROLL_out,PPUADDR_out,PPUDATA_out,
								 output [7:0] DMA, OAMAddr,
								 output WT_clear,WT_load,Load2004,Load2005,Load2006,Load2007,VINC);

logic load_wire_PPU;//, load_wire_APU;
logic [7:0] Data_out_PPU;//, Data_out_APU;
logic PPU_Load0, PPU_Load1, PPU_Load2, PPU_Load3, PPU_Load4, PPU_Load5, PPU_Load6, PPU_Load7, OAMDMA_Load;
assign Load2004 = PPU_Load4;
logic [7:0] PPU_Out0, PPU_Out1, PPU_Out2, PPU_Out3, PPU_Out4, PPU_Out5, PPU_Out6, PPU_Out7, OAMDMA_Out;
logic [7:0] Dout,Data_in_2007,PPU_read_mux,Data_Buffer_out,OAMDATA_in,data_in_oamaddr;
logic v_inc;
logic wt_clear;
logic load_buffer,PPUSTATUS_true,OAMADDR_Clk;
logic [1:0] oamaddrmux_select;
assign oamaddrmux_select = {Plus4,(Plus1 | PPU_Load4 | DMA_select)};
logic clear_status;
logic vinc;
assign VINC = vinc;
assign DMA = OAMDMA_Out;
// register logic
assign WT_clear = wt_clear;
assign WT_load = PPU_Load5 | PPU_Load6;
assign Data_out = Dout;
assign Load2005 = PPU_Load5;
assign Load2006 = PPU_Load6;
assign Load2007 = PPU_Load7;
assign OAMAddr = PPU_Out3;
assign load_buffer = v_inc & ~PPU_Load7 & ~PaletteTrue;

assign PPUCTRL_out = PPU_Out0;
assign PPUMASK_out = PPU_Out1;
assign PPUSTATUS_out = PPU_Out2;
assign OAMDATA_out = PPU_Out4;
assign PPUSCROLL_out = PPU_Out5;
assign PPUADDR_out = PPU_Out6;
assign PPUDATA_out = PPU_Out7;

always_comb
begin
load_wire_PPU = 1'b0;
OAMDMA_Load = 1'b0;
v_inc = 1'b0;
PPUSTATUS_true = 1'b0;
if (Address < 16'h2007)
begin
	if (Address == 16'h2002 && Load == 1'b0)
		PPUSTATUS_true = 1'b1;
	load_wire_PPU = Load;
	Dout = Data_out_PPU;
end
else if (Address == 16'h2007)
begin
	load_wire_PPU = Load;
	v_inc = 1'b1;
	Dout = PPU_read_mux;
end
else
begin
	/*load_wire_APU = Load;
	Data_out = Data_out_APU;*/
	if (Address == 16'h4014)
	begin
	OAMDMA_Load = Load;
	Dout = OAMDMA_Out;
	end
	else
	Dout = 8'd0;
end
end

// PPU decoder
decoder8 PPUDecoder(.Din(load_wire_PPU), .select(Address[2:0]),
						  .Dout0(PPU_Load0), .Dout1(PPU_Load1), .Dout2(PPU_Load2), .Dout3(PPU_Load3),
						  .Dout4(PPU_Load4), .Dout5(PPU_Load5), .Dout6(PPU_Load6), .Dout7(PPU_Load7));
						  
// PPU mux
mux8 PPUMux(.Din0(PPU_Out0), .Din1(PPU_Out1), .Din2(PPU_Out2), .Din3(PPU_Out3),
				.Din4(PPU_Out4), .Din5(PPU_Out5), .Din6(PPU_Out6), .Din7(PPU_Out7),
				.select(Address[2:0]), .Dout(Data_out_PPU));
				
// PPUDATA muxes
mux2_8 PPUDATAMux(.Din0(VRAM_data),.Din1(Data_in_CPU),.select(PPU_Load7),.Dout(Data_in_2007));
mux2_8 PPUReadMux(.Din0(Palette_RAM_data),.Din1(Data_Buffer_out),.select(load_buffer),.Dout(PPU_read_mux));
mux2_8 OAMDATAMux(.Din0(Data_in_CPU),.Din1(DMA_in),.select(DMA_select),.Dout(OAMDATA_in));
mux3_8 OAMADDRMux(.Din0(Data_in_CPU),.Din1(PPU_Out3 + 8'h01),.Din2(PPU_Out3 + 8'h04),.select(oamaddrmux_select),.Dout(data_in_oamaddr));

// PPU registers
reg8 PPUCTRL(.*, .Load(PPU_Load0), .Data_In(Data_in_CPU), .Data_Out(PPU_Out0));
reg8 PPUMASK(.*, .Load(PPU_Load1), .Data_In(Data_in_CPU), .Data_Out(PPU_Out1));
reg2002 PPUSTATUS(.*, .Load(PPU_Load2), .PPUSTATUS_true(clear_status), .Data_In(Data_in_CPU), .Data_Out(PPU_Out2));
reg8 OAMADDR(.Clk(Clk),.Reset(Reset | OAMADDRCLR), .Load(PPU_Load3 | PPU_Load4 | Plus1 | Plus4 | OAMAddrInc),.Data_In(data_in_oamaddr), .Data_Out(PPU_Out3));
reg8 OAMDATA(.*, .Load(PPU_Load4 | DMA_select), .Data_In(OAMDATA_in), .Data_Out(PPU_Out4));
reg8 PPUSCROLL(.*, .Load(PPU_Load5), .Data_In(Data_in_CPU), .Data_Out(PPU_Out5));
reg8 PPUADDR(.*, .Load(PPU_Load6), .Data_In(Data_in_CPU), .Data_Out(PPU_Out6));
reg8 PPUDATA(.*, .Load(PPU_Load7), .Data_In(Data_in_2007), .Data_Out(PPU_Out7));

reg8 OAMDMA(.*, .Load(OAMDMA_Load), .Data_In(Data_in_CPU), .Data_Out(OAMDMA_Out));
reg8 PPUDataBuffer(.*,.Load(load_buffer),.Data_In(VRAM_data),.Data_Out(Data_Buffer_out));

enum logic [2:0] {VINCWait,VINCWait2,VINCWait3,VINCWait4,Assert} VINC_State,VINC_Next_state;
always_ff @ (posedge Clk or posedge Reset)
begin
	if (Reset)
		VINC_State <= VINCWait;
	else
		VINC_State <= VINC_Next_state;
end

always_comb
begin
VINC_Next_state = VINC_State;
unique case (VINC_State)
VINCWait:
	if (v_inc)
		VINC_Next_state <= VINCWait2;
VINCWait2:
	VINC_Next_state <= VINCWait3;
VINCWait3:
	VINC_Next_state <= VINCWait4;
VINCWait4:
	VINC_Next_state <= Assert;
Assert:
	if (~v_inc)
		VINC_Next_state <= VINCWait;
endcase
end

always_comb
begin
vinc = 1'b0;
case (VINC_State)
VINCWait,VINCWait2,VINCWait3,VINCWait4:;
Assert:
	vinc = 1'b1;
endcase
end

enum logic [2:0] {Wait, Count1,Count2,Count3,Count4,Count5,Count6} State, Next_state;

always_ff @ (posedge Clk or posedge Reset)
begin 
	if (Reset) 
		State <= Wait;
	else 
		State <= Next_state;
end

always_comb 
begin
Next_state = State; 
	
unique case (State)
Wait:
	if (PPUSTATUS_true)
		Next_state <= Count1;
Count1:
	Next_state <= Count2;
Count2:
	Next_state <= Count3;
Count3:
	Next_state <= Count4;
Count4:
	Next_state <= Count5;
Count5:
	Next_state <= Count6;
Count6:
	Next_state <= Wait;
endcase
end

always_comb
begin
clear_status = 1'b0;
case (State)
Wait,Count1,Count2,Count3,Count4,Count5:;
Count6:
	clear_status = 1'b1;
endcase
end

always_comb
begin
if ((PPU_Load2 == 1'b0) && (Address == 16'h2002))
	wt_clear = 1'b1;
else
	wt_clear = 1'b0;
end

endmodule