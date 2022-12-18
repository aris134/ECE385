module p_reg (input logic Clk, Reset, SEI, SEC, CLI, CLC, CLV, N, LoadN, V, LoadV, 
				  input Z, LoadZ, C, LoadC, BRK, PLP,
              input  logic [7:0]  Data_In,	
              output logic [7:0]  Data_Out);	

    always_ff @ (posedge Clk or posedge Reset)	
    begin
	 	 if (Reset)
			  Data_Out <= 8'h00;	
		 else
		 begin
		 if (PLP)
			  Data_Out <= Data_In;	
		 if (LoadN)
				Data_Out[7] <= N;
		 if (LoadV)
				Data_Out[6] <= V;
		 if (LoadZ)
				Data_Out[1] <= Z;
		 if (LoadC)
				Data_Out[0] <= C;
		 if (SEI) 
				Data_Out[2] <= 1'b1;
		 if (SEC)
				Data_Out[0] <= 1'b1; 
		 if (CLI)
				Data_Out[2] <= 1'b0;
		 if (CLC)
				Data_Out[0] <= 1'b0;
		 if (CLV)
				Data_Out[6] <= 1'b0;
		 if (BRK)
				Data_Out[4] <= 1'b1;
		 end
    end

endmodule
