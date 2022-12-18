module cpuclk (input  logic Clk, Reset,
              output logic ClkOut);
				  
logic q1,q2,q3;
assign ClkOut = ~(q2 | q3);

flipflop ppuff1(.Clk(Clk),.Reset(Reset),.D(~(q1 | q2)),.Q(q1));
flipflop ppuff2(.Clk(Clk),.Reset(Reset),.D(q1),.Q(q2));
flipflop ppuff3(.Clk(~Clk),.Reset(Reset),.D(q2),.Q(q3));
endmodule
