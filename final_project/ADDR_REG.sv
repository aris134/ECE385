module ADDR_REG (input  logic Clk, Reset, Load, LoadUB, LoadLB, IRQ, NMI,	// added IRQ signal
              input  logic [15:0]  Data_In,	
              output logic [15:0]  Data_Out);	

    always_ff @ (posedge Clk or posedge Reset)	
    begin
	 	 if (Reset)
			  Data_Out <= 16'hFFFC;
		 else if (NMI)
			  Data_Out <= 16'hFFFA;
		 else if (IRQ)
				Data_Out <= 16'hFFFE;		// added IRQ signal response
		 else if (LoadUB)
				Data_Out[15:8] <= Data_In[7:0];
		 else if (LoadLB)
				Data_Out[7:0] <= Data_In[7:0];
		 else if (Load)
				Data_Out <= Data_In;
    end

endmodule