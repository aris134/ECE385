module shiftin_reg8 (input  logic Clk, Reset, Load,
              input  logic Data_In,
              output logic [7:0] Data_Out);

logic [7:0] data;
assign Data_Out = data;
    always_ff @ (posedge Clk or posedge Reset)	
    begin
	 	 if (Reset)
			  data <= 8'h00;
		 else if (Load)
			  data <= {data[6:0], Data_In};
    end

endmodule
