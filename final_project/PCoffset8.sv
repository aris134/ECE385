module PCoffset8 (input [7:0] offset,
						 output [15:0] sext);
						 
	logic [7:0] concatanate; 
						 
	mux2 m0(.Din0(1'b0),.Din1(1'b1),.Dout(concatanate[0]),.select(offset[7]));
   mux2 m1(.Din0(1'b0),.Din1(1'b1),.Dout(concatanate[1]),.select(offset[7]));
   mux2 m2(.Din0(1'b0),.Din1(1'b1),.Dout(concatanate[2]),.select(offset[7]));
	mux2 m3(.Din0(1'b0),.Din1(1'b1),.Dout(concatanate[3]),.select(offset[7]));
	mux2 m4(.Din0(1'b0),.Din1(1'b1),.Dout(concatanate[4]),.select(offset[7]));
	mux2 m5(.Din0(1'b0),.Din1(1'b1),.Dout(concatanate[5]),.select(offset[7]));
	mux2 m6(.Din0(1'b0),.Din1(1'b1),.Dout(concatanate[6]),.select(offset[7]));
	mux2 m7(.Din0(1'b0),.Din1(1'b1),.Dout(concatanate[7]),.select(offset[7]));
	
	
	assign sext = {concatanate,offset};
	
	endmodule 