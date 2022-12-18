module testbench();

timeunit 10ns;
timeprecision 1ns;

logic CLOCK_50 = 0;

logic VGA_CLK,VGA_SYNC_N,VGA_BLANK_N,VGA_VS,VGA_HS;
logic [7:0] VGA_R,VGA_G,VGA_B;
logic [3:0] KEY;
logic [17:0] SW;

nes NESsim(.*);

always begin : CLOCK_GENERATION
#1 CLOCK_50 = ~CLOCK_50;
end
initial begin: CLOCK_INITIALIZATION
CLOCK_50 = 0;
end

initial begin
KEY[1] = 1;
#2 KEY[1] = 0;
#2 KEY[1] = 1;
end
endmodule 