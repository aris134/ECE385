module PPURender (input Clk, Reset, HBLANK,x_decrement,shift_b,shift_a,load_c_lb,load_c_ub,load_b,attr_latch_ld,RenderingDisabled,display,
						input [7:0] SOAM, CHR_ROM, AT, OAM, OAMADDR, PPUMASK,
						input [9:0] Dot_Counter, Line_Counter,
						input [2:0] CoarseX, CoarseY,
						output [4:0] Pixel_address,SOAMPtr,
						output [1:0] SOAMMuxSelect,
						output Zero_hit,Plus1,Plus4,WriteSOAM,OAMADDRCLR,YRegLoad,
						output SOAMCHRSelect,FineYInc);
						
// state machine states
enum logic [3:0] {Wait, Init0, Init1, InitPtr, Eval, Write1, Write2, Write3, Check,
						FetchWait, TileFetch1, TileFetch2, AttrFetch, XFetch, SOAMClear} State, Next_state;
						
// logic wires
logic shift0,shift1,shift2,shift3,shift4,shift5,shift6,shift7;
logic [7:0] attr0,attr1,attr2,attr3,attr4,attr5,attr6,attr7;
logic x_load,file_load,bg_select,sprite_zero_tile,sprite_increment,sprite_decrement,fine_y_inc;
logic overflow_reset,soam_ptr_clear,soam_ptr_set,soam_ptr_plus1,soam_ptr_plus2;
logic soam_chr_select;
logic [2:0] file_select;
logic [3:0] sprite_count;
logic [4:0] spriteBM,BGBM,soam_ptr_out;
logic [7:0] PDC0out,PDC1out,PDA0out,PDA1out;
logic PDB0out,PDB1out,plusone,plusfour;
logic [1:0] palette_select,attr_latch_out;
assign BGBM = {1'b0,attr_latch_out,PDA1out[7],PDA0out[7]};
assign SOAMPtr = soam_ptr_out;
assign FineYInc = fine_y_inc;

// logic
logic szff_out;
assign Zero_hit = szff_out;
logic s0;
assign s0 = shift0 & sprite_zero_tile & (PDA1out || PDA0out) & ~szff_out;

logic tile_ld_UB,tile_ld_LB,tile_reset,write_soam,oamaddr_plus1,oamaddr_plus4,oamaddr_clr,Yregload;
logic [1:0] soam_mux_select;
assign SOAMMuxSelect = soam_mux_select;
assign WriteSOAM = write_soam;
assign Plus1 = oamaddr_plus1;
assign Plus4 = oamaddr_plus4;
assign OAMADDRCLR = oamaddr_clr;
assign YRegLoad = Yregload;
assign SOAMCHRSelect = soam_chr_select;

// modules
tile_prioritizer TilePrioritizer(.*,.Reset(Reset | tile_reset),.LoadUB(tile_ld_UB),.LoadLB(tile_ld_LB),
											.Attr0(attr0),.Attr1(attr1),.Attr2(attr2),.Attr3(attr3),
											.Attr4(attr4),.Attr5(attr5),.Attr6(attr6),.Attr7(attr7),
											.Shift0(shift0 & display),.Shift1(shift1 & display),.Shift2(shift2 & display),.Shift3(shift3 & display),
											.Shift4(shift4 & display),.Shift5(shift5 & display),.Shift6(shift6 & display),.Shift7(shift7 & display),
											.select(file_select),.Data_in(CHR_ROM),.Data_out(spriteBM),.BGselect(bg_select),.SpriteZero(sprite_zero_tile));
x_counter_file CounterFile(.*,.Load(x_load),.Start(x_decrement),.select(file_select),.Data_in(SOAM),.dot(Dot_Counter),
									.Shift0(shift0),.Shift1(shift1),.Shift2(shift2),.Shift3(shift3),
									.Shift4(shift4),.Shift5(shift5),.Shift6(shift6),.Shift7(shift7));
attribute_reg_file SpriteAttributes(.*,.Load(file_load),.select(file_select),.Data_in(SOAM),
												.Dout0(attr0),.Dout1(attr1),.Dout2(attr2),.Dout3(attr3),
												.Dout4(attr4),.Dout5(attr5),.Dout6(attr6),.Dout7(attr7));
mux2_5 PriorityMux(.Din0(spriteBM),.Din1(BGBM),.select(bg_select & PPUMASK[3] | ~(spriteBM[1] | spriteBM[0])),.Dout(Pixel_address));
reg8 PatternDataC0(.*,.Load(load_c_lb),.Data_In(CHR_ROM),.Data_Out(PDC0out));
reg8 PatternDataC1(.*,.Load(load_c_ub),.Data_In(CHR_ROM),.Data_Out(PDC1out));
shift_reg8 PatternDataB0(.*,.Load(load_b),.Shift_Enable(shift_b),.Data_In(PDC0out),.Data_Out(PDB0out));
shift_reg8 PatternDataB1(.*,.Load(load_b),.Shift_Enable(shift_b),.Data_In(PDC1out),.Data_Out(PDB1out));
shiftin_reg8 PatternDataA0(.*,.Load(shift_a),.Data_In(PDB0out),.Data_Out(PDA0out));
shiftin_reg8 PatternDataA1(.*,.Load(shift_a),.Data_In(PDB1out),.Data_Out(PDA1out));
PaletteSelect PaletteSelector(.*,.Palette_Attribute(AT),.Latches(palette_select));
reg2 PaletteLatch(.*,.Load(attr_latch_ld),.Data_In(palette_select),.Data_Out(attr_latch_out));

counter4 SpriteCounter(.*,.Increment(sprite_increment),.Decrement(sprite_decrement),.Data_out(sprite_count));
counter3 SpriteIncrementor(.*,.Reset(Reset | soam_ptr_clear),.Increment(sprite_decrement),.Data_out(file_select));
SOAMPTR SOAMpointer(.Clk(Clk),.Reset(Reset | soam_ptr_clear),.Set1(soam_ptr_set),.Plus1(soam_ptr_plus1),.Plus2(soam_ptr_plus2),.Data_Out(soam_ptr_out));


flip_flop SpriteZeroFF(.*,.Load(~szff_out),.D(s0),.Q(szff_out));

// state machine transitions
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
		if (Dot_Counter == 10'd0 && Line_Counter < 10'd240 && ~RenderingDisabled)
			Next_state <= Init0;
		else if (HBLANK == 1'b1 && Line_Counter == 10'd261 && ~RenderingDisabled)
			Next_state <= TileFetch1;
	Init0:
		Next_state <= Init1;
	Init1:
		if (Dot_Counter == 10'd64)
			Next_state <= InitPtr;
	InitPtr:
		Next_state <= Eval;
	Eval:
		if (Line_Counter >= OAM && Line_Counter < OAM + 8'h09)
			Next_state <= Write1;
		else
			Next_state <= Check;
	Write1:
		Next_state <= Write2;
	Write2:
		Next_state <= Write3;
	Write3:
		Next_state <= Check;
	Check:
		if (sprite_count == 4'd8 | OAMADDR == 8'd0)
			Next_state <= FetchWait;
		else
			Next_state <= Eval;
	FetchWait:
		if (Dot_Counter == 10'd260)
			Next_state <= TileFetch1;
	TileFetch1:
		if (sprite_count > 0)
			Next_state <= TileFetch2;
		else
			Next_state <= SOAMClear;
	TileFetch2:
		Next_state <= AttrFetch;
	AttrFetch:
		Next_state <= XFetch;
	XFetch:
		Next_state <= TileFetch1;
	SOAMClear:
		Next_state <= Wait;
endcase
end

always_comb
begin
tile_ld_UB = 1'b0;
tile_ld_LB = 1'b0;
tile_reset = 1'b0;
soam_mux_select = 2'b00;
write_soam = 1'b0;
soam_ptr_plus1 = 1'b0;
soam_ptr_plus2 = 1'b0;
soam_ptr_clear = 1'b0;
soam_ptr_set = 1'b0;
sprite_increment = 1'b0;
sprite_decrement = 1'b0;
oamaddr_plus1 = 1'b0;
oamaddr_plus4 = 1'b0;
oamaddr_clr = 1'b0;
Yregload = 1'b0;
soam_chr_select = 1'b0;
file_load = 1'b0;
x_load = 1'b0;
fine_y_inc = 1'b0;

case (State)
	Wait,Check:;
	Init0:;
		/*begin	// don't know why this was added either
		tile_reset = 1'b1;
		end*/
	Init1:
		begin
		soam_mux_select = 2'b01;
		write_soam = 1'b1;
		soam_ptr_plus1 = 1'b1;
		end
	InitPtr:
		begin
		soam_ptr_clear = 1'b1;
		end
	Eval:
		begin
		write_soam = 1'b1;
		Yregload = 1'b1;
		if (Line_Counter >= OAM && Line_Counter < OAM + 8'h09)
			begin
			sprite_increment = 1'b1;
			oamaddr_plus1 = 1'b1;
			soam_ptr_plus1 = 1'b1;
			end
		else
			oamaddr_plus4 = 1'b1;
		end
	Write1:
		begin
		soam_ptr_plus1 = 1'b1;
		write_soam = 1'b1;
		oamaddr_plus1 = 1'b1;
		soam_mux_select = 2'b10;
		end
	Write2,Write3:
		begin
		soam_ptr_plus1 = 1'b1;
		write_soam = 1'b1;
		oamaddr_plus1 = 1'b1;
		end
	FetchWait:
		begin
		soam_ptr_set = 1'b1;
		oamaddr_clr = 1'b1;
		end
	TileFetch1:
		begin
		if (sprite_count > 0)
			tile_ld_LB = 1'b1;
		end
	TileFetch2:
		begin
		tile_ld_UB = 1'b1;
		soam_chr_select = 1'b1;
		soam_ptr_plus1 = 1'b1;
		end
	AttrFetch:
		begin
		file_load = 1'b1;
		soam_ptr_plus1 = 1'b1;
		end
	XFetch:
		begin
		x_load = 1'b1;
		soam_ptr_plus2 = 1'b1;
		sprite_decrement = 1'b1;
		end
	SOAMClear:
		begin
		fine_y_inc = 1'b1;
		soam_ptr_clear = 1'b1;
		end
	endcase
end
		
	
endmodule 