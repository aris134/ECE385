module PaletteSelect (input [2:0] CoarseX, CoarseY,
							 input [7:0] Palette_Attribute,
							 output [1:0] Latches);

logic [1:0] latches;
assign Latches = latches;
				 
always_comb
begin
latches = 2'b00;	// changed coarsex
if (((CoarseX - 3'd2) % 4) == 0 || ((CoarseX - 3'd2) % 4) == 1)
begin
	if ((CoarseY % 4) == 0 || (CoarseY % 4) == 1)
		latches = Palette_Attribute[1:0];
	else
		latches = Palette_Attribute[5:4];
end
else
begin
	if ((CoarseY % 4) == 0 || (CoarseY % 4) == 1)
		latches = Palette_Attribute[3:2];
	else
		latches = Palette_Attribute[7:6];
end
end
endmodule