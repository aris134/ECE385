module PPU_addr_decoder (input [13:0] address,
							input fetch_attr_byte,
							output [13:0] address_out,
							output PaletteTrue,vram_true);
							
logic [13:0] address_wire;
assign address_out = address_wire;
logic palette_true;
assign PaletteTrue = palette_true;
logic VRAM_True;
assign vram_true = VRAM_True;

always_comb
begin
palette_true = 1'b0;
VRAM_True = 1'b0;
address_wire = 14'd0;
if (fetch_attr_byte)
address_wire = {address[11:10],4'b1111,address[9:7],address[4:2]};
else
begin
if (address < 14'h2000)
address_wire = address;

else if (address >= 14'h2000 && address < 14'h3000)
begin
VRAM_True = 1'b1;
	if (address >= 14'h2000 && address < 14'h2400)
		address_wire = address - 14'h2000; 

	else if (address >= 14'h2400 && address < 14'h2800)
		address_wire = address - 14'h2400;

	else if (address >= 14'h2800 && address < 14'h2C00)
		address_wire = address - 14'h2400;

	else
		address_wire = address - 14'h2800;
end

else if (address >= 14'h3000 && address < 14'h3F00)
begin
VRAM_True = 1'b1;
	if (address >= 14'h3000 && address < 14'h3400)
		address_wire = address - 14'h3000; 

	else if (address >= 14'h3400 && address < 14'h3800)
		address_wire = address - 14'h3400;

	else if (address >= 14'h3800 && address < 14'h3C00)
		address_wire = address - 14'h3400;

	else
		address_wire = address - 14'h3800;
end

else
begin
address_wire = {9'd0,address[4:0]};
palette_true = 1'b1;
end
end
end

endmodule 