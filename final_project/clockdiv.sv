module clockdiv (input Clk, Reset,
					  output PPUClk, CPUClk);

logic PPUtick;
logic CPUtick;

assign PPUClk = PPUtick;
assign CPUClk = CPUtick;

//ppuclk ppuclock(.Reset(Reset),.Clk(Clk),.ClkOut(PPUtick));
 always_ff @ (posedge Clk or posedge Reset )
 begin 
       if (Reset) 
            PPUtick <= 1'b0;
        else 
            PPUtick <= ~ (PPUtick);
    end
cpuclk cpuclock(.Reset(Reset),.Clk(PPUtick),.ClkOut(CPUtick));

endmodule

