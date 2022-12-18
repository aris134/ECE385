module reg4016 (input  logic Clk, Reset, Load, Shift_In, Shift_Enable,
              input  logic [7:0]  Data_In,	
              output logic [7:0]  Data_Out);	

    always_ff @ (posedge Clk or posedge Reset)	
    begin
	 	 if (Reset)
			  Data_Out <= 8'h00;	// for clearing PC when RESET is pressed
		 else if (Load)
			  Data_Out <= Data_In;	
		 else if (Shift_Enable)
			  Data_Out <= {Data_Out[7:1],Shift_In};
    end

endmodule
