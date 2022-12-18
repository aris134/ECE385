module cpu_ram (input logic [10:0] address, 
					 input Clk,
					 input WE,
					 input [7:0] data_in,
					 output [7:0] read_data
					 );
logic [7:0] d_out;
logic [7:0] mem[2047:0];
assign read_data = d_out;
initial // read memory from text file
begin
	$readmemh("C:/Users/Daniel/Documents/finalproject/memory/cpuram.txt", mem);
end

always @ (negedge Clk) 
begin
if (~WE)
mem[address] <= data_in;
d_out <= mem[address];
end
endmodule 
