module PPU (input MasterClk, Clk, CPUClk, Reset,
						input WT_clear,WT_load,Load2004,Load2005,Load2006,Load2007,VINC,write_oam,
						input [7:0] PPUCTRL,PPUMASK,PPUSTATUS,OAMADDR,OAMDATA,PPUSCROLL,PPUADDR,PPUDATA,OAMOffset,
						output [7:0] Palette_RAM_data,VRAM_data,
						output Zero_hit,PaletteTrue,Plus1,Plus4,OAMADDRCLR,blank,VBLANK_set,VBLANK_clear,NMI,HS,VS,StopCPU);

// logic wires
logic write_soam,h_blank,ld_soam_ptr,WT_out,Yregload,IncX; // incx is a statemachine thing
logic soam_chr_select,nametable_chr_select,palette_true,palette_ram_select,nametable_ld;
logic AT_load,fine_y_inc,coarse_y_inc,display,attr_latch_ld,copy_h,vram_true,we_cpu,we_oam;
logic hs,vs;
logic stop_cpu;
assign StopCPU = stop_cpu;
assign VS = vs;
assign HS = hs;
logic [1:0] soam_mux_select,chr_mux_select;
logic [2:0] x_count;
logic [4:0] soam_ptr_out,ppu_palette_addr,cpu_palette_addr,PRAM_mux_out,palette_ram_addr;
logic [7:0] oam_out,soam_out,chr_rom_out,vram_out,yreg_out,nametable_out;
logic [7:0] palette_ram_data,AT,soam_in;
logic [9:0] scanline,dot_counter;
logic [12:0] chr_rom_addr,soam_chr_out,nametable_chr_out;
logic [13:0] PPUaddrbus;
logic [14:0] vreg_out,treg_out,VINC_In;
assign PaletteTrue = palette_true;
assign Palette_RAM_data = palette_ram_data;
assign VRAM_data = vram_out;

// state machine logic
logic dot_clear,scanline_increment,scanline_clear,x_decrement,shift_b,shift_a,load_c_lb,load_c_ub,load_b,vblank_set,vblank_clear,copy_v,fetch_attr_byte;
logic rendering_disabled;
assign rendering_disabled = ~(PPUMASK[3] | PPUMASK[4]);
assign VBLANK_set = vblank_set;
assign VBLANK_clear = vblank_clear;
assign NMI = PPUSTATUS[7] & PPUCTRL[7];

// modules
OAM PrimaryOAM(.Clk(MasterClk),.address(OAMADDR + OAMOffset),.WE(write_oam),.data_in(OAMDATA),.read_data(oam_out));
SecondaryOAM OAMBuffer(.Clk(MasterClk),.address(soam_ptr_out),.WE(write_soam | we_oam),.data_in(soam_in),.read_data(soam_out));
PPURender RenderingUnit(.*,.FineYInc(fine_y_inc),.display(display),.HBLANK(h_blank),.SOAM(soam_out),.CHR_ROM(chr_rom_out),.OAM(oam_out),.Dot_Counter(dot_counter),.Line_Counter(scanline),
								.CoarseX(vreg_out[4:2]),.CoarseY(vreg_out[9:7]),.Pixel_address(ppu_palette_addr),.SOAMPtr(soam_ptr_out),.RenderingDisabled(rendering_disabled),
								.SOAMMuxSelect(soam_mux_select),.WriteSOAM(write_soam),.YRegLoad(Yregload),.SOAMCHRSelect(soam_chr_select),.Zero_hit(Zero_hit));
reg8 AttrBuffer(.*,.Load(AT_load),.Data_In(VRAM_data),.Data_Out(AT)); // at_load is a state machine signal
chr_rom CHRROM(.*,.Clk(MasterClk),.address(chr_rom_addr),.WE(1'd0),.data_in(8'd0),.read_data(chr_rom_out));
								
