module testbench();

timeunit 10ns;
timeprecision 1ns;

logic Clk = 0; 

logic C_flag, v_select;
logic [2:0] ALUK, c_select;
logic [7:0] Accumulator, X, Y, M;
logic[7:0] result;
logic v_flag, c_flag, neg_flag, zero_flag;

simulation simulation0(.*);

always begin : CLOCK_GENERATION
#1 Clk = ~Clk;
end

initial begin: CLOCK_INITIALIZATION
    Clk = 0;
end 

initial begin

Reset = 0;
Run = 1; 
Continue = 1; 
Switches = 16'h005A;
#2 Reset = 1; 
#4 Run = 0; 
#2 Run = 1;
#60 Switches = 16'h0001;


end

endmodule 