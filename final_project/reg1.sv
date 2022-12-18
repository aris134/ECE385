module reg1
(
		input 	Clk,Reset,nmi_assert,nmi_done,
		output	nmi_status
);

logic out;
assign nmi_status = out;

always_ff @ (posedge Clk or posedge Reset or posedge nmi_done)
begin
if (Reset || nmi_done)
	out <= 1'b0;
else if (nmi_assert == 1'b1)
	out <= 1'b1;
end

endmodule