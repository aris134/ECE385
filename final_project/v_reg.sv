module v_reg (input  Clk, Reset, Load2006,WT,VINC,x_overflow,FineYInc,copy_h,copy_v,CoarseYInc,
				  input [14:0] t, VINC_In,
              output [14:0]  Data_Out);	

logic [14:0] data_out;
assign Data_Out = data_out;
				  
    always_ff @ (posedge Clk or posedge Reset)	
    begin
	 	 if (Reset)
			  data_out <= 15'h0000;	// for clearing PC when RESET is pressed
		 else if (CoarseYInc)	// increment coarse y
			  data_out <= data_out + 15'h20;
		 else if ((Load2006 == 1'b1) && (WT == 1'b1))	// take t register when write toggle is 1 and 2006 is written to
			  data_out <= t;
		 else if (VINC)	// cpu v increment signal
			  data_out <= VINC_In;
		 else if (x_overflow && data_out[4:0] != 15'd31)	// increment coarse x with fine x overflow
			  data_out <= data_out + 15'd1;
		 else if (x_overflow && data_out[4:0] == 15'd31)	// reset coarse x when it overflows
			  data_out <= {data_out[14:5],5'd0};
		 else if (FineYInc)	// incrementing fine y signal
			  data_out <= data_out + 15'h1000;
		 else if (copy_h)		// reset x coordinates at hblank
		 begin
			  data_out[10] <= t[10];
			  data_out[4:0] <= t[4:0];
		 end
		 else if (copy_v)		// copy t vertical signal onto v
		 begin
			  data_out[9:5] <= t[9:5];
			  data_out[14:11] <= t[14:11];
		 end
	end
endmodule
