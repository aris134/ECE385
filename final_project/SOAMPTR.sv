module SOAMPTR (input  logic Clk, Reset, Set1, Plus1, Plus2,
              output logic [4:0]  Data_Out);	

logic [4:0] data;
assign Data_Out = data;
    always_ff @ (posedge Clk or posedge Reset)	
    begin
	 	 if (Reset)
			  data <= 5'b00000;
		 else if (Set1)
			  data <= 5'b00001;
		 else if (Plus1)
			  data <= data + 5'd1;
		 else if (Plus2)
			  data <= data + 5'd2;
    end

endmodule
