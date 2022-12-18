module scanline_reg (input  logic Clk, Reset, Load, Clear,
              input  logic [8:0]  Data_In,	
              output logic [8:0]  Data_Out);	

    always_ff @ (posedge Clk or posedge Reset)	
    begin
	 	 if (Reset)
			  Data_Out <= 9'd0;	// for clearing PC when RESET is pressed
		 else if (Clear)
			  Data_Out <= 9'd0;
		 else if (Load)
			  Data_Out <= Data_In;		
    end

endmodule
