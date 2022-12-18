module SystemPalette (input logic [7:0] address, 
					 input Clk,
					 input WE,
					 input [23:0] data_in,
					 output [23:0] read_data
					 );

logic [23:0] d_out;
assign read_data = d_out;
logic [23:0] mem[63:0];

initial // read memory from text file
begin
	$readmemh("C:/Users/Daniel/Documents/finalproject/memory/systempalette.txt", mem);
end

always @ (posedge Clk) 
begin
if (WE)
mem[address] <= data_in;
d_out <= mem[address];
end
endmodule 