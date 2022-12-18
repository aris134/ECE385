module reg5 (input  logic Clk, Reset, Load,
              input  logic [4:0]  Data_In,	
              output logic [4:0]  Data_Out);	

    always_ff @ (posedge Clk or posedge Reset)	
    begin
	 	 if (Reset)
			  Data_Out <= 5'b00000;
		 else if (Load)
			  Data_Out <= Data_In;
    end

endmodule
