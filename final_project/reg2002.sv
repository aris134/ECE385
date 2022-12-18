module reg2002 (input  logic Clk, Reset, Load,VBLANK_set,VBLANK_clear,PPUSTATUS_true,
              input  logic [7:0]  Data_In,	
              output logic [7:0]  Data_Out);	

    always_ff @ (posedge Clk or posedge Reset)	
    begin
	 	 if (Reset)
			  Data_Out <= 8'h00;	// for clearing PC when RESET is pressed
		 else if (Load)
			  Data_Out <= Data_In;
		 else if (VBLANK_set) 
			  Data_Out <= {1'b1,Data_Out[6:0]};
		 else if (VBLANK_clear | PPUSTATUS_true)
			  Data_Out <= {1'b0,Data_Out[6:0]};
    end

endmodule
