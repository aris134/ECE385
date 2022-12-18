module edge_detector(
		input 	NMI,
		input 	Clk,
		input 	Reset,
		output	NMI_assert);
 
logic q1, q2;

nmi_flipflop FF1 (.Clk(Clk),.Reset(Reset),.D(NMI),.Q(q1));
nmi_flipflop FF2 (.Clk(Clk),.Reset(Reset),.D(q1),.Q(q2));

assign NMI_assert = ~q1 & q2;

endmodule 