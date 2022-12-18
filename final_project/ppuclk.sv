module ppuclk (input  logic Clk, Reset,
              output logic ClkOut);

logic q1,q2,q3;
logic q4,q5,q6;
assign ClkOut = ~(q5 | q6);

flipflop ppuff1(.Clk(Clk),.Reset(Reset),.D(~(q1 | q2)),.Q(q1));
flipflop ppuff2(.Clk(Clk),.Reset(Reset),.D(q1),.Q(q2));
flipflop ppuff3(.Clk(~Clk),.Reset(Reset),.D(q2),.Q(q3));

logic Clk_out;
assign Clk_out = ~(q2 | q3);

flipflop ppuff4(.Clk(Clk_out),.Reset(Reset),.D(~(q4 | q5)),.Q(q4));
flipflop ppuff5(.Clk(Clk_out),.Reset(Reset),.D(q4),.Q(q5));
flipflop ppuff6(.Clk(~Clk_out),.Reset(Reset),.D(q5),.Q(q6));

endmodule
