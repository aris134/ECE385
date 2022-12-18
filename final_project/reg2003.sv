module reg2003 (input  logic Clk, Reset, Load, Plus1, Plus4,
              input  logic [7:0]  Data_In,	
              output logic [7:0]  Data_Out);	

logic [7:0] data;
assign Data_Out = data;
    always_ff @ (posedge Clk or posedge Reset)	
    begin
	 	 if (Reset)
			  data <= 8'h00;	
		 else if (Load)
			  data <= Data_In;	
		 else if (Plus1)
			  data <= data + 8'h01;
		 else if (Plus4)
			  data <= data + 8'h04;
    end

endmodule
