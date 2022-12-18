module nes(input CLOCK_50,
			 input [3:0] KEY,
			 input [17:0] SW,
				
				 // VGA Interface 
            output [7:0]  VGA_R,					//VGA Red
					           VGA_G,					//VGA Green
						   	  VGA_B,					//VGA Blue
				output        VGA_CLK,				//VGA Clock
							     VGA_SYNC_N,			//VGA Sync signal
								  VGA_BLANK_N,			//VGA Blank signal
								  VGA_VS,					//VGA vertical sync signal	
								  VGA_HS					);

// bus logic
logic [7:0] databus_8;
logic [15:0] address_16;
logic [7:0] control_8;
logic [1:0] bus_select;

logic [7:0] cpu_out;
logic [7:0] prg_data;
logic [7:0] cpu_ram;
logic [7:0] IO_reg;
logic [7:0] DMA;

logic [23:0] RGB;

logic CPUClk,PPUClk;
logic vs,hs,blank;
logic stop_cpu;

assign VGA_R = RGB[23:16];
assign VGA_G = RGB[15:8];
assign VGA_B = RGB[7:0];
assign VGA_CLK = PPUClk;
assign VGA_SYNC_N = 1'b0;
assign VGA_BLANK_N = blank;
assign VGA_VS = vs;
assign VGA_HS = hs;

logic NMI;
logic IRQ;
logic WE;
logic REG_LOAD;
logic reset_ah;

logic WT_clear,WT_load,Load2005,Load2006,Load2007,VINC,OAMWrite,oam_addr_inc;
logic Zero_hit,PaletteTrue,Plus1,Plus4,OAMADDRCLR,VBLANK_set,VBLANK_clear,DMA_select;
logic [7:0] PPUCTRL,PPUMASK,PPUSTATUS,OAMADDR,OAMDATA,PPUSCROLL,PPUADDR,PPUDATA,data_4016,controller_data;
logic [7:0] Palette_RAM_data,VRAM_data,OAMOffset;

assign controller_data = {~KEY[3],~KEY[2],SW[1],~KEY[0],SW[2],SW[3],SW[4],SW[0]};
assign reset_ah = ~KEY[1];


mux4_8 BUSMUX (.Din0(prg_data),.Din1(cpu_ram),.Din2(IO_reg),.Din3(data_4016),.select(bus_select),.Dout(databus_8));

prg_rom PRGROM (.address(address_16),.Clk(CLOCK_50),.WE(1'b0),.data_in(8'b00000000),
.read_data(prg_data));

IO_register_file IOreg (.CPUClk(CPUClk),.Clk(PPUClk),.Reset(reset_ah),.Load(REG_LOAD),.Plus4(Plus4),.Plus1(Plus1),.OAMADDRCLR(OAMADDRCLR),.VBLANK_set(VBLANK_set),
.VBLANK_clear(VBLANK_clear),.Address(address_16),.Data_in_CPU(cpu_out),.VRAM_data(VRAM_data),.Palette_RAM_data(Palette_RAM_data),.PaletteTrue(PaletteTrue),
.Data_out(IO_reg),.DMA(DMA),.OAMAddr(OAMADDR),.WT_clear(WT_clear),.WT_load(WT_load),.DMA_select(DMA_select),.DMA_in(cpu_ram),
.Load2004(Load2004),.Load2005(Load2005),.Load2006(Load2006),.Load2007(Load2007),.VINC(VINC),.OAMAddrInc(oam_addr_inc),
.PPUCTRL_out(PPUCTRL),.PPUMASK_out(PPUMASK),.PPUSTATUS_out(PPUSTATUS),.OAMDATA_out(OAMDATA),.PPUSCROLL_out(PPUSCROLL),.PPUADDR_out(PPUADDR),.PPUDATA_out(PPUDATA));

cpu_ram CPURAM (.address(address_16[10:0]),.Clk(CLOCK_50),.WE(WE),.data_in(cpu_out),.read_data(cpu_ram));

CPU Ricoh_2A03 (.Clk(CPUClk),.Reset(reset_ah),.IRQ(IRQ),.NMI(~NMI),.controller_data(controller_data),
.Data_in(databus_8),.DMA(DMA),.Data_out(cpu_out),.DMA_select(DMA_select),.OAMWrite(OAMWrite),.OAMAddrInc(oam_addr_inc),
.Address_out(address_16),.BUS_SELECT(bus_select),.WE(WE),.REG_LOAD(REG_LOAD),.Data4016(data_4016),.OAMOffset(OAMOffset),.StopCPU(stop_cpu));

PPU Ricoh_2C02 (.CPUClk(CPUClk),.Clk(PPUClk),.Reset(reset_ah),.MasterClk(CLOCK_50),.WT_clear(WT_clear),.WT_load(WT_load),.Load2004(Load2004),.Load2005(Load2005),.Load2006(Load2006),
.Load2007(Load2007),.VINC(VINC),.PPUCTRL(PPUCTRL),.PPUMASK(PPUMASK),.PPUSTATUS(PPUSTATUS),.OAMADDR(OAMADDR),.OAMDATA(OAMDATA),
.PPUSCROLL(PPUSCROLL),.PPUADDR(PPUADDR),.PPUDATA(PPUDATA),.Palette_RAM_data(Palette_RAM_data),.VRAM_data(VRAM_data),.Zero_hit(Zero_hit),
.PaletteTrue(PaletteTrue),.Plus1(Plus1),.Plus4(Plus4),.OAMADDRCLR(OAMADDRCLR),.blank(blank),.VBLANK_set(VBLANK_set),
.VBLANK_clear(VBLANK_clear),.NMI(NMI),.VS(vs),.HS(hs),.write_oam(OAMWrite),.OAMOffset(OAMOffset),.StopCPU(stop_cpu));

clockdiv ClockDivider(.Clk(CLOCK_50),.Reset(reset_ah),.PPUClk(PPUClk),.CPUClk(CPUClk));

SystemPalette Systempalette(.Clk(CLOCK_50),.address(Palette_RAM_data),.WE(1'b0),.data_in(24'd0),.read_data(RGB));

endmodule 