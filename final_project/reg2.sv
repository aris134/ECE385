module reg2 (input  logic Clk, Reset, Load,
              input  logic [1:0]  Data_In,	
              output logic [1:0]  Data_Out);	

    always_ff @ (posedge Clk or posedge Reset)	
    begin
	 	 if (Reset)
			  Data_Out <= 2'b00;
		 else if (Load)
			  Data_Out <= Data_In;
    end

endmodule
