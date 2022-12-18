module reg8 (input  logic Clk, Reset, Load,
              input  logic [7:0]  Data_In,	
              output logic [7:0]  Data_Out);	

    always_ff @ (posedge Clk or posedge Reset)	
    begin
	 	 if (Reset)
			  Data_Out <= 8'h00;	// for clearing PC when RESET is pressed
		 else if (Load)
			  Data_Out <= Data_In;		
    end

endmodule
