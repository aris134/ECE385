module clockdiv (input Clk, Reset,
					  output PPUClk, CPUClk);
					  
logic [3:0] PPUcount;
logic [1:0] CPUcount;

logic PPUtick;
logic CPUtick;

assign PPUClk = PPUtick;
assign CPUClk = CPUtick;

always_ff @ (posedge Clk or posedge Reset)
begin
	if (Reset)
		PPUcount = 4'd0;
	if (PPUcount == 4'd9)
	begin
		PPUtick = 1'b1;
		PPUcount = 4'd0;
	end
	else
		PPUcount = (PPUcount + 1'b1);
end

always_ff @ (posedge PPUtick or posedge Reset)
begin
	if	(Reset)
		CPUcount = 2'd0;
	if (CPUcount == 2'd3)
	begin
		CPUtick = 1'b1;
		CPUcount = 2'd0;
	end
	else
		CPUcount = (CPUcount + 1'b1);
end
endmodule 