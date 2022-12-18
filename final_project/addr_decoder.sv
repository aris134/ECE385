module addr_decoder (input [15:0] address,
							input w,
							output [15:0] address_out,
							output [1:0] bus_select,
							output we, reg_file_load,Load4016,Read4016);
							
logic [15:0] address_wire;
assign address_out = address_wire;

logic [1:0] bus;
assign bus_select = bus;

logic WE;
assign we = WE;

logic REG_LOAD;
assign reg_file_load = REG_LOAD;

logic load4016;
assign Load4016 = load4016;

logic read4016;
assign Read4016 = read4016;

always_comb
begin
bus = 2'b00;
WE = 1'b1;
REG_LOAD = 1'b0;
load4016 = 1'b0;
read4016 = 1'b0;
if (address[15:0] < 16'h2000)
begin
address_wire = address;
bus = 2'b01;
WE = w;
end

else if (address[15:0] >= 16'h2000 && address[15:0] < 16'h4020)
begin
if (address == 16'h4016)
begin
	address_wire = address;
	bus = 2'b11;
	if (~w)
		load4016 = 1'b1;
	else
		read4016 = 1'b1;
end
else
begin
address_wire = address;
bus = 2'b10;
REG_LOAD = ~w;
end
end

else if (address[15:0] >= 16'h4020 && address[15:0] < 16'h6000)
address_wire = address - 16'h4020;

else if (address[15:0] >= 16'h6000 && address[15:0] < 16'h8000)
address_wire = address - 16'h6000;

else
begin
address_wire = address - 16'hC000;
bus = 2'b00;
end
end
endmodule 