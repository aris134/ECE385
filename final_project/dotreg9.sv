module dotreg9 (input  logic Clk, Reset, Clear,	
              output logic [8:0]  Data_Out);	

    always_ff @ (posedge Clk or posedge Reset)	
    begin
	 	 if (Reset)
			  Data_Out <= 9'b111111111;	// for clearing PC when RESET is pressed
		 else if (Clear)
			  Data_Out <= 9'd0;
		 else
			  Data_Out <= Data_Out + 9'd1;		
    end

endmodule
