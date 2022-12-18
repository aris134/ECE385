module t_reg (input  Clk, Reset, Load2005, Load2006, WT,
				  input 	[1:0]	  PPUCTRL_2,
				  input 	[7:0]	  PPUSCROLL,PPUADDR,
              output [14:0]  Data_Out);	

logic [14:0] data_out;
assign Data_Out = data_out;

    always_ff @ (posedge Clk or posedge Reset)	
    begin
	 	 if (Reset)
			  data_out <= 15'h0000;	// for clearing PC when RESET is pressed
		 else if ((WT == 1'b0) && (Load2005 == 1'b1))
			  data_out[4:0] <= PPUSCROLL[4:0];
		 else if ((WT == 1'b1) && (Load2005 == 1'b1))
		 begin
			  data_out[14:12] <= PPUSCROLL[2:0];
			  data_out[9:5] <= PPUSCROLL[7:3];
		 end
		 else if ((WT == 1'b0) && (Load2006 == 1'b1))
		 begin
			  data_out[13:8] <= PPUADDR[5:0];
			  data_out[14] <= 1'b0;
		 end
		 else if ((WT == 1'b1) && (Load2006 == 1'b1))
			  data_out[7:0] <= PPUADDR;
    end

endmodule
