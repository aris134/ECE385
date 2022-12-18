module pc_reg (input  logic Clk, Reset, Load, LoadUB, LoadLB,
              input  logic [15:0]  Data_In,	
              output logic [15:0]  Data_Out);	

    always_ff @ (posedge Clk or posedge Reset)	
    begin
	 	 if (Reset)
			  Data_Out <= 16'h0000;	
		 else if (LoadUB)
				Data_Out[15:8] <= Data_In[7:0];
		 else if (LoadLB)
				Data_Out[7:0] <= Data_In[7:0];
		 else if (Load)
				Data_Out <= Data_In;
    end

endmodule