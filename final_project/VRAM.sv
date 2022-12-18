module VRAM (input logic [10:0] address, 
					 input Clk,
					 input WE,
					 input [7:0] data_in,
					 output [7:0] read_data
					 );

logic [7:0] d_out;
assign read_data = d_out;
logic [7:0] mem[2047:0];

always @ (negedge Clk) 
begin
if (WE)
mem[address] <= data_in;
d_out <= mem[address];
end
endmodule 