module Computation_Unit(input C_flag,n_select,
			  input [1:0] v_select,
			  input [4:0] ALUK,
			  input [3:0] c_select,
			  input [7:0] Accumulator, X, Y, M, SP,
			  output [7:0] result,
			  output v_flag, c_flag, neg_flag, zero_flag);
			  
			  
	 
logic [7:0] ORA;
logic [7:0] AND;
logic [7:0] EOR;
logic [8:0] ADC;
logic [8:0] SBC;
logic [7:0] LSR_A;
logic [7:0] LSR_M;
logic [7:0] ROL_A;
logic [7:0] ROL_M;
logic [7:0] ROR_A;
logic [7:0] ROR_M;
logic [8:0] CPY;
logic [8:0] CPX;
logic [8:0] CMP;
logic [7:0] INC_X;
logic [7:0] INC_Y;
logic [7:0] INC_M;
logic [7:0] ASL_A;
logic [7:0] ASL_M;
logic [7:0] DEC_M;
logic [7:0] DEC_X;
logic [7:0] DEC_Y;
logic v_wc; // overflow for ADC
logic v_sc; // overflow for SBC
logic c_sub;
logic c_add;
logic c_cmp;
logic c;
logic v;
logic LSB;
logic MSB;
logic [7:0] out;
logic n_math;
logic n;
logic z;


assign c_flag = c;
assign neg_flag = n;
assign zero_flag = z; 
assign result = out; 
assign v_flag = v;

assign ADC = {1'b0,Accumulator} + {1'b0,M} + {8'b00000000,C_flag};
assign SBC = {1'b0,Accumulator} - {1'b0,M} - {8'b00000000,~C_flag}; 
assign CMP = {1'b0,Accumulator} - {1'b0,M};
assign CPX = {1'b0,X} - {1'b0,M};
assign CPY = {1'b0,Y} - {1'b0,M};
assign ORA = Accumulator | M;
assign AND = Accumulator & M;
assign EOR = Accumulator ^ M;
assign c_sub = ~SBC[8];
assign c_add = ADC[8];
assign v_wc = (Accumulator[7] ~^ M[7]) & (Accumulator[7]^out[7]);
assign v_sc = (Accumulator[7] ^ M[7]) & (M[7] ~^ out[7]);
assign LSR_A = {1'b0,Accumulator[7:1]};
assign LSR_M = {1'b0,M[7:1]};
assign ROL_A = {Accumulator[6:0],LSB};
assign ROL_M = {M[6:0],LSB};
assign ASL_A = {Accumulator[6:0],1'b0};
assign ASL_M = {M[6:0],1'b0};
assign ROR_A = {MSB, Accumulator[7:1]};
assign ROR_M = {MSB, M[7:1]};
assign INC_X = X + 1'b1;
assign INC_Y = Y + 1'b1;
assign INC_M = M + 1'b1;
assign DEC_X = X - 1'b1;
assign DEC_Y = Y - 1'b1;
assign DEC_M = M - 1'b1;

mux2 neg_mux(.Din0(n_math),.Din1(M[7]),.select(n_select),.Dout(n));

mux4_1 v_mux(.Din0(v_wc),.Din1(M[6]),.Din2(1'b0),.Din3(v_sc),.select(v_select),.Dout(v));

mux9 carry_mux(.Din0(c_sub),.Din1(c_add),.Din2(Accumulator[0]),
.Din3(M[0]),.Din4(Accumulator[7]),.Din5(M[7]),.Din6(c_cmp),.Din7(1'b1),
.Din8(1'b0),.select(c_select),.Dout(c));

compute_mux function_gen(.ORA(ORA),.AND(AND),.EOR(EOR),.ADC(ADC[7:0]),.SBC(SBC[7:0]),.LSR_A(LSR_A),
.LSR_M(LSR_M),.ROL_A(ROL_A),.ROL_M(ROL_M),.ROR_A(ROR_A),.ROR_M(ROR_M),.PASS_X(X),
.PASS_Y(Y),.PASS_M(M),.PASS_A(Accumulator),.ASL_A(ASL_A),.ASL_M(ASL_M),
.INC_X(INC_X),.INC_Y(INC_Y),.INC_M(INC_M),
.DEC_X(DEC_X),.DEC_Y(DEC_Y),.DEC_M(DEC_M),
.CMP(CMP),.CPX(CPX),.CPY(CPY),.PASS_SP(SP),.select(ALUK),.Dout(out));

always_comb
begin
if (C_flag)
LSB = 1'b1;
else LSB = 1'b0;
end

always_comb
begin
if (C_flag) 
MSB = 1'b1;
else MSB = 1'b0;
end

always_comb
begin
if (out==8'b00000000)
z = 1'b1;
else
z = 1'b0;
n_math = out[7] | 1'b0; 
c_cmp = ~n;
end

endmodule 