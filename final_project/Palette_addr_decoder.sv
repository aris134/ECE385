module Palette_addr_decoder (input [4:0] address,
							output [4:0] address_out);
							
logic [4:0] address_wire;
assign address_out = address_wire;

always_comb
begin
if (~(address[0] | address[1]) & address[4])
address_wire = address - 5'b10000;
else
address_wire = address;
end

endmodule 