PPU_addr_decoder PPUAddrDecoder(.address(vreg_out),.address_out(PPUaddrbus),.PaletteTrue(palette_true),.vram_true(vram_true),.fetch_attr_byte(fetch_attr_byte));
reg8 Yregister(.*,.Load(Yregload),.Data_In(oam_out),.Data_Out(yreg_out));
reg8 NametableBuffer(.*,.Load(nametable_ld),.Data_In(vram_out),.Data_Out(nametable_out));
Palette_addr_decoder PaletteAddrDecoder(.address(PRAM_mux_out),.address_out(palette_ram_addr));
PaletteRAM Palette_RAM(.*,.Clk(MasterClk),.address(palette_ram_addr),.WE(palette_true & we_cpu),.data_in(PPUDATA),.read_data(palette_ram_data));
mux2_5 PaletteRamMux(.Din0(ppu_palette_addr),.Din1(PPUaddrbus[4:0]),.select(palette_ram_select),.Dout(PRAM_mux_out)); // use state machine to toggle select based on scanline
flip_flop WriteToggle(.*,.Clk(CPUClk),.Reset(Reset | WT_clear),.Load(WT_load),.D(~WT_out),.Q(WT_out));
flip_flop WE_CPU(.*,.Load(Load2007 | we_cpu),.D(Load2007),.Q(we_cpu));
flip_flop WE_OAM(.Clk(Clk),.Reset(Reset),.Load(Load2004 | we_oam),.D(Load2004),.Q(we_oam));
fine_x FineXReg(.*,.Scroll3(PPUSCROLL[2:0]),.Count(x_count));
t_reg Treg(.*,.Clk(Clk),.WT(WT_out),.PPUCTRL_2(PPUCTRL[1:0]),.Data_Out(treg_out));
v_reg Vreg(.*,.CoarseYInc(coarse_y_inc),.Clk(Clk),.WT(WT_out),.x_overflow((x_count[2] & x_count[1] & x_count[0]) & ~rendering_disabled),.FineYInc(fine_y_inc),.t(treg_out),.Data_Out(vreg_out)); // fine y inc state machine
VINCMux VregMux(.Din0(vreg_out),.Din1(vreg_out + 15'd32),.Din2(vreg_out + 15'd1),.select({VINC,PPUCTRL[2]}),.Dout(VINC_In));
VRAM PPUVRAM(.address(PPUaddrbus[10:0]),.Clk(MasterClk),.WE(vram_true & we_cpu),.data_in(PPUDATA),.read_data(vram_out));
mux3_8 SOAMInMux(.Din0(oam_out),.Din1(8'hFF),.Din2(oam_out + (scanline - yreg_out)),.select(soam_mux_select),.Dout(soam_in));
mux3_13 CHRROMMUX(.Din0(soam_chr_out),.Din1(PPUaddrbus),.Din2(nametable_chr_out),
						.select({chr_mux_select[1] & ~rendering_disabled, chr_mux_select[0] | rendering_disabled}),.Dout(chr_rom_addr));
// set chr_mux_select as 0 at tick 257-320

// maybe needs vreg_out[14:12] for sprites
mux2_13 SOAMCHRMUX(.Din0({PPUCTRL[3],12'd0} + {2'd0,soam_out,4'h0} + vreg_out[14:12]),.Din1({PPUCTRL[3],12'd0} + {2'd0,soam_out,4'd8} + (vreg_out[14:12] + 3'd1)),.select(soam_chr_select),.Dout(soam_chr_out));
mux2_13 NAMCHRMUX(.Din0({PPUCTRL[4],12'd0} + {2'd0,nametable_out,4'h0} + vreg_out[14:12]),.Din1({PPUCTRL[4],12'd0} + {2'd0,nametable_out,4'd8} + (vreg_out[14:12] + 3'd1)),.select(nametable_chr_select),.Dout(nametable_chr_out));

// dot and scanline counters
//dotreg9 DotCounter(.Clk(Clk),.Reset(Reset),.Clear(dot_clear),.Data_Out(dot_counter));
//scanline_reg ScanlineCounter(.Clk(Clk),.Reset(Reset),.Clear(scanline_clear),.Load(scanline_increment),.Data_In(scanline + 9'd1),.Data_Out(scanline));

/*always_comb
begin
dot_clear = 1'b0;
scanline_clear = 1'b0;
if (dot_counter == 9'd340)
	dot_clear = 1'b1;
if (scanline == 9'd261 && dot_counter == 9'd340)
	scanline_clear = 1'b1;
end*/


// vga logic stuff
    // 800 horizontal pixels indexed 0 to 799
    // 525 vertical pixels indexed 0 to 524
    parameter [9:0] hpixels = 10'b1100011111;
    parameter [9:0] vlines = 10'b1000001100;
	 
	 // horizontal pixel and vertical line counters

   
	//Runs the horizontal counter  when it resets vertical counter is incremented
   always_ff @ (posedge Clk or posedge Reset )
	begin: counter_proc
		  if ( Reset ) 
			begin 
				 dot_counter <= 10'b0000000000;
				 scanline <= 10'b0000000000;
			end
				
		  else 
			 if ( dot_counter == hpixels )  //If hc has reached the end of pixel count
			  begin 
					dot_counter <= 10'b0000000000;
					if ( scanline == vlines )   //if vc has reached end of line count
						 scanline <= 10'b0000000000;
					else 
						 scanline <= (scanline + 1'b1);
			  end
			 else 
				  dot_counter <= (dot_counter + 1'b1);  //no statement about vc, implied vc <= vc;
	 end 

	 //horizontal sync pulse is 96 pixels long at pixels 656-752
    //(signal is registered to ensure clean output waveform)
    always_ff @ (posedge Reset or posedge Clk )
    begin : hsync_proc
        if ( Reset ) 
            hs <= 1'b0;
        else  
            if ((((dot_counter + 1) >= 10'b1010010000) & ((dot_counter + 1) < 10'b1011110000))) 
                hs <= 1'b0;
            else 
				    hs <= 1'b1;
    end
	 
    //vertical sync pulse is 2 lines(800 pixels) long at line 490-491
    //(signal is registered to ensure clean output waveform)
    always_ff @ (posedge Reset or posedge Clk )
    begin : vsync_proc
        if ( Reset ) 
           vs <= 1'b0;
        else 
            if ( ((scanline + 1) == 9'b111101010) | ((scanline + 1) == 9'b111101011) ) 
			       vs <= 1'b0;
            else 
			       vs <= 1'b1;
    end
       
    //only display pixels between horizontal 0-639 and vertical 0-479 (640x480)
    //(This signal is registered within the DAC chip, so we can leave it as pure combinational logic here)    
    always_comb
    begin 
        if ( (dot_counter >= 10'b1010000000) | (scanline >= 10'b0111100000) ) 
            display = 1'b0;
        else 
            display = 1'b1;
    end 
   
    assign blank = display;

// state machine
enum logic [5:0] {Clear, Scanline_Read, BGR1,BGR2,BGR3,BGR4,BGR5,BGR6,BGR7, H_Blank, BNL0,BNL1,BNL2,BNL3,BNL4,BNL5,BNL6,BNL7,BNL8,BNL9,BNL10,
						Post_Render, Pre_VBLANK,Set_VBLANK,VBLANK,Clear_VBLANK,Pre_R_HBLANK,Vertical_Copy,Pre_R_NoRender,WaitVGAH1,WaitVGAH2,WaitVGAV
						} State, Next_state;

always_ff @ (posedge Clk or posedge Reset)
begin 
	if (Reset) 
		State <= Clear;
	else 
		State <= Next_state;
end

// transitions
always_comb 
begin
Next_state = State; 
	
unique case (State)
	Clear:
		Next_state <= Scanline_Read;
	Scanline_Read:
		if (scanline < 10'd240 && dot_counter == 10'd0)
			Next_state <= Scanline_Read;
		else if (scanline < 10'd240 && (dot_counter < 10'd257 && dot_counter > 10'd0) && ~(rendering_disabled))
			Next_state <= BGR1;
		else if (scanline == 10'd240)
			Next_state <= Post_Render;
	BGR1:
		Next_state <= BGR2;
	BGR2:
		Next_state <= BGR3;
	BGR3:
		Next_state <= BGR4;
	BGR4:
		Next_state <= BGR5;
	BGR5:
		Next_state <= BGR6;
	BGR6:
		Next_state <= BGR7;
	BGR7:
		if (dot_counter == 10'd256)
		Next_state <= H_Blank;
		else
		Next_state <= Scanline_Read;
	H_Blank:
		if (dot_counter == 10'd320)
			Next_state <= BNL0;
	BNL0:
		Next_state <= BNL1;
	BNL1:
		Next_state <= BNL2;
	BNL2:
		Next_state <= BNL3;
	BNL3:
		Next_state <= BNL4;
	BNL4:
		if (x_count == 3'd7)
			Next_state <= BNL5;
	BNL5:
		Next_state <= BNL6;
	BNL6:
		Next_state <= BNL7;
	BNL7:
		Next_state <= BNL8;
	BNL8:
		Next_state <= BNL9;
	BNL9:
		if (x_count == 3'd7)
			Next_state <= BNL10;
	BNL10:
		if (dot_counter == 10'd340)
		begin
			//Next_state <= Scanline_Read;
			if (scanline == 10'd261)
				Next_state <= WaitVGAV;
			else
				Next_state <= WaitVGAH1;
		end
	Post_Render:
		if (dot_counter == 10'd340)
			//Next_state <= Pre_VBLANK;
			Next_state <= WaitVGAH2;
	Pre_VBLANK:
		Next_state <= Set_VBLANK;
	Set_VBLANK:
		Next_state <= VBLANK;
	VBLANK:
		if (dot_counter == 10'd0 && scanline == 10'd261)
			Next_state <= Clear_VBLANK;
	Clear_VBLANK:
		if (dot_counter == 10'd256)
			Next_state <= Pre_R_HBLANK;
	Pre_R_HBLANK:
		if (rendering_disabled)
			Next_state <= Pre_R_NoRender;
		else if (dot_counter == 10'd279)
			Next_state <= Vertical_Copy;
	Pre_R_NoRender:
		if (dot_counter == 10'd340)
			//Next_state <= Scanline_Read;
			Next_state <= WaitVGAV;
	Vertical_Copy:
		if (dot_counter == 10'd320)
			Next_state <= BNL0;
	WaitVGAH1:
		if (dot_counter == 10'd799)
			Next_state <= Scanline_Read;
	WaitVGAH2:
		if (dot_counter == 10'd799)
			Next_state <= Pre_VBLANK;
	WaitVGAV:
		if (scanline == 10'd524 && dot_counter == 10'd799)
			Next_state <= Scanline_Read;
endcase
end

// outputs
always_comb
begin
palette_ram_select = 1'b0;
nametable_ld = 1'b0;
x_decrement = 1'b0;
IncX = 1'b0;
AT_load = 1'b0;
nametable_chr_select = 1'b0;
load_c_lb = 1'b0;
load_c_ub = 1'b0;
load_b = 1'b0;
attr_latch_ld = 1'b0;
coarse_y_inc = 1'b0;
copy_h = 1'b0;
h_blank = 1'b0;
shift_b = 1'b0;
shift_a = 1'b0;
chr_mux_select = 2'b10;
scanline_increment = 1'b0;
vblank_set = 1'b0;
vblank_clear = 1'b0;
copy_v = 1'b0;
fetch_attr_byte = 1'b0;
stop_cpu = 1'b0;

case(State)
	Clear,Pre_VBLANK,Pre_R_NoRender:;
	Scanline_Read:
		begin
		if (dot_counter > 10'd340 && rendering_disabled)
			stop_cpu = 1'b1;
		//if (rendering_disabled && dot_counter == 9'd340)
			//scanline_increment = 1'b1;
		else if (dot_counter < 10'd257 && dot_counter > 10'd0 && scanline < 10'd240)
			begin
			palette_ram_select = 1'b0;	// outputs RGB
			nametable_ld = 1'b1;	// loads nametable buffer
			x_decrement = 1'b1;	// decrements sprite counters
			IncX = 1'b1;	// increment fine x
			shift_b = 1'b1;	// shift pattern table registers
			shift_a = 1'b1;
			end
		end
	BGR2:
		begin
		palette_ram_select = 1'b0;	// outputs RGB
		AT_load = 1'b1;	// loads attribute buffer
		fetch_attr_byte = 1'b1;	// address VRAM for attribute buffer
		x_decrement = 1'b1;	// decrements sprite counters
		IncX = 1'b1;	// increment fine x
		shift_b = 1'b1;
		shift_a = 1'b1;
		end
	BGR3:
		begin
		nametable_chr_select = 1'b0;	// select nametable buffer + 0
		load_c_lb = 1'b1;		// load pattern data LB
		x_decrement = 1'b1;
		IncX = 1'b1;
		shift_b = 1'b1;
		shift_a = 1'b1;
		end
	BGR4:
		begin
		nametable_chr_select = 1'b1;	// select nametable buffer + 8
		load_c_ub = 1'b1;		// load pattern data UB
		x_decrement = 1'b1;
		IncX = 1'b1;
		shift_b = 1'b1;
		shift_a = 1'b1;
		end
	BGR1,BGR5,BGR6:
		begin
		x_decrement = 1'b1;
		IncX = 1'b1;
		shift_b = 1'b1;
		shift_a = 1'b1;
		end
	BGR7:
		begin
		x_decrement = 1'b1;
		IncX = 1'b1;
		load_b = 1'b1;		// load b with new nametable
		shift_a = 1'b1;
		attr_latch_ld = 1'b1;
		end
	H_Blank:
		begin
		if ((dot_counter == 10'd259) && (scanline % 10'd8 == 10'd7))
			coarse_y_inc = 1'b1;
		if (dot_counter == 10'd257)
			begin
			copy_h = 1'b1;
			h_blank = 1'b1;
			end
		chr_mux_select = 2'b00;
		end
	BNL0:
		begin
			IncX = 1'b1;	// increment fine x
			nametable_ld = 1'b1;	// loads nametable buffer
		end
	BNL1:
		begin
			AT_load = 1'b1;	// attribute buffer load
			fetch_attr_byte = 1'b1;	// address VRAM for attribute buffer
			load_c_lb = 1'b1; // load register a lb
			IncX = 1'b1;	// fine x is 1
			nametable_chr_select = 1'b0;	// select nametable buffer + 0
		end
	BNL2:
		begin
			load_c_ub = 1'b1; // load register a ub
			IncX = 1'b1;	// fine x is 2
			nametable_chr_select = 1'b1;	// select nametable buffer + 8
		end
	BNL3:
		begin
			load_b = 1'b1;	// load b with contents from c
			IncX = 1'b1;
		end
	BNL4:		// get out of this state once fine_x is 7
		begin
			shift_a = 1'b1; // shifts = 0
			shift_b = 1'b1;
			IncX = 1'b1;	// fine_x = 4
		end
	BNL5:		// fine_x is 0 and a has shifted twice
		begin
			IncX = 1'b1; // fine x is now 0
			nametable_ld = 1'b1;
			shift_a = 1'b1; // shifts = 4
			shift_b = 1'b1;
		end
	BNL6:
		begin
			load_c_lb = 1'b1; // load register a lb
			IncX = 1'b1;	// fine x is 1
			nametable_chr_select = 1'b0;	// select nametable buffer + 0
			shift_a = 1'b1; // shifts = 5
			shift_b = 1'b1;
		end
	BNL7:
		begin
			load_c_ub = 1'b1; // load register a ub
			IncX = 1'b1;	// fine x is 2
			nametable_chr_select = 1'b1;	// select nametable buffer + 8
			shift_a = 1'b1; // shifts = 6
			shift_b = 1'b1;
		end
	BNL8:
		begin
			load_b = 1'b1;
			IncX = 1'b1; // fine x is 3
			shift_a = 1'b1; // last shift
		end
	BNL9:
		begin
			IncX = 1'b1;
		end
	BNL10:
		begin
			attr_latch_ld = 1'b1;
			/*if (dot_counter == 10'd340)
			begin
				if (scanline != 10'd261)
					scanline_increment = 1'b1;
			end*/
		end
	Post_Render:;/*
		begin
			if (dot_counter == 9'd340)
				scanline_increment = 1'b1;
		end*/
	VBLANK:
		begin
		if (dot_counter > 10'd340)
			stop_cpu = 1'b1;
		palette_ram_select = 1'b1;
			/*if (dot_counter == 9'd340)
				scanline_increment = 1'b1;*/
		end
	Set_VBLANK:
		begin
			palette_ram_select = 1'b1;
			vblank_set = 1'b1;
		end
	Clear_VBLANK:
		vblank_clear = 1'b1;
	Pre_R_HBLANK:
		begin
			if (~rendering_disabled)
			begin
			copy_h = 1'b1;
			if (dot_counter == 10'd257)
				h_blank = 1'b1;
			chr_mux_select = 2'b00;
			end
		end
	Vertical_Copy:
		begin
			chr_mux_select = 2'b00;
			copy_v = 1'b1;
		end
	WaitVGAH1,WaitVGAH2,WaitVGAV:
		begin
			stop_cpu = 1'b1;
		end
endcase
end
endmodule
