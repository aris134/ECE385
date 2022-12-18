module controller_reg (input  logic Clk, Reset, Load, Shift_Enable,
              input  logic [7:0]  Data_In,
              output logic  Data_Out);

logic [7:0] data;
assign Data_Out = data[7];
    always_ff @ (posedge Clk or posedge Reset)	
    begin
	 	 if (Reset)
			  data <= 8'hFF;	
		 else if (Load)
			  data <= Data_In;
		 else if (Shift_Enable)
			  data <= {data[6:0], 1'b1};
    end

endmodule
