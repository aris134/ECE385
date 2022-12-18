module CPU(input Clk, Reset, IRQ, NMI, StopCPU,
			  input [7:0] Data_in,controller_data,
			  input [7:0] DMA,
			  output [7:0] Data_out,Data4016,OAMOffset,
			  output [15:0] Address_out,
			  output [1:0] BUS_SELECT,
			  output WE,
			  output REG_LOAD,DMA_select,OAMWrite,OAMAddrInc);

enum logic [8:0] {INIT, START_1, START_2, FETCH, //DECODE, 
ADC_I, ADC_Z_1, ADC_Z_2, ADC_Z_X_1, ADC_Z_X_2, ADC_Z_X_3, // ADC
ADC_ABS_1, ADC_ABS_2, ADC_ABS_3, ADC_ABS_X_1, ADC_ABS_X_2, ADC_ABS_X_3, ADC_ABS_X_4,
ADC_ABS_Y_1, ADC_ABS_Y_2, ADC_ABS_Y_3, ADC_ABS_Y_4, 
ADC_IND_X_1, ADC_IND_X_2, ADC_IND_X_3, ADC_IND_X_4, ADC_IND_X_5,
ADC_IND_Y_1, ADC_IND_Y_2, ADC_IND_Y_3, ADC_IND_Y_4, ADC_IND_Y_5,
AND_I, AND_Z_1, AND_Z_2, AND_Z_X_1, AND_Z_X_2, AND_Z_X_3, // AND
AND_ABS_1, AND_ABS_2, AND_ABS_3, AND_ABS_X_1, AND_ABS_X_2, AND_ABS_X_3, AND_ABS_X_4,
AND_ABS_Y_1, AND_ABS_Y_2, AND_ABS_Y_3, AND_ABS_Y_4, 
AND_IND_X_1, AND_IND_X_2, AND_IND_X_3, AND_IND_X_4, AND_IND_X_5,
AND_IND_Y_1, AND_IND_Y_2, AND_IND_Y_3, AND_IND_Y_4, AND_IND_Y_5,
LDA_I, LDA_Z_1, LDA_Z_2, LDA_Z_X_1, LDA_Z_X_2, LDA_Z_X_3, // LDA
LDA_ABS_1, LDA_ABS_2, LDA_ABS_3, LDA_ABS_X_1, LDA_ABS_X_2, LDA_ABS_X_3, LDA_ABS_X_4,
LDA_ABS_Y_1, LDA_ABS_Y_2, LDA_ABS_Y_3, LDA_ABS_Y_4, 
LDA_IND_X_1, LDA_IND_X_2, LDA_IND_X_3, LDA_IND_X_4, LDA_IND_X_5,
LDA_IND_Y_1, LDA_IND_Y_2, LDA_IND_Y_3, LDA_IND_Y_4, LDA_IND_Y_5,
LDX_I,LDX_Z_1, LDX_Z_2, LDX_Z_Y_1, LDX_Z_Y_2, LDX_Z_Y_3, // LDX
LDX_ABS_1, LDX_ABS_2, LDX_ABS_3, LDX_ABS_Y_1, LDX_ABS_Y_2, LDX_ABS_Y_3, LDX_ABS_Y_4, 
LDY_I, LDY_Z_1, LDY_Z_2, LDY_Z_X_1, LDY_Z_X_2, LDY_Z_X_3, // LDY 
LDY_ABS_1, LDY_ABS_2, LDY_ABS_3, LDY_ABS_X_1, LDY_ABS_X_2, LDY_ABS_X_3, LDY_ABS_X_4,
// ASL
ASL_A, ASL_Z_1, ASL_Z_2, ASL_Z_3, ASL_Z_4,
ASL_Z_X_1, ASL_Z_X_2, ASL_Z_X_3, ASL_Z_X_4, ASL_Z_X_5,
ASL_ABS_1, ASL_ABS_2, ASL_ABS_3, ASL_ABS_4, ASL_ABS_5,
ASL_ABS_X_1, ASL_ABS_X_2, ASL_ABS_X_3, ASL_ABS_X_4, ASL_ABS_X_5, ASL_ABS_X_6,
// LSR
LSR_A, LSR_Z_1, LSR_Z_2, LSR_Z_3, LSR_Z_4,
LSR_Z_X_1, LSR_Z_X_2, LSR_Z_X_3, LSR_Z_X_4, LSR_Z_X_5,
LSR_ABS_1, LSR_ABS_2, LSR_ABS_3, LSR_ABS_4, LSR_ABS_5,
LSR_ABS_X_1, LSR_ABS_X_2, LSR_ABS_X_3, LSR_ABS_X_4, LSR_ABS_X_5, LSR_ABS_X_6,
// ROL
ROL_A, ROL_Z_1, ROL_Z_2, ROL_Z_3, ROL_Z_4,
ROL_Z_X_1, ROL_Z_X_2, ROL_Z_X_3, ROL_Z_X_4, ROL_Z_X_5,
ROL_ABS_1, ROL_ABS_2, ROL_ABS_3, ROL_ABS_4, ROL_ABS_5,
ROL_ABS_X_1, ROL_ABS_X_2, ROL_ABS_X_3, ROL_ABS_X_4, ROL_ABS_X_5, ROL_ABS_X_6,
// ROR
ROR_A, ROR_Z_1, ROR_Z_2, ROR_Z_3, ROR_Z_4,
ROR_Z_X_1, ROR_Z_X_2, ROR_Z_X_3, ROR_Z_X_4, ROR_Z_X_5,
ROR_ABS_1, ROR_ABS_2, ROR_ABS_3, ROR_ABS_4, ROR_ABS_5,
ROR_ABS_X_1, ROR_ABS_X_2, ROR_ABS_X_3, ROR_ABS_X_4, ROR_ABS_X_5, ROR_ABS_X_6,
// Branches
BCC_1, BCC_2, BCC_3, BCS_1, BCS_2, BCS_3, BEQ_1, BEQ_2, BEQ_3,
BMI_1, BMI_2, BMI_3, BNE_1, BNE_2, BNE_3, 
BPL_1, BPL_2, BPL_3, BVC_1, BVC_2, BVC_3, 
BVS_1, BVS_2, BVS_3,
// clears and sets
CLC, CLI, CLV, CLD, SEC, SEI,
SBC_I, SBC_Z_1, SBC_Z_2, SBC_Z_X_1, SBC_Z_X_2, SBC_Z_X_3, // SBC
SBC_ABS_1, SBC_ABS_2, SBC_ABS_3, SBC_ABS_X_1, 
// SBC
SBC_ABS_X_2, SBC_ABS_X_3, SBC_ABS_X_4,
SBC_ABS_Y_1, SBC_ABS_Y_2, SBC_ABS_Y_3, SBC_ABS_Y_4, 
SBC_IND_X_1, SBC_IND_X_2, SBC_IND_X_3, SBC_IND_X_4, SBC_IND_X_5,
SBC_IND_Y_1, SBC_IND_Y_2, SBC_IND_Y_3, SBC_IND_Y_4, SBC_IND_Y_5,
// CMP instructions
CMP_I,CMP_Z_1,CMP_Z_2, CMP_Z_X_1, CMP_Z_X_2, CMP_Z_X_3,
CMP_ABS_1, CMP_ABS_2, CMP_ABS_3, CMP_ABS_X_1, CMP_ABS_X_2, CMP_ABS_X_3, CMP_ABS_X_4,
CMP_ABS_Y_1, CMP_ABS_Y_2, CMP_ABS_Y_3, CMP_ABS_Y_4, 
CMP_IND_X_1, CMP_IND_X_2, CMP_IND_X_3, CMP_IND_X_4, CMP_IND_X_5,
CMP_IND_Y_1, CMP_IND_Y_2, CMP_IND_Y_3, CMP_IND_Y_4, CMP_IND_Y_5,
// CPX instructions
CPX_I,CPX_Z_1,CPX_Z_2,
CPX_ABS_1, CPX_ABS_2, CPX_ABS_3,
// CPY instructions
CPY_I,CPY_Z_1,CPY_Z_2,
CPY_ABS_1, CPY_ABS_2, CPY_ABS_3,
// DEC
DEC_Z_1, DEC_Z_2, DEC_Z_3, DEC_Z_4,DEC_Z_X_1, DEC_Z_X_2, DEC_Z_X_3, DEC_Z_X_4, DEC_Z_X_5,
DEC_ABS_1, DEC_ABS_2, DEC_ABS_3, DEC_ABS_4, DEC_ABS_5, 
DEC_ABS_X_1, DEC_ABS_X_2, DEC_ABS_X_3, DEC_ABS_X_4, DEC_ABS_X_5, DEC_ABS_X_6,
DEX, DEY,
// INC
INC_Z_1, INC_Z_2, INC_Z_3, INC_Z_4,INC_Z_X_1, INC_Z_X_2, INC_Z_X_3, INC_Z_X_4, INC_Z_X_5,
INC_ABS_1, INC_ABS_2, INC_ABS_3, INC_ABS_4, INC_ABS_5, 
INC_ABS_X_1, INC_ABS_X_2, INC_ABS_X_3, INC_ABS_X_4, INC_ABS_X_5, INC_ABS_X_6,
INX, INY,
// ORA
ORA_I, ORA_Z_1, ORA_Z_2, ORA_Z_X_1, ORA_Z_X_2, ORA_Z_X_3, // ORA
ORA_ABS_1, ORA_ABS_2, ORA_ABS_3, ORA_ABS_X_1, ORA_ABS_X_2, ORA_ABS_X_3, ORA_ABS_X_4,
ORA_ABS_Y_1, ORA_ABS_Y_2, ORA_ABS_Y_3, ORA_ABS_Y_4, 
ORA_IND_X_1, ORA_IND_X_2, ORA_IND_X_3, ORA_IND_X_4, ORA_IND_X_5,
ORA_IND_Y_1, ORA_IND_Y_2, ORA_IND_Y_3, ORA_IND_Y_4, ORA_IND_Y_5,
// EOR
EOR_I, EOR_Z_1, EOR_Z_2, EOR_Z_X_1, EOR_Z_X_2, EOR_Z_X_3, // EOR
EOR_ABS_1, EOR_ABS_2, EOR_ABS_3, EOR_ABS_X_1, EOR_ABS_X_2, EOR_ABS_X_3, EOR_ABS_X_4,
EOR_ABS_Y_1, EOR_ABS_Y_2, EOR_ABS_Y_3, EOR_ABS_Y_4, 
EOR_IND_X_1, EOR_IND_X_2, EOR_IND_X_3, EOR_IND_X_4, EOR_IND_X_5,
EOR_IND_Y_1, EOR_IND_Y_2, EOR_IND_Y_3, EOR_IND_Y_4, EOR_IND_Y_5, NOP,
//BIT TEST
BIT_Z_1, BIT_Z_2, BIT_ABS_1, BIT_ABS_2, BIT_ABS_3,
// STA 
STA_Z_1, STA_Z_2, STA_Z_X_1, STA_Z_X_2, STA_Z_X_3, STA_ABS_1, STA_ABS_2, STA_ABS_3,
STA_ABS_X_1, STA_ABS_X_2, STA_ABS_X_3, STA_ABS_X_4, 
STA_ABS_Y_1, STA_ABS_Y_2, STA_ABS_Y_3, STA_ABS_Y_4, 
STA_IND_X_1, STA_IND_X_2, STA_IND_X_3, STA_IND_X_4, STA_IND_X_5,
STA_IND_Y_1, STA_IND_Y_2, STA_IND_Y_3, STA_IND_Y_4, STA_IND_Y_5,
// STX
STX_Z_1, STX_Z_2, STX_Z_Y_1, STX_Z_Y_2, STX_Z_Y_3, 
STX_ABS_1, STX_ABS_2, STX_ABS_3,
// STY
STY_Z_1, STY_Z_2, STY_Z_X_1, STY_Z_X_2, STY_Z_X_3, 
STY_ABS_1, STY_ABS_2, STY_ABS_3,
// Transfers
TAX, TAY, TSX, TXA, TXS, TYA,
// JMP
JMP_ABS_1, JMP_ABS_2, JMP_IND_1, JMP_IND_2, JMP_IND_3, JMP_IND_4,
// JSR
JSR_1, JSR_2, JSR_3, JSR_4, JSR_5,
// RTS
RTS_1, RTS_2, RTS_3, RTS_4, RTS_5,
// RTI
RTI_1, RTI_2, RTI_3, RTI_4, RTI_5,
// BRK
BRK_1, BRK_2, BRK_3, BRK_4, BRK_5, BRK_6,
// push/pull A and P
PHA_1, PHA_2, PHP_1, PHP_2,
PLA_1, PLA_2, PLA_3, PLP_1, PLP_2, PLP_3,
DMA_1, DMA_2,
// NMI
NMI_1, NMI_2, NMI_3, NMI_4, NMI_5, NMI_6
}   State, Next_state;

logic [15:0] pc_dec;
logic w;
logic we;
assign WE = we;
logic reg_file_load,dma_select,OAM_write,oam_addr_inc;
assign OAMAddrInc = oam_addr_inc;
assign OAMWrite = OAM_write;
assign DMA_select = dma_select;
assign REG_LOAD = reg_file_load;
logic [2:0] databus_select;
logic [15:0] branch16;
logic [15:0] address;
logic q;
logic nmi_assert,nmi_done,nmi_status,addr_reg_nmi;
logic fixUB; 
logic fixUB_PC;
logic [15:0] x_sum_buff;
logic [15:0] y_sum_buff;
logic [15:0] ubmux;
logic  [1:0] bus;
assign BUS_SELECT = bus;
logic [7:0] pc_data_out,data_out;
assign Data_out = data_out;
logic irq; // added irq signal for BRK

//register wires
logic [7:0] accumulator_in;
logic [7:0] accumulator_out;
logic [15:0] pc_in;
logic [15:0] pc_out;
logic [7:0] x_in;
logic [7:0] x_out;
logic [7:0] y_in;
logic [7:0] y_out;
logic [7:0] p_out;
logic [7:0] sp_in; // added sp_in
logic [7:0] sp_out;
logic [15:0] addr_buff_out;
logic [15:0] ind_in;
logic [15:0] ind_out;
logic [7:0] databuff_in;
logic [7:0] databuff_out;
logic [7:0] dma_out;
logic [7:0] counter_in;
logic [7:0] counter_out;
assign counter_in = counter_out + 1'b1;
logic [15:0] dma_pointer;
assign dma_pointer = {DMA,counter_out};
assign OAMOffset = counter_out;

// mux control signals
logic YMUX;
logic [1:0] XMUX;
logic [1:0] PCMUX;
logic AMUX;
logic [3:0] ADDRMUX;
logic UBMUX; 
logic [2:0] INDMUX;	// changed INDMUX to [3:0]
logic PCOUTMUX; // added for pc dataout mux
logic [1:0] STACKMUX; // added for stack pointer mux

// general register control signals
logic LOAD_X;
logic LOAD_Y;
logic LOAD_A;
logic LOAD_SP;
logic LOAD_PC;
logic LOAD_PC_LB;
logic LOAD_PC_UB;
logic LOAD_ADDRBUFF;
logic LOAD_ADDRBUFF_UB;
logic LOAD_ADDRBUFF_LB;
logic LOAD_IND_UB;
logic LOAD_IND_LB;
logic LOAD_IND;
logic LOAD_DATA;
logic inc_counter;

// status register control signals
logic sei;
logic sec;
logic cli;
logic clc;
logic clv;
logic PLP;
logic brk;
logic Ld_N;
logic Ld_Z;
logic Ld_C;
logic Ld_V;

// computation unit signals
logic V, C, N, Z; 
logic [7:0] alu_out;
logic n_select;
logic [1:0] v_select;
logic [4:0] ALUK;
logic [3:0] c_select;

//registers
reg8 X (.Clk(Clk),.Reset(Reset),.Load(LOAD_X),.Data_In(x_in),.Data_Out(x_out));
reg8 Y (.Clk(Clk),.Reset(Reset),.Load(LOAD_Y),.Data_In(y_in),.Data_Out(y_out));
reg8 A (.Clk(Clk),.Reset(Reset),.Load(LOAD_A),.Data_In(accumulator_in),.Data_Out(accumulator_out));
pc_reg PC (.Clk(Clk),.Reset(Reset),.Load(LOAD_PC),.LoadUB(LOAD_PC_UB),.LoadLB(LOAD_PC_LB),.Data_In(pc_in),
.Data_Out(pc_out));
sp_reg StackPointer (.Clk(Clk),.Reset(Reset),.Load(LOAD_SP),.Data_In(sp_in),.Data_Out(sp_out)); // added sp_in for mux
p_reg P (.Clk(Clk),.Reset(Reset),.SEI(sei),.SEC(sec),.CLI(cli),.CLV(clv),.CLC(clc),.N(N),.LoadN(Ld_N),.V(V),.LoadV(Ld_V),
.Z(Z),.LoadZ(Ld_Z),.C(C),.LoadC(Ld_C),.BRK(brk),.PLP(PLP),.Data_In(alu_out),.Data_Out(p_out));
ADDR_REG reg_addr (.Clk(Clk),.Reset(Reset),.LoadUB(LOAD_ADDRBUFF_UB),.LoadLB(LOAD_ADDRBUFF_LB),
.Load(LOAD_ADDRBUFF),.IRQ(irq),.NMI(addr_reg_nmi),.Data_In({8'h00,Data_in}),.Data_Out(addr_buff_out));
pc_reg INDIRECT (.Clk(Clk),.Reset(Reset),.LoadUB(LOAD_IND_UB),.LoadLB(LOAD_IND_LB),
.Load(LOAD_IND),.Data_In(ind_in),
.Data_Out(ind_out));
reg8 DATA_BUFFER (.Clk(Clk),.Reset(Reset),.Load(LOAD_DATA),
.Data_In(alu_out),.Data_Out(databuff_out));
/*reg8 DMA_BUFFER (.Clk(Clk),.Reset(Reset),.Load(LOAD_DMA),
.Data_In(Data_in),.Data_Out(dma_out));*/
reg8 DMA_COUNTER (.Clk(Clk),.Reset(Reset),.Load(inc_counter),
.Data_In(counter_in),.Data_Out(counter_out));

// controller registers
logic strobe,controller_shift,controller_out;
logic load4016;
logic [7:0] data_4016;
assign Data4016 = data_4016;
controller_reg ControllerReg(.Clk(Clk),.Reset(Reset),.Load(strobe),.Shift_Enable(controller_shift),.Data_In(controller_data),.Data_Out(controller_out));
reg4016 Reg4016(.Clk(Clk),.Reset(Reset),.Load(load4016),.Shift_In(controller_out),.Shift_Enable(controller_shift),.Data_In(data_out),.Data_Out(data_4016));
flip_flop Strobe(.Clk(Clk),.Reset(Reset),.Load(load4016),.D(data_out[0]),.Q(strobe));

// SEXT
PCoffset8 pc_offset (.offset(Data_in),.sext(branch16));

// flip flop for NMI
edge_detector NMI_detector(.Clk(Clk),.NMI(NMI),.Reset(Reset),.NMI_assert(nmi_assert));
reg1 NMI_reg(.Clk(Clk),.Reset(Reset),.nmi_assert(nmi_assert),.nmi_done(nmi_done),.nmi_status(nmi_status));

// muxes
mux7_8 databus_mux (.Din0(x_out),.Din1(y_out),.Din2(accumulator_out),.Din3(p_out),
.Din4(databuff_out),.Din5(pc_data_out),.Din6(dma_out),
.select(databus_select),.Dout(data_out));	// added pc_data_out din5, changed to mux6
mux2_8 MUX_Y (.Din0(Data_in),.Din1(alu_out),.select(YMUX),.Dout(y_in));
mux2_8 MUX_A (.Din0(Data_in),.Din1(alu_out),.select(AMUX),.Dout(accumulator_in));
mux3_8 MUX_X (.Din0(Data_in),.Din1(alu_out),.Din2(sp_out),.select(XMUX),.Dout(x_in));
mux4_16 MUX_PC (.Din0({8'h00,Data_in}),.Din1(branch16 + pc_out + 16'h0001),.Din2(pc_out + 16'h0001),.Din3(addr_buff_out),
.select(PCMUX),.Dout(pc_in));	// changed to mux4, added addr_buff_out din3
mux11_16 MUX_ADDR (.Din0({8'h01,sp_out}),.Din1(addr_buff_out),		// changed din0 to include 0x0100 offset
.Din2({addr_buff_out[15:8],addr_buff_out[7:0]+x_out}),
.Din3({addr_buff_out[15:8],addr_buff_out[7:0]+y_out}),
.Din4(pc_out),.Din5(addr_buff_out+1'b1),.Din6(ind_out+1'b1),.Din7({8'b0,Data_in+x_out}),	// changed Din6 to ind_out+1
.Din8({8'b0,Data_in+y_out}),.Din9(ind_out),.Din10(dma_pointer),.select(ADDRMUX),.Dout(address));
mux5_16 MUX_IND (.Din0({8'b0,x_out+Data_in}),.Din1({8'b0,y_out+Data_in}),.Din2(ind_out+16'h0001),
.Din3({8'b0,Data_in}),.Din4(pc_out),.select(INDMUX),.Dout(ind_in)); // changed to mux5, added pc_out
// new muxes
mux2_8 PCdataout_mux (.Din0(pc_out[15:8]),.Din1(pc_out[7:0]),.select(PCOUTMUX),.Dout(pc_data_out));
mux3_8 MUX_SP (.Din0(x_out),.Din1(sp_out-1'b1),.Din2(sp_out+1'b1),.select(STACKMUX),.Dout(sp_in));

// computation Unit
Computation_Unit ALU (.C_flag(p_out[0]),.n_select(n_select),.v_select(v_select),.ALUK(ALUK),
.c_select(c_select),.Accumulator(accumulator_out),.X(x_out),.Y(y_out),.M(Data_in),
.SP(sp_out),.result(alu_out),
.v_flag(V),.c_flag(C),.neg_flag(N),.zero_flag(Z));

// address decoder
addr_decoder ADDRESS_DECODE (.address(address),.w(w),.address_out(Address_out),.bus_select(bus),
.we(we),.reg_file_load(reg_file_load),.Load4016(load4016),.Read4016(controller_shift));


assign x_sum_buff = {8'b0,x_out} + addr_buff_out;
assign y_sum_buff = {8'b0,y_out} + addr_buff_out;
mux2_16 MUXUB (.Din0(x_sum_buff),.Din1(y_sum_buff),.select(UBMUX),.Dout(ubmux));
assign fixUB = ubmux[15:8] ^ addr_buff_out[15:8]; 
assign pc_dec = pc_out - 1'b1;
assign fixUB_PC = pc_dec[15:8] ^ pc_in[15:8];

 always_ff @ (posedge Clk or posedge Reset)
    begin 
        if (Reset) 
            State <= START_1;
        else 
            State <= Next_state;
    end
	 
	 
   //**** STATE TRANSITIONS ****//
	always_comb 
	begin
	Next_state = State; 
	
	unique case (State)
		INIT 	:
			if (Reset)
				Next_state <= START_1;
		START_1 :
				Next_state <= START_2;
		START_2 : 
				Next_state <= FETCH;
		FETCH :
				if (nmi_status)
					Next_state <= NMI_1;
				else if (StopCPU)
					Next_state <= FETCH;
				else
				begin
				case (Data_in)
				8'h69 : 
					Next_state <= ADC_I;
				8'h65 :
					Next_state <= ADC_Z_1;
				8'h75 :
					Next_state <= ADC_Z_X_1;
				8'h6D :
					Next_state <= ADC_ABS_1;
				8'h7D :
					Next_state <= ADC_ABS_X_1;
				8'h79 :
					Next_state <= ADC_ABS_Y_1;
				8'h61 :
					Next_state <= ADC_IND_X_1;
				8'h71 :
					Next_state <= ADC_IND_Y_1;
				8'hA0 :
					Next_state <= LDY_I;
				8'hA2 :
					Next_state <= LDX_I;
				8'h29 :
					Next_state <= AND_I;
				8'h25 :
					Next_state <= AND_Z_1;
				8'h35 :
					Next_state <= AND_Z_X_1;
				8'h2D :
					Next_state <= AND_ABS_1;
				8'h3D :
					Next_state <= AND_ABS_X_1;
				8'h39 :
					Next_state <= AND_ABS_Y_1;
				8'h21 :
					Next_state <= AND_IND_X_1;
				8'h31 :
					Next_state <= AND_IND_Y_1;
				8'h0A :
					Next_state <= ASL_A; 
				8'h06 :
					Next_state <= ASL_Z_1;
				8'h16 :
					Next_state <= ASL_Z_X_1;
				8'h0E :
					Next_state <= ASL_ABS_1;
				8'h1E :
					Next_state <= ASL_ABS_X_1;
				8'h90 :
					Next_state <= BCC_1;
				8'hb0 :
					Next_state <= BCS_1;
				8'hf0 :
					Next_state <= BEQ_1;
				8'h30 :
					Next_state <= BMI_1;
				8'hd0 :
					Next_state <= BNE_1;
				8'h10 :
					Next_state <= BPL_1;
				8'h50 :
					Next_state <= BVC_1;
				8'h70 :
					Next_state <= BVS_1;
				8'h18 :
					Next_state <= CLC;
				8'h58 :
					Next_state <= CLI;
				8'hb8 :
					Next_state <= CLV;
				8'h38 :
					Next_state <= SEC;
				8'h78 :
					Next_state <= SEI;
				8'hE9 :
					Next_state <= SBC_I;
				8'hE5 :
					Next_state <= SBC_Z_1;
				8'hF5 :
					Next_state <= SBC_Z_X_1;
				8'hED :
					Next_state <= SBC_ABS_1;
				8'hFD :
					Next_state <= SBC_ABS_X_1;
				8'hF9 :
					Next_state <= SBC_ABS_Y_1;
				8'hE1 :
					Next_state <= SBC_IND_X_1;
				8'hF1 :
					Next_state <= SBC_IND_Y_1;
				8'hc9 :
					Next_state <= CMP_I;
				8'ha9 :
					Next_state <= LDA_I;
				8'hC5 :
					Next_state <= CMP_Z_1;
				8'hD5 :
					Next_state <= CMP_Z_X_1;
				8'hcd :
					Next_state <= CMP_ABS_1;
				8'hdd :
					Next_state <= CMP_ABS_X_1;
				8'hd9 :
					Next_state <= CMP_ABS_Y_1;
				8'hc1 :
					Next_state <= CMP_IND_X_1;
				8'hd1 :
					Next_state <= CMP_IND_Y_1;
				8'he0 :
					Next_state <= CPX_I;
				8'he4 :
					Next_state <= CPX_Z_1;
				8'hec :
					Next_state <= CPX_ABS_1;
				8'hc0 :
					Next_state <= CPY_I;
				8'hc4 :
					Next_state <= CPY_Z_1;
				8'hcc :
					Next_state <= CPY_ABS_1;
				8'hc6 :
					Next_state <= DEC_Z_1;
				8'hd6 :
					Next_state <= DEC_Z_X_1;
				8'hce :
					Next_state <= DEC_ABS_1;
				8'hde :
					Next_state <= DEC_ABS_X_1;
				8'hca :
					Next_state <= DEX;
				8'h88 :
					Next_state <= DEY;
				8'h09 :
					Next_state <= ORA_I;
				8'h05 :
					Next_state <= ORA_Z_1;
				8'h15 :
					Next_state <= ORA_Z_X_1;
				8'h0d :
					Next_state <= ORA_ABS_1;
				8'h1d :
					Next_state <= ORA_ABS_X_1;
				8'h19 :
					Next_state <= ORA_ABS_Y_1;
				8'h01 :
					Next_state <= ORA_IND_X_1;
				8'h11 :
					Next_state <= ORA_IND_Y_1;
					//
				8'h49 :
					Next_state <= EOR_I;
				8'h45 :
					Next_state <= EOR_Z_1;
				8'h55 :
					Next_state <= EOR_Z_X_1;
				8'h4d :
					Next_state <= EOR_ABS_1;
				8'h5d :
					Next_state <= EOR_ABS_X_1;
				8'h59 :
					Next_state <= EOR_ABS_Y_1;
				8'h41 :
					Next_state <= EOR_IND_X_1;
				8'h51 :
					Next_state <= EOR_IND_Y_1;
				8'hea :
					Next_state <= NOP;
				8'he6 :
					Next_state <= INC_Z_1;
				8'hf6 :
					Next_state <= INC_Z_X_1;
				8'hee :
					Next_state <= INC_ABS_1;
				8'hfe :
					Next_state <= INC_ABS_X_1;
				8'he8 :
					Next_state <= INX;
				8'hc8 :
					Next_state <= INY;
				8'h24 :
					Next_state <= BIT_Z_1;
				8'h2c :
					Next_state <= BIT_ABS_1;
				8'hA5 :
					Next_state <= LDA_Z_1;
				8'hB5 :
					Next_state <= LDA_Z_X_1;
				8'hAD :
					Next_state <= LDA_ABS_1;
				8'hBD :
					Next_state <= LDA_ABS_X_1;
				8'hB9 :
					Next_state <= LDA_ABS_Y_1;
				8'hA1 :
					Next_state <= LDA_IND_X_1;
				8'hB1 :
					Next_state <= LDA_IND_Y_1;
				8'ha6 :
					Next_state <= LDX_Z_1;
				8'hb6 :
					Next_state <= LDX_Z_Y_1;
				8'hae :
					Next_state <= LDX_ABS_1;
				8'hbe :
					Next_state <= LDX_ABS_Y_1;
				//
				8'ha4 :
					Next_state <= LDY_Z_1;
				8'hb4 :
					Next_state <= LDY_Z_X_1;
				8'hac :
					Next_state <= LDY_ABS_1;
				8'hbc :
					Next_state <= LDY_ABS_X_1;
				//
				8'h4A :
					Next_state <= LSR_A; 
				8'h46 :
					Next_state <= LSR_Z_1;
				8'h56 :
					Next_state <= LSR_Z_X_1;
				8'h4E :
					Next_state <= LSR_ABS_1;
				8'h5E :
					Next_state <= LSR_ABS_X_1;
					//
				8'h2A :
					Next_state <= ROL_A; 
				8'h26 :
					Next_state <= ROL_Z_1;
				8'h36 :
					Next_state <= ROL_Z_X_1;
				8'h2E :
					Next_state <= ROL_ABS_1;
				8'h3E :
					Next_state <= ROL_ABS_X_1;
					//
				8'h6A :
					Next_state <= ROR_A; 
				8'h66 :
					Next_state <= ROR_Z_1;
				8'h76 :
					Next_state <= ROR_Z_X_1;
				8'h6E :
					Next_state <= ROR_ABS_1;
				8'h7E :
					Next_state <= ROR_ABS_X_1;
				8'h85 :
					Next_state <= STA_Z_1;
				8'h95 :
					Next_state <= STA_Z_X_1;
				8'h8d :
					Next_state <= STA_ABS_1;
				8'h9d :
					Next_state <= STA_ABS_X_1;
				8'h99 :
					Next_state <= STA_ABS_Y_1;
				8'h81 :
					Next_state <= STA_IND_X_1;
				8'h91 :
					Next_state <= STA_IND_Y_1;
				8'h86 :
					Next_state <= STX_Z_1;
				8'h96 :
					Next_state <= STX_Z_Y_1;
				8'h8E :
					Next_state <= STX_ABS_1;
				8'h84 :
					Next_state <= STY_Z_1;
				8'h94 :
					Next_state <= STY_Z_X_1;
				8'h8c :
					Next_state <= STY_ABS_1;
				8'hAA :
					Next_state <= TAX;
				8'hA8 :
					Next_state <= TAY;
				8'hBA :
					Next_state <= TSX;
				8'h8A :
					Next_state <= TXA;
				8'h9A :
					Next_state <= TXS;
				8'h98 :
					Next_state <= TYA;
				8'hD8 :
					Next_state <= CLD;
				8'h4C :
					Next_state <= JMP_ABS_1;
				8'h6C :
					Next_state <= JMP_IND_1;
				8'h20 :
					Next_state <= JSR_1;
				8'h60 :
					Next_state <= RTS_1;
				8'h40 :
					Next_state <= RTI_1;
				8'h00 :
					Next_state <= BRK_1;
				8'h48 :
					Next_state <= PHA_1;
				8'h08 :
					Next_state <= PHP_1;
				8'h68 :
					Next_state <= PLA_1;
				8'h28 :
					Next_state <= PLP_1;
				default ;
				endcase
				end
		ADC_I :
				Next_state <= FETCH;
		ADC_Z_1 :
				Next_state <= ADC_Z_2;
		ADC_Z_2 :
				Next_state <= FETCH;
		ADC_Z_X_1 :
				Next_state <= ADC_Z_X_2;
		ADC_Z_X_2 :
				Next_state <= ADC_Z_X_3;
		ADC_Z_X_3 :
				Next_state <= FETCH;
		ADC_ABS_1 :
				Next_state <= ADC_ABS_2;
		ADC_ABS_2 :
				Next_state <= ADC_ABS_3;
		ADC_ABS_3 :
				Next_state <= FETCH;
		ADC_ABS_X_1 :
				Next_state <= ADC_ABS_X_2;
		ADC_ABS_X_2 :
				Next_state <= ADC_ABS_X_3;
		ADC_ABS_X_3 :
				if (fixUB == 1'b1)
				Next_state <= ADC_ABS_X_4;
				else 
				Next_state <= FETCH;
		ADC_ABS_X_4 :
				Next_state <= FETCH;
		ADC_ABS_Y_1 :
				Next_state <= ADC_ABS_Y_2;
		ADC_ABS_Y_2 :
				Next_state <= ADC_ABS_Y_3;
		ADC_ABS_Y_3 :
				if (fixUB == 1'b1)
				Next_state <= ADC_ABS_Y_4;
				else 
				Next_state <= FETCH;
		ADC_ABS_Y_4 :
				Next_state <= FETCH;
		ADC_IND_X_1 :
				Next_state <= ADC_IND_X_2;
		ADC_IND_X_2 :
				Next_state <= ADC_IND_X_3;
		ADC_IND_X_3 :
				Next_state <= ADC_IND_X_4;
		ADC_IND_X_4 :
				Next_state <= ADC_IND_X_5;
		ADC_IND_X_5 :
				Next_state <= FETCH;
		ADC_IND_Y_1 :
				Next_state <= ADC_IND_Y_2;
		ADC_IND_Y_2 :
				Next_state <= ADC_IND_Y_3;
		ADC_IND_Y_3 :
				Next_state <= ADC_IND_Y_4;
		ADC_IND_Y_4 :
				if (fixUB == 1'b1)
				Next_state <= ADC_IND_Y_5;
				else
				Next_state <= FETCH;
		ADC_IND_Y_5 :
				Next_state <= FETCH;
		AND_I : // AND
				Next_state <= FETCH;
		AND_Z_1 :
				Next_state <= AND_Z_2;
		AND_Z_2 :
				Next_state <= FETCH;
		AND_Z_X_1 :
				Next_state <= AND_Z_X_2;
		AND_Z_X_2 :
				Next_state <= AND_Z_X_3;
		AND_Z_X_3 :
				Next_state <= FETCH;
		AND_ABS_1 :
				Next_state <= AND_ABS_2;
		AND_ABS_2 :
				Next_state <= AND_ABS_3;
		AND_ABS_3 :
				Next_state <= FETCH;
		AND_ABS_X_1 :
				Next_state <= AND_ABS_X_2;
		AND_ABS_X_2 :
				Next_state <= AND_ABS_X_3;
		AND_ABS_X_3 :
				if (fixUB == 1'b1)
				Next_state <= AND_ABS_X_4;
				else 
				Next_state <= FETCH;
		AND_ABS_X_4 :
				Next_state <= FETCH;
		AND_ABS_Y_1 :
				Next_state <= AND_ABS_Y_2;
		AND_ABS_Y_2 :
				Next_state <= AND_ABS_Y_3;
		AND_ABS_Y_3 :
				if (fixUB == 1'b1)
				Next_state <= AND_ABS_Y_4;
				else 
				Next_state <= FETCH;
		AND_ABS_Y_4 :
				Next_state <= FETCH;
		AND_IND_X_1 :
				Next_state <= AND_IND_X_2;
		AND_IND_X_2 :
				Next_state <= AND_IND_X_3;
		AND_IND_X_3 :
				Next_state <= AND_IND_X_4;
		AND_IND_X_4 :
				Next_state <= AND_IND_X_5;
		AND_IND_X_5 :
				Next_state <= FETCH;
		AND_IND_Y_1 :
				Next_state <= AND_IND_Y_2;
		AND_IND_Y_2 :
				Next_state <= AND_IND_Y_3;
		AND_IND_Y_3 :
				Next_state <= AND_IND_Y_4;
		AND_IND_Y_4 :
				if (fixUB == 1'b1)
				Next_state <= AND_IND_Y_5;
				else
				Next_state <= FETCH;
		AND_IND_Y_5 :
				Next_state <= FETCH;
		LDY_I :
				Next_state <= FETCH;
		LDX_I :
				Next_state <= FETCH;
		ASL_A :
				Next_state <= FETCH;
		ASL_Z_1 :
				Next_state <= ASL_Z_2;
		ASL_Z_2 :
				Next_state <= ASL_Z_3;
		ASL_Z_3 :
				Next_state <= ASL_Z_4;
		ASL_Z_4 :
				Next_state <= FETCH;
		ASL_Z_X_1 :
				Next_state <= ASL_Z_X_2;
		ASL_Z_X_2 :
				Next_state <= ASL_Z_X_3;
		ASL_Z_X_3 :
				Next_state <= ASL_Z_X_4; 
		ASL_Z_X_4 :
				Next_state <= ASL_Z_X_5; 
		ASL_Z_X_5 :
				Next_state <= FETCH;
		ASL_ABS_1 :
				Next_state <= ASL_ABS_2;
		ASL_ABS_2 :
				Next_state <= ASL_ABS_3;
		ASL_ABS_3 :
				Next_state <= ASL_ABS_4;
		ASL_ABS_4 :
				Next_state <= ASL_ABS_5;
		ASL_ABS_5 :
				Next_state <= FETCH;
		ASL_ABS_X_1 :
				Next_state <= ASL_ABS_X_2;
		ASL_ABS_X_2 :
				Next_state <= ASL_ABS_X_3;
		ASL_ABS_X_3 :
				Next_state <= ASL_ABS_X_4;
		ASL_ABS_X_4 :
				Next_state <= ASL_ABS_X_5;
		ASL_ABS_X_5 :
				Next_state <= ASL_ABS_X_6;
		ASL_ABS_X_6 :
				Next_state <= FETCH;
		BCC_1 :
				if (p_out[0] == 1'b0)
				Next_state <= BCC_2;
				else 
				Next_state <= FETCH;
		BCC_2 :
				if (fixUB_PC == 1'b1)
				Next_state <= BCC_3;
				else 
				Next_state <= FETCH;
		BCC_3 :
				Next_state <= FETCH;
				//
		BCS_1 :
				if (p_out[0] == 1'b1)
				Next_state <= BCS_2;
				else 
				Next_state <= FETCH;
		BCS_2 :
				if (fixUB_PC == 1'b1)
				Next_state <= BCS_3;
				else 
				Next_state <= FETCH;
		BCS_3 :
				Next_state <= FETCH;
		BEQ_1 :
				if (p_out[1] == 1'b1)
				Next_state <= BEQ_2;
				else 
				Next_state <= FETCH;
		BEQ_2 :
				if (fixUB_PC == 1'b1)
				Next_state <= BEQ_3;
				else 
				Next_state <= FETCH;
		BEQ_3 :
				Next_state <= FETCH;
		BMI_1 :
				if (p_out[7] == 1'b1)
				Next_state <= BMI_2;
				else 
				Next_state <= FETCH;
		BMI_2 :
				if (fixUB_PC == 1'b1)
				Next_state <= BMI_3;
				else 
				Next_state <= FETCH;
		BMI_3 :
				Next_state <= FETCH;
		BNE_1 :
				if (p_out[1] == 1'b0)
				Next_state <= BNE_2;
				else 
				Next_state <= FETCH;
		BNE_2 :
				if (fixUB_PC == 1'b1)
				Next_state <= BNE_3;
				else 
				Next_state <= FETCH;
		BNE_3 :
				Next_state <= FETCH;
		BPL_1 :
				if (p_out[7] == 1'b0)
				Next_state <= BPL_2;
				else 
				Next_state <= FETCH;
		BPL_2 :
				if (fixUB_PC == 1'b1)
				Next_state <= BPL_3;
				else 
				Next_state <= FETCH;
		BPL_3 :
				Next_state <= FETCH;
		BVC_1 :
				if (p_out[6] == 1'b0)
				Next_state <= BVC_2;
				else 
				Next_state <= FETCH;
		BVC_2 :
				if (fixUB_PC == 1'b1)
				Next_state <= BVC_3;
				else 
				Next_state <= FETCH;
		BVC_3 :
				Next_state <= FETCH;
		BVS_1 :
				if (p_out[6] == 1'b1)
				Next_state <= BVS_2;
				else 
				Next_state <= FETCH;
		BVS_2 :
				if (fixUB_PC == 1'b1)
				Next_state <= BVS_3;
				else 
				Next_state <= FETCH;
		BVS_3 :
				Next_state <= FETCH;
		CLC	:
				Next_state <= FETCH;
		CLI	:
				Next_state <= FETCH; 
		CLV	:
				Next_state <= FETCH;
		SEC	:
				Next_state <= FETCH;
		SEI	:
				Next_state <= FETCH;
		SBC_I :		// SBC
				Next_state <= FETCH;
		SBC_Z_1 :	
				Next_state <= SBC_Z_2;
		SBC_Z_2 :
				Next_state <= FETCH;
		SBC_Z_X_1 :
				Next_state <= SBC_Z_X_2;
		SBC_Z_X_2 :
				Next_state <= SBC_Z_X_3;
		SBC_Z_X_3 :
				Next_state <= FETCH;
		SBC_ABS_1 :
				Next_state <= SBC_ABS_2;
		SBC_ABS_2 :
				Next_state <= SBC_ABS_3;
		SBC_ABS_3 :
				Next_state <= FETCH;
		SBC_ABS_X_1 :
				Next_state <= SBC_ABS_X_2;
		SBC_ABS_X_2 :
				Next_state <= SBC_ABS_X_3;
		SBC_ABS_X_3 :
				if (fixUB == 1'b1)
				Next_state <= SBC_ABS_X_4;
				else 
				Next_state <= FETCH;
		SBC_ABS_X_4 :
				Next_state <= FETCH;
		SBC_ABS_Y_1 :
				Next_state <= SBC_ABS_Y_2;
		SBC_ABS_Y_2 :
				Next_state <= SBC_ABS_Y_3;
		SBC_ABS_Y_3 :
				if (fixUB == 1'b1)
				Next_state <= SBC_ABS_Y_4;
				else 
				Next_state <= FETCH;
		SBC_ABS_Y_4 :
				Next_state <= FETCH;
		SBC_IND_X_1 :
				Next_state <= SBC_IND_X_2;
		SBC_IND_X_2 :
				Next_state <= SBC_IND_X_3;
		SBC_IND_X_3 :
				Next_state <= SBC_IND_X_4;
		SBC_IND_X_4 :
				Next_state <= SBC_IND_X_5;
		SBC_IND_X_5 :
				Next_state <= FETCH;
		SBC_IND_Y_1 :
				Next_state <= SBC_IND_Y_2;
		SBC_IND_Y_2 :
				Next_state <= SBC_IND_Y_3;
		SBC_IND_Y_3 :
				Next_state <= SBC_IND_Y_4;
		SBC_IND_Y_4 :
				if (fixUB == 1'b1)
				Next_state <= SBC_IND_Y_5;
				else
				Next_state <= FETCH;
		SBC_IND_Y_5 :
				Next_state <= FETCH;
		CMP_I :
				Next_state <= FETCH;
		CMP_Z_1 :
				Next_state <= CMP_Z_2;
		CMP_Z_2 :
				Next_state <= FETCH;
		CMP_Z_X_1 :
				Next_state <= CMP_Z_X_2;
		CMP_Z_X_2 :
				Next_state <= CMP_Z_X_3;
		CMP_Z_X_3 :
				Next_state <= FETCH;
		CMP_ABS_1 :
				Next_state <= CMP_ABS_2;
		CMP_ABS_2 :
				Next_state <= CMP_ABS_3;
		CMP_ABS_3 :
				Next_state <= FETCH;
		CMP_ABS_X_1 :
				Next_state <= CMP_ABS_X_2;
		CMP_ABS_X_2 :
				Next_state <= CMP_ABS_X_3;
		CMP_ABS_X_3 :
				if (fixUB == 1'b1)
				Next_state <= CMP_ABS_X_4;
				else 
				Next_state <= FETCH;
		CMP_ABS_X_4 :
				Next_state <= FETCH;
		CMP_ABS_Y_1 :
				Next_state <= CMP_ABS_Y_2;
		CMP_ABS_Y_2 :
				Next_state <= CMP_ABS_Y_3;
		CMP_ABS_Y_3 :
				if (fixUB == 1'b1)
				Next_state <= CMP_ABS_Y_4;
				else 
				Next_state <= FETCH;
		CMP_ABS_Y_4 :
				Next_state <= FETCH;
		CMP_IND_X_1 :
				Next_state <= CMP_IND_X_2;
		CMP_IND_X_2 :
				Next_state <= CMP_IND_X_3;
		CMP_IND_X_3 :
				Next_state <= CMP_IND_X_4;
		CMP_IND_X_4 :
				Next_state <= CMP_IND_X_5;
		CMP_IND_X_5 :
				Next_state <= FETCH;
		CMP_IND_Y_1 :
				Next_state <= CMP_IND_Y_2;
		CMP_IND_Y_2 :
				Next_state <= CMP_IND_Y_3;
		CMP_IND_Y_3 :
				Next_state <= CMP_IND_Y_4;
		CMP_IND_Y_4 :
				if (fixUB == 1'b1)
				Next_state <= CMP_IND_Y_5;
				else
				Next_state <= FETCH;
		CMP_IND_Y_5 :
				Next_state <= FETCH;
		LDA_I :
				Next_state <= FETCH;
		CPX_I :
				Next_state <= FETCH;
		CPX_Z_1 :
				Next_state <= CPX_Z_2;
		CPX_Z_2 :
				Next_state <= FETCH;
		CPX_ABS_1 :
				Next_state <= CPX_ABS_2;
		CPX_ABS_2 :
				Next_state <= CPX_ABS_3;
		CPX_ABS_3 :
				Next_state <= FETCH;
		CPY_I :
				Next_state <= FETCH;
		CPY_Z_1 :
				Next_state <= CPY_Z_2;
		CPY_Z_2 :
				Next_state <= FETCH;
		CPY_ABS_1 :
				Next_state <= CPY_ABS_2;
		CPY_ABS_2 :
				Next_state <= CPY_ABS_3;
		CPY_ABS_3 :
				Next_state <= FETCH;
		DEC_Z_1 :
				Next_state <= DEC_Z_2;
		DEC_Z_2 :
				Next_state <= DEC_Z_3;
		DEC_Z_3 :
				Next_state <= DEC_Z_4;
		DEC_Z_4 :
				Next_state <= FETCH;
		DEC_Z_X_1 :
				Next_state <= DEC_Z_X_2;
		DEC_Z_X_2 :
				Next_state <= DEC_Z_X_3;
		DEC_Z_X_3 :
				Next_state <= DEC_Z_X_4;
		DEC_Z_X_4 :
				Next_state <= DEC_Z_X_5;
		DEC_Z_X_5 :
				Next_state <= FETCH;
		DEC_ABS_1 :
				Next_state <= DEC_ABS_2;
		DEC_ABS_2 :
				Next_state <= DEC_ABS_3;
		DEC_ABS_3 :
				Next_state <= DEC_ABS_4;
		DEC_ABS_4 :
				Next_state <= DEC_ABS_5;
		DEC_ABS_5 :
				Next_state <= FETCH;
		DEC_ABS_X_1 :
				Next_state <= DEC_ABS_X_2;
		DEC_ABS_X_2 :
				Next_state <= DEC_ABS_X_3;
		DEC_ABS_X_3 :
				Next_state <= DEC_ABS_X_4;
		DEC_ABS_X_4 :
				Next_state <= DEC_ABS_X_5;
		DEC_ABS_X_5 :
				Next_state <= DEC_ABS_X_6;
		DEC_ABS_X_6 :
				Next_state <= FETCH;
		DEX :
				Next_state <= FETCH;
		DEY :
				Next_state <= FETCH;
		// ORA
		ORA_I :
				Next_state <= FETCH;
		ORA_Z_1 :
				Next_state <= ORA_Z_2;
		ORA_Z_2 :
				Next_state <= FETCH;
		ORA_Z_X_1 :
				Next_state <= ORA_Z_X_2;
		ORA_Z_X_2 :
				Next_state <= ORA_Z_X_3;
		ORA_Z_X_3 :
				Next_state <= FETCH;
		ORA_ABS_1 :
				Next_state <= ORA_ABS_2;
		ORA_ABS_2 :
				Next_state <= ORA_ABS_3;
		ORA_ABS_3 :
				Next_state <= FETCH;
		ORA_ABS_X_1 :
				Next_state <= ORA_ABS_X_2;
		ORA_ABS_X_2 :
				Next_state <= ORA_ABS_X_3;
		ORA_ABS_X_3 :
				if (fixUB == 1'b1)
				Next_state <= ORA_ABS_X_4;
				else 
				Next_state <= FETCH;
		ORA_ABS_X_4 :
				Next_state <= FETCH;
		ORA_ABS_Y_1 :
				Next_state <= ORA_ABS_Y_2;
		ORA_ABS_Y_2 :
				Next_state <= ORA_ABS_Y_3;
		ORA_ABS_Y_3 :
				if (fixUB == 1'b1)
				Next_state <= ORA_ABS_Y_4;
				else 
				Next_state <= FETCH;
		ORA_ABS_Y_4 :
				Next_state <= FETCH;
		ORA_IND_X_1 :
				Next_state <= ORA_IND_X_2;
		ORA_IND_X_2 :
				Next_state <= ORA_IND_X_3;
		ORA_IND_X_3 :
				Next_state <= ORA_IND_X_4;
		ORA_IND_X_4 :
				Next_state <= ORA_IND_X_5;
		ORA_IND_X_5 :
				Next_state <= FETCH;
		ORA_IND_Y_1 :
				Next_state <= ORA_IND_Y_2;
		ORA_IND_Y_2 :
				Next_state <= ORA_IND_Y_3;
		ORA_IND_Y_3 :
				Next_state <= ORA_IND_Y_4;
		ORA_IND_Y_4 :
				if (fixUB == 1'b1)
				Next_state <= ORA_IND_Y_5;
				else
				Next_state <= FETCH;
		ORA_IND_Y_5 :
				Next_state <= FETCH;
		// EOR
		EOR_I :
				Next_state <= FETCH;
		EOR_Z_1 :
				Next_state <= EOR_Z_2;
		EOR_Z_2 :
				Next_state <= FETCH;
		EOR_Z_X_1 :
				Next_state <= EOR_Z_X_2;
		EOR_Z_X_2 :
				Next_state <= EOR_Z_X_3;
		EOR_Z_X_3 :
				Next_state <= FETCH;
		EOR_ABS_1 :
				Next_state <= EOR_ABS_2;
		EOR_ABS_2 :
				Next_state <= EOR_ABS_3;
		EOR_ABS_3 :
				Next_state <= FETCH;
		EOR_ABS_X_1 :
				Next_state <= EOR_ABS_X_2;
		EOR_ABS_X_2 :
				Next_state <= EOR_ABS_X_3;
		EOR_ABS_X_3 :
				if (fixUB == 1'b1)
				Next_state <= EOR_ABS_X_4;
				else 
				Next_state <= FETCH;
		EOR_ABS_X_4 :
				Next_state <= FETCH;
		EOR_ABS_Y_1 :
				Next_state <= EOR_ABS_Y_2;
		EOR_ABS_Y_2 :
				Next_state <= EOR_ABS_Y_3;
		EOR_ABS_Y_3 :
				if (fixUB == 1'b1)
				Next_state <= EOR_ABS_Y_4;
				else 
				Next_state <= FETCH;
		EOR_ABS_Y_4 :
				Next_state <= FETCH;
		EOR_IND_X_1 :
				Next_state <= EOR_IND_X_2;
		EOR_IND_X_2 :
				Next_state <= EOR_IND_X_3;
		EOR_IND_X_3 :
				Next_state <= EOR_IND_X_4;
		EOR_IND_X_4 :
				Next_state <= EOR_IND_X_5;
		EOR_IND_X_5 :
				Next_state <= FETCH;
		EOR_IND_Y_1 :
				Next_state <= EOR_IND_Y_2;
		EOR_IND_Y_2 :
				Next_state <= EOR_IND_Y_3;
		EOR_IND_Y_3 :
				Next_state <= EOR_IND_Y_4;
		EOR_IND_Y_4 :
				if (fixUB == 1'b1)
				Next_state <= EOR_IND_Y_5;
				else
				Next_state <= FETCH;
		EOR_IND_Y_5 :
				Next_state <= FETCH;
		NOP :
				Next_state <= FETCH;
		//
		INC_Z_1 :
				Next_state <= INC_Z_2;
		INC_Z_2 :
				Next_state <= INC_Z_3;
		INC_Z_3 :
				Next_state <= INC_Z_4;
		INC_Z_4 :
				Next_state <= FETCH;
		INC_Z_X_1 :
				Next_state <= INC_Z_X_2;
		INC_Z_X_2 :
				Next_state <= INC_Z_X_3;
		INC_Z_X_3 :
				Next_state <= INC_Z_X_4;
		INC_Z_X_4 :
				Next_state <= INC_Z_X_5;
		INC_Z_X_5 :
				Next_state <= FETCH;
		INC_ABS_1 :
				Next_state <= INC_ABS_2;
		INC_ABS_2 :
				Next_state <= INC_ABS_3;
		INC_ABS_3 :
				Next_state <= INC_ABS_4;
		INC_ABS_4 :
				Next_state <= INC_ABS_5;
		INC_ABS_5 :
				Next_state <= FETCH;
		INC_ABS_X_1 :
				Next_state <= INC_ABS_X_2;
		INC_ABS_X_2 :
				Next_state <= INC_ABS_X_3;
		INC_ABS_X_3 :
				Next_state <= INC_ABS_X_4;
		INC_ABS_X_4 :
				Next_state <= INC_ABS_X_5;
		INC_ABS_X_5 :
				Next_state <= INC_ABS_X_6;
		INC_ABS_X_6 :
				Next_state <= FETCH;
		INX :
				Next_state <= FETCH;
		INY :
				Next_state <= FETCH;
		BIT_Z_1 :
				Next_state <= BIT_Z_2;
		BIT_Z_2 :
				Next_state <= FETCH;
		BIT_ABS_1 :
				Next_state <= BIT_ABS_2;
		BIT_ABS_2 :
				Next_state <= BIT_ABS_3;
		BIT_ABS_3 :
				Next_state <= FETCH;
		LDA_Z_1 :
				Next_state <= LDA_Z_2;
		LDA_Z_2 :
				Next_state <= FETCH;
		LDA_Z_X_1 :
				Next_state <= LDA_Z_X_2;
		LDA_Z_X_2 :
				Next_state <= LDA_Z_X_3;
		LDA_Z_X_3 :
				Next_state <= FETCH;
		LDA_ABS_1 :
				Next_state <= LDA_ABS_2;
		LDA_ABS_2 :
				Next_state <= LDA_ABS_3;
		LDA_ABS_3 :
				Next_state <= FETCH;
		LDA_ABS_X_1 :
				Next_state <= LDA_ABS_X_2;
		LDA_ABS_X_2 :
				Next_state <= LDA_ABS_X_3;
		LDA_ABS_X_3 :
				if (fixUB == 1'b1)
				Next_state <= LDA_ABS_X_4;
				else 
				Next_state <= FETCH;
		LDA_ABS_X_4 :
				Next_state <= FETCH;
		LDA_ABS_Y_1 :
				Next_state <= LDA_ABS_Y_2;
		LDA_ABS_Y_2 :
				Next_state <= LDA_ABS_Y_3;
		LDA_ABS_Y_3 :
				if (fixUB == 1'b1)
				Next_state <= LDA_ABS_Y_4;
				else 
				Next_state <= FETCH;
		LDA_ABS_Y_4 :
				Next_state <= FETCH;
		LDA_IND_X_1 :
				Next_state <= LDA_IND_X_2;
		LDA_IND_X_2 :
				Next_state <= LDA_IND_X_3;
		LDA_IND_X_3 :
				Next_state <= LDA_IND_X_4;
		LDA_IND_X_4 :
				Next_state <= LDA_IND_X_5;
		LDA_IND_X_5 :
				Next_state <= FETCH;
		LDA_IND_Y_1 :
				Next_state <= LDA_IND_Y_2;
		LDA_IND_Y_2 :
				Next_state <= LDA_IND_Y_3;
		LDA_IND_Y_3 :
				Next_state <= LDA_IND_Y_4;
		LDA_IND_Y_4 :
				if (fixUB == 1'b1)
				Next_state <= LDA_IND_Y_5;
				else
				Next_state <= FETCH;
		LDA_IND_Y_5 :
				Next_state <= FETCH;
		// LDX
		LDX_Z_1 :
				Next_state <= LDX_Z_2;
		LDX_Z_2 :
				Next_state <= FETCH;
		LDX_Z_Y_1 :
				Next_state <= LDX_Z_Y_2;
		LDX_Z_Y_2 :
				Next_state <= LDX_Z_Y_3;
		LDX_Z_Y_3 :
				Next_state <= FETCH;
		LDX_ABS_1 :
				Next_state <= LDX_ABS_2;
		LDX_ABS_2 :
				Next_state <= LDX_ABS_3;
		LDX_ABS_3 :
				Next_state <= FETCH;
		LDX_ABS_Y_1 :
				Next_state <= LDX_ABS_Y_2;
		LDX_ABS_Y_2 :
				Next_state <= LDX_ABS_Y_3;
		LDX_ABS_Y_3 :
				if (fixUB == 1'b1)
				Next_state <= LDX_ABS_Y_4;
				else 
				Next_state <= FETCH;
		LDX_ABS_Y_4 :
				Next_state <= FETCH;
		// LDY
		LDY_Z_1 :
				Next_state <= LDY_Z_2;
		LDY_Z_2 :
				Next_state <= FETCH;
		LDY_Z_X_1 :
				Next_state <= LDY_Z_X_2;
		LDY_Z_X_2 :
				Next_state <= LDY_Z_X_3;
		LDY_Z_X_3 :
				Next_state <= FETCH;
		LDY_ABS_1 :
				Next_state <= LDY_ABS_2;
		LDY_ABS_2 :
				Next_state <= LDY_ABS_3;
		LDY_ABS_3 :
				Next_state <= FETCH;
		LDY_ABS_X_1 :
				Next_state <= LDY_ABS_X_2;
		LDY_ABS_X_2 :
				Next_state <= LDY_ABS_X_3;
		LDY_ABS_X_3 :
				if (fixUB == 1'b1)
				Next_state <= LDY_ABS_X_4;
				else 
				Next_state <= FETCH;
		LDY_ABS_X_4 :
				Next_state <= FETCH;
		LSR_A :
				Next_state <= FETCH;
		LSR_Z_1 :
				Next_state <= LSR_Z_2;
		LSR_Z_2 :
				Next_state <= LSR_Z_3;
		LSR_Z_3 :
				Next_state <= LSR_Z_4;
		LSR_Z_4 :
				Next_state <= FETCH;
		LSR_Z_X_1 :
				Next_state <= LSR_Z_X_2;
		LSR_Z_X_2 :
				Next_state <= LSR_Z_X_3;
		LSR_Z_X_3 :
				Next_state <= LSR_Z_X_4; 
		LSR_Z_X_4 :
				Next_state <= LSR_Z_X_5; 
		LSR_Z_X_5 :
				Next_state <= FETCH;
		LSR_ABS_1 :
				Next_state <= LSR_ABS_2;
		LSR_ABS_2 :
				Next_state <= LSR_ABS_3;
		LSR_ABS_3 :
				Next_state <= LSR_ABS_4;
		LSR_ABS_4 :
				Next_state <= LSR_ABS_5;
		LSR_ABS_5 :
				Next_state <= FETCH;
		LSR_ABS_X_1 :
				Next_state <= LSR_ABS_X_2;
		LSR_ABS_X_2 :
				Next_state <= LSR_ABS_X_3;
		LSR_ABS_X_3 :
				Next_state <= LSR_ABS_X_4;
		LSR_ABS_X_4 :
				Next_state <= LSR_ABS_X_5;
		LSR_ABS_X_5 :
				Next_state <= LSR_ABS_X_6;
		LSR_ABS_X_6 :
				Next_state <= FETCH;
		//
		ROL_A :
				Next_state <= FETCH;
		ROL_Z_1 :
				Next_state <= ROL_Z_2;
		ROL_Z_2 :
				Next_state <= ROL_Z_3;
		ROL_Z_3 :
				Next_state <= ROL_Z_4;
		ROL_Z_4 :
				Next_state <= FETCH;
		ROL_Z_X_1 :
				Next_state <= ROL_Z_X_2;
		ROL_Z_X_2 :
				Next_state <= ROL_Z_X_3;
		ROL_Z_X_3 :
				Next_state <= ROL_Z_X_4; 
		ROL_Z_X_4 :
				Next_state <= ROL_Z_X_5; 
		ROL_Z_X_5 :
				Next_state <= FETCH;
		ROL_ABS_1 :
				Next_state <= ROL_ABS_2;
		ROL_ABS_2 :
				Next_state <= ROL_ABS_3;
		ROL_ABS_3 :
				Next_state <= ROL_ABS_4;
		ROL_ABS_4 :
				Next_state <= ROL_ABS_5;
		ROL_ABS_5 :
				Next_state <= FETCH;
		ROL_ABS_X_1 :
				Next_state <= ROL_ABS_X_2;
		ROL_ABS_X_2 :
				Next_state <= ROL_ABS_X_3;
		ROL_ABS_X_3 :
				Next_state <= ROL_ABS_X_4;
		ROL_ABS_X_4 :
				Next_state <= ROL_ABS_X_5;
		ROL_ABS_X_5 :
				Next_state <= ROL_ABS_X_6;
		ROL_ABS_X_6 :
				Next_state <= FETCH;
		//
		ROR_A :
				Next_state <= FETCH;
		ROR_Z_1 :
				Next_state <= ROR_Z_2;
		ROR_Z_2 :
				Next_state <= ROR_Z_3;
		ROR_Z_3 :
				Next_state <= ROR_Z_4;
		ROR_Z_4 :
				Next_state <= FETCH;
		ROR_Z_X_1 :
				Next_state <= ROR_Z_X_2;
		ROR_Z_X_2 :
				Next_state <= ROR_Z_X_3;
		ROR_Z_X_3 :
				Next_state <= ROR_Z_X_4; 
		ROR_Z_X_4 :
				Next_state <= ROR_Z_X_5; 
		ROR_Z_X_5 :
				Next_state <= FETCH;
		ROR_ABS_1 :
				Next_state <= ROR_ABS_2;
		ROR_ABS_2 :
				Next_state <= ROR_ABS_3;
		ROR_ABS_3 :
				Next_state <= ROR_ABS_4;
		ROR_ABS_4 :
				Next_state <= ROR_ABS_5;
		ROR_ABS_5 :
				Next_state <= FETCH;
		ROR_ABS_X_1 :
				Next_state <= ROR_ABS_X_2;
		ROR_ABS_X_2 :
				Next_state <= ROR_ABS_X_3;
		ROR_ABS_X_3 :
				Next_state <= ROR_ABS_X_4;
		ROR_ABS_X_4 :
				Next_state <= ROR_ABS_X_5;
		ROR_ABS_X_5 :
				Next_state <= ROR_ABS_X_6;
		ROR_ABS_X_6 :
				Next_state <= FETCH;
		STA_Z_1 :
				Next_state <= STA_Z_2;
		STA_Z_2 :
				Next_state <= FETCH;
		STA_Z_X_1 :
				Next_state <= STA_Z_X_2;
		STA_Z_X_2 :
				Next_state <= STA_Z_X_3;
		STA_Z_X_3 :
				Next_state <= FETCH;
		STA_ABS_1 :
				Next_state <= STA_ABS_2;
		STA_ABS_2 :
				Next_state <= STA_ABS_3;
		STA_ABS_3 :
				if (addr_buff_out == 16'h4014)
					Next_state <= DMA_1;
				else
					Next_state <= FETCH;
		STA_ABS_X_1 :
				Next_state <= STA_ABS_X_2;
		STA_ABS_X_2 :
				Next_state <= STA_ABS_X_3;
		STA_ABS_X_3 :
				Next_state <= STA_ABS_X_4;
		STA_ABS_X_4 :
				if (addr_buff_out == 16'h4014)
					Next_state <= DMA_1;
				else
					Next_state <= FETCH;
		STA_ABS_Y_1 :
				Next_state <= STA_ABS_Y_2;
		STA_ABS_Y_2 :
				Next_state <= STA_ABS_Y_3;
		STA_ABS_Y_3 :
				Next_state <= STA_ABS_Y_4;
		STA_ABS_Y_4 :
				if (addr_buff_out == 16'h4014)
					Next_state <= DMA_1;
				else
					Next_state <= FETCH;
		STA_IND_X_1 :
				Next_state <= STA_IND_X_2;
		STA_IND_X_2 :
				Next_state <= STA_IND_X_3;
		STA_IND_X_3 :
				Next_state <= STA_IND_X_4;
		STA_IND_X_4 :
				Next_state <= STA_IND_X_5;
		STA_IND_X_5 :
				if (addr_buff_out == 16'h4014)
					Next_state <= DMA_1;
				else
					Next_state <= FETCH;
		STA_IND_Y_1 :
				Next_state <= STA_IND_Y_2;
		STA_IND_Y_2 :
				Next_state <= STA_IND_Y_3;
		STA_IND_Y_3 :
				Next_state <= STA_IND_Y_4;
		STA_IND_Y_4 :
				Next_state <= STA_IND_Y_5;
		STA_IND_Y_5 :
				if (addr_buff_out == 16'h4014)
					Next_state <= DMA_1;
				else
					Next_state <= FETCH;
		//
		STX_Z_1 :
				Next_state <= STX_Z_2;
		STX_Z_2 :
				Next_state <= FETCH;
		STX_Z_Y_1 :
				Next_state <= STX_Z_Y_2;
		STX_Z_Y_2 :
				Next_state <= STX_Z_Y_3;
		STX_Z_Y_3 :
				Next_state <= FETCH;
		STX_ABS_1 :
				Next_state <= STX_ABS_2;
		STX_ABS_2 :
				Next_state <= STX_ABS_3;
		STX_ABS_3 :
				if (addr_buff_out == 16'h4014)
					Next_state <= DMA_1;
				else
					Next_state <= FETCH;
		//
		STY_Z_1 :
				Next_state <= STY_Z_2;
		STY_Z_2 :
				Next_state <= FETCH;
		STY_Z_X_1 :
				Next_state <= STY_Z_X_2;
		STY_Z_X_2 :
				Next_state <= STY_Z_X_3;
		STY_Z_X_3 :
				Next_state <= FETCH;
		STY_ABS_1 :
				Next_state <= STY_ABS_2;
		STY_ABS_2 :
				Next_state <= STY_ABS_3;
		STY_ABS_3 :
				if (addr_buff_out == 16'h4014)
					Next_state <= DMA_1;
				else
					Next_state <= FETCH;
		TAX :
				Next_state <= FETCH;
		TAY :
				Next_state <= FETCH;
		TSX :
				Next_state <= FETCH;
		TXA :
				Next_state <= FETCH;
		TXS :
				Next_state <= FETCH;
		TYA :
				Next_state <= FETCH;
		CLD :
				Next_state <= FETCH;
		JMP_ABS_1 :
				Next_state <= JMP_ABS_2;
		JMP_ABS_2 :
				Next_state <= FETCH;
		JMP_IND_1 :
				Next_state <= JMP_IND_2;
		JMP_IND_2 :
				Next_state <= JMP_IND_3;
		JMP_IND_3 :
				Next_state <= JMP_IND_4;
		JMP_IND_4 :
				Next_state <= FETCH;
		JSR_1 :
				Next_state <= JSR_2;
		JSR_2 :
				Next_state <= JSR_3;
		JSR_3 :
				Next_state <= JSR_4;
		JSR_4 :
				Next_state <= JSR_5;
		JSR_5 :
				Next_state <= FETCH;
		RTS_1 :
				Next_state <= RTS_2;
		RTS_2 :
				Next_state <= RTS_3;
		RTS_3 :
				Next_state <= RTS_4;
		RTS_4 :
				Next_state <= RTS_5;
		RTS_5 :
				Next_state <= FETCH;
		RTI_1 :
				Next_state <= RTI_2;
		RTI_2 :
				Next_state <= RTI_3;
		RTI_3 :
				Next_state <= RTI_4;
		RTI_4 :
				Next_state <= RTI_5;
		RTI_5 :
				Next_state <= FETCH;
		BRK_1 :
				Next_state <= BRK_2;
		BRK_2 :
				Next_state <= BRK_3;
		BRK_3 :
				Next_state <= BRK_4;
		BRK_4 :
				if (nmi_status == 1'b1)
					Next_state <= NMI_5;
				else
					Next_state <= BRK_5;
		BRK_5 :
				Next_state <= BRK_6;
		BRK_6 :
				Next_state <= FETCH;
		PHA_1 :
				Next_state <= PHA_2;
		PHA_2 :
				Next_state <= FETCH;
		PHP_1 :
				Next_state <= PHP_2;
		PHP_2 :
				Next_state <= FETCH;
		PLA_1 :
				Next_state <= PLA_2;
		PLA_2 :
				Next_state <= PLA_3;
		PLA_3 :
				Next_state <= FETCH;
		PLP_1 :
				Next_state <= PLP_2;
		PLP_2 :
				Next_state <= PLP_3;
		PLP_3 :
				Next_state <= FETCH;
		DMA_1 :
				Next_state <= DMA_2;
		DMA_2 :
				if (counter_out == 8'hFF)
					Next_state <= FETCH;
				else
					Next_state <= DMA_1;
		NMI_1 :
				Next_state <= NMI_2;
		NMI_2 :
				Next_state <= NMI_3;
		NMI_3 :
				Next_state <= NMI_4;
		NMI_4 :
				Next_state <= NMI_5;
		NMI_5 :
				Next_state <= NMI_6;
		NMI_6 :
				Next_state <= FETCH;
		endcase
	end
	
	
	//**** STATE DEFINITIONS ****//
	
	always_comb
	begin
	LOAD_PC_LB = 1'b0;
	LOAD_DATA = 1'b0;
	databus_select = 2'b00;
	LOAD_PC_UB = 1'b0;
	LOAD_PC = 1'b0;
	w = 1'b1;
	LOAD_ADDRBUFF = 1'b0;
	LOAD_ADDRBUFF_LB = 1'b0;
	LOAD_ADDRBUFF_UB = 1'b0;
	LOAD_IND = 1'b0;
	LOAD_IND_LB = 1'b0;
	LOAD_IND_UB = 1'b0;
	LOAD_A = 1'b0;
	LOAD_X = 1'b0;
	LOAD_Y = 1'b0;
	LOAD_SP = 1'b0;
	sei = 1'b0;
	sec = 1'b0;
	cli = 1'b0;
	clc = 1'b0;
	clv = 1'b0;
	PLP = 1'b0;
	brk = 1'b0;
	Ld_N = 1'b0;
	Ld_Z = 1'b0;
	Ld_C = 1'b0;
	Ld_V = 1'b0;
	YMUX = 1'b0;
   XMUX = 2'b00;
   PCMUX = 2'b00;
   AMUX = 1'b0;
   ADDRMUX = 4'b0000;
   UBMUX = 1'b0;
   INDMUX = 3'b000;
	PCOUTMUX = 1'b0;
	STACKMUX = 2'b00;
	n_select = 1'b0;
   v_select = 2'b00;
   ALUK = 5'b00000;
   c_select = 4'b0000;
   irq = 1'b0;
	dma_select = 1'b0;
	inc_counter = 1'b0;
	nmi_done = 1'b0;
	addr_reg_nmi = 1'b0;
	OAM_write = 1'b0;
	oam_addr_inc = 1'b0;
	
	case (State)
	START_1 : 
			begin
			ADDRMUX = 4'b0001;
			LOAD_PC_LB = 1'b1;
			PCMUX = 2'b00;
			end
	START_2 :
			begin
			ADDRMUX = 4'b0101;
			LOAD_PC_UB = 1'b1;
			PCMUX = 2'b00;
			end
	FETCH :
			begin
			ADDRMUX = 4'b0100;
			if (~nmi_status & ~StopCPU)
			begin
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			end
			end
	ADC_I :
			begin
			ALUK = 5'b00011;
			n_select = 1'b0;
			c_select = 4'b0001;
			v_select = 2'b00;
			AMUX = 1'b1;
			LOAD_A =1'b1;
			LOAD_PC = 1'b1;
			Ld_N = 1'b1;
			Ld_C = 1'b1;
			Ld_V = 1'b1;
			Ld_Z = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	ADC_Z_1 :
			begin
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			LOAD_ADDRBUFF = 1'b1;
			end
	ADC_Z_2 :
			begin
			ADDRMUX = 4'b0001;
			ALUK = 5'b00011;
			n_select = 1'b0;
			c_select = 4'b0001;
			v_select = 2'b0;
			Ld_N = 1'b1;
			Ld_C = 1'b1;
			Ld_V = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A =1'b1;
			end
	ADC_Z_X_1 :
			begin
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	ADC_Z_X_2 :
			begin
			ADDRMUX = 4'b0111;
			end
	ADC_Z_X_3 :
			begin
			ALUK = 5'b00011;
			n_select = 1'b0;
			c_select = 4'b0001;
			v_select = 2'b0;
			Ld_N = 1'b1;
			Ld_C = 1'b1;
			Ld_V = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A =1'b1;
			end
	ADC_ABS_1 :
			begin
			LOAD_ADDRBUFF_LB = 1'b1;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	ADC_ABS_2 :
			begin
			LOAD_ADDRBUFF_UB = 1'b1;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	ADC_ABS_3 :
			begin
			ADDRMUX = 4'b0001;
			ALUK = 5'b00011;
			n_select = 1'b0;
			c_select = 4'b0001;
			v_select = 2'b00;
			Ld_N = 1'b1;
			Ld_C = 1'b1;
			Ld_V = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A = 1'b1;
			end
	ADC_ABS_X_1 :
			begin
			LOAD_ADDRBUFF_LB = 1'b1;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	ADC_ABS_X_2 :
			begin 
			LOAD_ADDRBUFF_UB = 1'b1;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	ADC_ABS_X_3 :
			begin
			UBMUX = 1'b0;
			if (fixUB == 1'b0)
			begin
			ADDRMUX = 4'b0010;
			ALUK = 5'b00011;
			n_select = 1'b0;
			c_select = 4'b0001;
			v_select = 2'b00;
			Ld_N = 1'b1;
			Ld_C = 1'b1;
			Ld_V = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A = 1'b1;
			end
		end
	ADC_ABS_X_4 :
			begin
			ADDRMUX = 4'b0010;
			ALUK = 5'b00011;
			n_select = 1'b0;
			c_select = 4'b0001;
			v_select = 2'b00;
			Ld_N = 1'b1;
			Ld_C = 1'b1;
			Ld_V = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A = 1'b1;
			end
	ADC_ABS_Y_1 :
			begin
			LOAD_ADDRBUFF_LB = 1'b1;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	ADC_ABS_Y_2 :
			begin 
			LOAD_ADDRBUFF_UB = 1'b1;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	ADC_ABS_Y_3 :
			begin
			UBMUX = 1'b1;
			if (fixUB == 1'b0)
			begin
			ADDRMUX = 4'b0011;
			ALUK = 5'b00011;
			n_select = 1'b0;
			c_select = 4'b0001;
			v_select = 2'b00;
			Ld_N = 1'b1;
			Ld_C = 1'b1;
			Ld_V = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A = 1'b1;
			end
		end
	ADC_ABS_Y_4 :
			begin
			ADDRMUX = 4'b0011;
			ALUK = 5'b00011;
			n_select = 1'b0;
			c_select = 4'b0001;
			v_select = 2'b00;
			Ld_N = 1'b1;
			Ld_C = 1'b1;
			Ld_V = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A = 1'b1;
		end
	ADC_IND_X_1 :
			begin
			ADDRMUX = 4'b0100;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			INDMUX = 3'b000;
			LOAD_IND = 1'b1;
			end
	ADC_IND_X_2 :
			begin
			ADDRMUX = 4'b1001;
			LOAD_ADDRBUFF_LB = 1'b1;
			INDMUX = 3'b010;
			LOAD_IND = 1'b1;
			end
	ADC_IND_X_3 :
			begin
			LOAD_ADDRBUFF_UB = 1'b1;
			ADDRMUX = 4'b1001;
			end
	ADC_IND_X_4 :
			begin
			ADDRMUX = 4'b0001;
			end
	ADC_IND_X_5 :
			begin
			ADDRMUX = 4'b0001;
			ALUK = 5'b00011;
			n_select = 1'b0;
			c_select = 4'b0001;
			v_select = 2'b00;
			Ld_N = 1'b1;
			Ld_C = 1'b1;
			Ld_V = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A = 1'b1;
			end
	ADC_IND_Y_1 :
			begin
			ADDRMUX = 4'b0100;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			INDMUX = 3'b011; // IND reg will get pointer
			LOAD_IND = 1'b1;
			end
	ADC_IND_Y_2 :
			begin
			ADDRMUX = 4'b1001;
			LOAD_ADDRBUFF_LB = 1'b1;
			INDMUX = 3'b010;
			LOAD_IND = 1'b1;
			end
	ADC_IND_Y_3 :
			begin
			ADDRMUX = 4'b1001;
			LOAD_ADDRBUFF_UB = 1'b1;
			end
	ADC_IND_Y_4 :
			begin
			UBMUX = 1'b1; 
			if (fixUB == 1'b0)
			begin
			ADDRMUX = 4'b0011;
			ALUK = 5'b00011;
			n_select = 1'b0;
			c_select = 4'b0001;
			v_select = 2'b00;
			Ld_N = 1'b1;
			Ld_C = 1'b1;
			Ld_V = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A = 1'b1;
			end
		end
	ADC_IND_Y_5 :
			begin
			ADDRMUX = 4'b0011;
			ALUK = 5'b00011;
			n_select = 1'b0;
			c_select = 4'b0001;
			v_select = 2'b00;
			Ld_N = 1'b1;
			Ld_C = 1'b1;
			Ld_V = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A = 1'b1;
			end
	AND_I : // AND
			begin
			ALUK = 5'b00001;
			n_select = 1'b0;
			AMUX = 1'b1;
			LOAD_A =1'b1;
			LOAD_PC = 1'b1;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	AND_Z_1 :
			begin
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			LOAD_ADDRBUFF = 1'b1;
			end
	AND_Z_2 :
			begin
			ADDRMUX = 4'b0001;
			ALUK = 5'b00001;
			n_select = 1'b0;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A =1'b1;
			end
	AND_Z_X_1 :
			begin
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	AND_Z_X_2 :
			begin
			ADDRMUX = 4'b0111;
			end
	AND_Z_X_3 :
			begin
			ALUK = 5'b00001;
			n_select = 1'b0;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A =1'b1;
			end
	AND_ABS_1 :
			begin
			LOAD_ADDRBUFF_LB = 1'b1;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	AND_ABS_2 :
			begin
			LOAD_ADDRBUFF_UB = 1'b1;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	AND_ABS_3 :
			begin
			ADDRMUX = 4'b0001;
			ALUK = 5'b00001;
			n_select = 1'b0;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A = 1'b1;
			end
	AND_ABS_X_1 :
			begin
			LOAD_ADDRBUFF_LB = 1'b1;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	AND_ABS_X_2 :
			begin 
			LOAD_ADDRBUFF_UB = 1'b1;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	AND_ABS_X_3 :
			begin
			UBMUX = 1'b0;
			if (fixUB == 1'b0)
			begin
			ADDRMUX = 4'b0010;
			ALUK = 5'b00001;
			n_select = 1'b0;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A = 1'b1;
			end
		end
	AND_ABS_X_4 :
			begin
			ADDRMUX = 4'b0010;
			ALUK = 5'b00001;
			n_select = 1'b0;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A = 1'b1;
			end
	AND_ABS_Y_1 :
			begin
			LOAD_ADDRBUFF_LB = 1'b1;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	AND_ABS_Y_2 :
			begin 
			LOAD_ADDRBUFF_UB = 1'b1;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	AND_ABS_Y_3 :
			begin
			UBMUX = 1'b1;
			if (fixUB == 1'b0)
			begin
			ADDRMUX = 4'b0011;
			ALUK = 5'b00001;
			n_select = 1'b0;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A = 1'b1;
			end
		end
	AND_ABS_Y_4 :
			begin
			ADDRMUX = 4'b0011;
			ALUK = 5'b00011;
			n_select = 1'b0;
			c_select = 4'b0001;
			v_select = 2'b00;
			Ld_N = 1'b1;
			Ld_C = 1'b1;
			Ld_V = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A = 1'b1;
			end
	AND_IND_X_1 :
			begin
			ADDRMUX = 4'b0100;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			INDMUX = 3'b000;
			LOAD_IND = 1'b1;
			end
	AND_IND_X_2 :
			begin
			ADDRMUX = 4'b1001;
			LOAD_ADDRBUFF_LB = 1'b1;
			INDMUX = 3'b010;
			LOAD_IND = 1'b1;
			end
	AND_IND_X_3 :
			begin
			LOAD_ADDRBUFF_UB = 1'b1;
			ADDRMUX = 4'b1001;
			end
	AND_IND_X_4 :
			begin
			ADDRMUX = 4'b0001;
			end
	AND_IND_X_5 :
			begin
			ADDRMUX = 4'b0001;
			ALUK = 5'b00001;
			n_select = 1'b0;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A = 1'b1;
			end
	AND_IND_Y_1 :
			begin
			ADDRMUX = 4'b0100;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			INDMUX = 3'b011; // IND reg will get pointer
			LOAD_IND = 1'b1;
			end
	AND_IND_Y_2 :
			begin
			ADDRMUX = 4'b1001;
			LOAD_ADDRBUFF_LB = 1'b1;
			INDMUX = 3'b010;
			LOAD_IND = 1'b1;
			end
	AND_IND_Y_3 :
			begin
			ADDRMUX = 4'b1001;
			LOAD_ADDRBUFF_UB = 1'b1;
			end
	AND_IND_Y_4 :
			begin
			UBMUX = 1'b1;
			if (fixUB == 1'b0)
			begin
			ADDRMUX = 4'b0011;
			ALUK = 5'b00001;
			n_select = 1'b0;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A = 1'b1;
			end
		end
	AND_IND_Y_5 :
			begin
			ADDRMUX = 4'b0011;
			ALUK = 5'b00001;
			n_select = 1'b0;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A = 1'b1;
			end
	LDX_I : // Load
			begin
			ALUK = 5'b01101;
			n_select = 1'b1;
			XMUX = 2'b00;
			LOAD_X =1'b1;
			LOAD_PC = 1'b1;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	LDY_I :
			begin
			ALUK = 5'b01101;
			n_select = 1'b1;
			YMUX = 1'b0;
			LOAD_Y =1'b1;
			LOAD_PC = 1'b1;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	LDA_I :
			begin
			ALUK = 5'b01101;
			n_select = 1'b1;
			AMUX = 1'b0;
			LOAD_A =1'b1;
			LOAD_PC = 1'b1;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	ASL_A :
			begin
			ALUK = 5'b01111;
			n_select = 1'b0;
			c_select = 4'b0100;
			LOAD_A = 1'b1;
			AMUX = 1'b1;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			Ld_C = 1'b1;
			end
	ASL_Z_1 :
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			LOAD_ADDRBUFF = 1'b1;
			end
	ASL_Z_2 :
			begin
			ADDRMUX = 4'b001; // read from address
			end
	ASL_Z_3 :
			begin
			ADDRMUX = 4'b0001;
			ALUK = 5'b10000;
			n_select = 1'b0;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			Ld_C = 1'b1;
			c_select = 4'b0101;
			LOAD_DATA = 1'b1;
			end
	ASL_Z_4 :
			begin
			ADDRMUX = 4'b0001;
			databus_select = 3'b100; 
			w = 1'b0;
			end
	ASL_Z_X_1 :
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			LOAD_ADDRBUFF = 1'b1;
			end
	ASL_Z_X_2 :
			begin
			; // burn a cycle
			end
	ASL_Z_X_3 :
			begin
			; // 
			end
	ASL_Z_X_4 :
			begin
			ADDRMUX = 4'b0010;
			ALUK = 5'b10000;
			n_select = 1'b0;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			Ld_C = 1'b1;
			c_select = 4'b0101;
			LOAD_DATA = 1'b1;
			end
	ASL_Z_X_5 :
			begin
			ADDRMUX = 4'b0010;
			databus_select = 3'b100; 
			w = 1'b0;
			end
	ASL_ABS_1 :
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			LOAD_ADDRBUFF_LB = 1'b1;
			end
	ASL_ABS_2 :
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			LOAD_ADDRBUFF_UB = 1'b1;
			end
	ASL_ABS_3 :
			begin
			; // waste time
			end
	ASL_ABS_4 :
			begin
			ADDRMUX = 4'b0001;
			ALUK = 5'b10000;
			n_select = 1'b0;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			Ld_C = 1'b1;
			c_select = 4'b0101;
			LOAD_DATA = 1'b1;
			end
	ASL_ABS_5 :
			begin
			ADDRMUX = 4'b0001;
			databus_select = 3'b100; 
			w = 1'b0;
			end
	ASL_ABS_X_1 :
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			LOAD_ADDRBUFF_LB = 1'b1;
			end
	ASL_ABS_X_2 :
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			LOAD_ADDRBUFF_UB = 1'b1;
			end
	ASL_ABS_X_3 :
			begin
			;
			end
	ASL_ABS_X_4 :
			begin
			;
			end
	ASL_ABS_X_5 :
			begin
			ADDRMUX = 4'b0010;
			ALUK = 5'b10000;
			n_select = 1'b0;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			Ld_C = 1'b1;
			c_select = 4'b0101;
			LOAD_DATA = 1'b1;
			end
	ASL_ABS_X_6 :
			begin
			ADDRMUX = 4'b0010;
			databus_select = 3'b100; 
			w = 1'b0;
			end
	BCC_1 :
			begin
			if (p_out[0] == 1'b0)
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b01;
			LOAD_PC = 1'b1;
			end
			else
			begin
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			end
			end
	BCC_2 :
			begin
			;
			end 
	BCC_3 :
			begin
			;
			end
	BCS_1 :
			begin
			if (p_out[0] == 1'b1)
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b01;
			LOAD_PC = 1'b1;
			end
			else
			begin
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			end
			end
	BCS_2 :
			begin
			;
			end 
	BCS_3 :
			begin
			;
			end
	BEQ_1 :
			begin
			if (p_out[1] == 1'b1)
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b01;
			LOAD_PC = 1'b1;
			end
			else
			begin
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			end
			end
	BEQ_2 :
			begin
			;
			end 
	BEQ_3 :
			begin
			;
			end
	BMI_1 :
			begin
			if (p_out[7] == 1'b1)
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b01;
			LOAD_PC = 1'b1;
			end
			else
			begin
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			end
			end
	BMI_2 :
			begin
			;
			end 
	BMI_3 :
			begin
			;
			end
	BNE_1 :
			begin
			if (p_out[1] == 1'b0)
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b01;
			LOAD_PC = 1'b1;
			end
			else
			begin
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			end
			end
	BNE_2 :
			begin
			;
			end 
	BNE_3 :
			begin
			;
			end
	BPL_1 :
			begin
			if (p_out[7] == 1'b0)
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b01;
			LOAD_PC = 1'b1;
			end
			else
			begin
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			end
			end
	BPL_2 :
			begin
			;
			end 
	BPL_3 :
			begin
			;
			end
	BVC_1 :
			begin
			if (p_out[6] == 1'b0)
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b01;
			LOAD_PC = 1'b1;
			end
			else
			begin
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			end
			end
	BVC_2 :
			begin
			;
			end 
	BVC_3 :
			begin
			;
			end
	BVS_1 :
			begin
			if (p_out[6] == 1'b1)
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b01;
			LOAD_PC = 1'b1;
			end
			else
			begin
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			end
			end
	BVS_2 :
			begin
			;
			end 
	BVS_3 :
			begin
			;
			end
	CLC	:
			begin
			clc = 1'b1;
			end
	CLI	:
			begin
			cli = 1'b1;
			end
	CLV	:
			begin
			clv = 1'b1;
			end
	SEC	:
			begin
			sec = 1'b1;
			end
	SEI	:
			begin
			sei = 1'b1;
			end
	SBC_I :		// SBC
			begin
			ALUK = 5'b00100;
			n_select = 1'b0;
			c_select = 4'b0000;
			v_select = 2'b11;
			AMUX = 1'b1;
			LOAD_A =1'b1;
			LOAD_PC = 1'b1;
			Ld_N = 1'b1;
			Ld_C = 1'b1;
			Ld_V = 1'b1;
			Ld_Z = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	SBC_Z_1 :
			begin
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			LOAD_ADDRBUFF = 1'b1;
			end
	SBC_Z_2 :
			begin
			ADDRMUX = 4'b0001;
			ALUK = 5'b00100;
			n_select = 1'b0;
			c_select = 4'b0000;
			v_select = 2'b11;
			Ld_N = 1'b1;
			Ld_C = 1'b1;
			Ld_V = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A =1'b1;
			end
	SBC_Z_X_1 :
			begin
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	SBC_Z_X_2 :
			begin
			ADDRMUX = 4'b0111;
			end
	SBC_Z_X_3 :
			begin
			ALUK = 5'b00100;
			n_select = 1'b0;
			c_select = 4'b0000;
			v_select = 2'b11;
			Ld_N = 1'b1;
			Ld_C = 1'b1;
			Ld_V = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A =1'b1;
			end
	SBC_ABS_1 :
			begin
			LOAD_ADDRBUFF_LB = 1'b1;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	SBC_ABS_2 :
			begin
			LOAD_ADDRBUFF_UB = 1'b1;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	SBC_ABS_3 :
			begin
			ADDRMUX = 4'b0001;
			ALUK = 5'b00100;
			n_select = 1'b0;
			c_select = 4'b0000;
			v_select = 2'b11;
			Ld_N = 1'b1;
			Ld_C = 1'b1;
			Ld_V = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A = 1'b1;
			end
	SBC_ABS_X_1 :
			begin
			LOAD_ADDRBUFF_LB = 1'b1;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	SBC_ABS_X_2 :
			begin 
			LOAD_ADDRBUFF_UB = 1'b1;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	SBC_ABS_X_3 :
			begin
			UBMUX = 1'b0;
			if (fixUB == 1'b0)
			begin
			ADDRMUX = 4'b0010;
			ALUK = 5'b00100;
			n_select = 1'b0;
			c_select = 4'b0000;
			v_select = 2'b00;
			Ld_N = 1'b1;
			Ld_C = 1'b1;
			Ld_V = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A = 1'b1;
			end
		end
	SBC_ABS_X_4 :
			begin
			ADDRMUX = 4'b0010;
			ALUK = 5'b00100;
			n_select = 1'b0;
			c_select = 4'b0000;
			v_select = 2'b11;
			Ld_N = 1'b1;
			Ld_C = 1'b1;
			Ld_V = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A = 1'b1;
			end
	SBC_ABS_Y_1 :
			begin
			LOAD_ADDRBUFF_LB = 1'b1;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	SBC_ABS_Y_2 :
			begin 
			LOAD_ADDRBUFF_UB = 1'b1;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	SBC_ABS_Y_3 :
			begin
			UBMUX = 1'b1;
			if (fixUB == 1'b0)
			begin
			ADDRMUX = 4'b0011;
			ALUK = 5'b00100;
			n_select = 1'b0;
			c_select = 4'b0000;
			v_select = 2'b11;
			Ld_N = 1'b1;
			Ld_C = 1'b1;
			Ld_V = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A = 1'b1;
			end
		end
	SBC_ABS_Y_4 :
			begin
			ADDRMUX = 4'b0011;
			ALUK = 5'b00100;
			n_select = 1'b0;
			c_select = 4'b0000;
			v_select = 2'b11;
			Ld_N = 1'b1;
			Ld_C = 1'b1;
			Ld_V = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A = 1'b1;
		end
	SBC_IND_X_1 :
			begin
			ADDRMUX = 4'b0100;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			INDMUX = 3'b000;
			LOAD_IND = 1'b1;
			end
	SBC_IND_X_2 :
			begin
			ADDRMUX = 4'b1001;
			LOAD_ADDRBUFF_LB = 1'b1;
			INDMUX = 3'b010;
			LOAD_IND = 1'b1;
			end
	SBC_IND_X_3 :
			begin
			LOAD_ADDRBUFF_UB = 1'b1;
			ADDRMUX = 4'b1001;
			end
	SBC_IND_X_4 :
			begin
			ADDRMUX = 4'b0001;
			end
	SBC_IND_X_5 :
			begin
			ADDRMUX = 4'b0001;
			ALUK = 5'b00100;
			n_select = 1'b0;
			c_select = 4'b0000;
			v_select = 2'b11;
			Ld_N = 1'b1;
			Ld_C = 1'b1;
			Ld_V = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A = 1'b1;
			end
	SBC_IND_Y_1 :
			begin
			ADDRMUX = 4'b0100;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			INDMUX = 3'b011; // IND reg will get pointer
			LOAD_IND = 1'b1;
			end
	SBC_IND_Y_2 :
			begin
			ADDRMUX = 4'b1001;
			LOAD_ADDRBUFF_LB = 1'b1;
			INDMUX = 3'b010;
			LOAD_IND = 1'b1;
			end
	SBC_IND_Y_3 :
			begin
			ADDRMUX = 4'b1001;
			LOAD_ADDRBUFF_UB = 1'b1;
			end
	SBC_IND_Y_4 :
			begin
			UBMUX = 1'b1;
			if (fixUB == 1'b0)
			begin
			ADDRMUX = 4'b0011;
			ALUK = 5'b00100;
			n_select = 1'b0;
			c_select = 4'b0000;
			v_select = 2'b11;
			Ld_N = 1'b1;
			Ld_C = 1'b1;
			Ld_V = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A = 1'b1;
			end
		end
	SBC_IND_Y_5 :
			begin
			ADDRMUX = 4'b0011;
			ALUK = 5'b00100;
			n_select = 1'b0;
			c_select = 4'b0000;
			v_select = 2'b11;
			Ld_N = 1'b1;
			Ld_C = 1'b1;
			Ld_V = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A = 1'b1;
			end
	CMP_I :
		begin
			ALUK = 5'b10111;
			n_select = 1'b0;
			c_select = 4'b0110;
			LOAD_PC = 1'b1;
			Ld_N = 1'b1;
			Ld_C = 1'b1;
			Ld_Z = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
		end
	CMP_Z_1 :
			begin
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			LOAD_ADDRBUFF = 1'b1;
			end
	CMP_Z_2 :
			begin
			ADDRMUX = 4'b0001;
			ALUK = 5'b10111;
			n_select = 1'b0;
			c_select = 4'b0110;
			Ld_N = 1'b1;
			Ld_C = 1'b1;
			Ld_Z = 1'b1;
			end
	CMP_Z_X_1 :
			begin
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	CMP_Z_X_2 :
			begin
			ADDRMUX = 4'b0111;
			end
	CMP_Z_X_3 :
			begin
			ALUK = 5'b10111;
			n_select = 1'b0;
			c_select = 4'b0110;
			Ld_N = 1'b1;
			Ld_C = 1'b1;
			Ld_Z = 1'b1;
			end
	CMP_ABS_1 :
			begin
			LOAD_ADDRBUFF_LB = 1'b1;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	CMP_ABS_2 :
			begin
			LOAD_ADDRBUFF_UB = 1'b1;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	CMP_ABS_3 :
			begin
			ADDRMUX = 4'b0001;
			ALUK = 5'b10111;
			n_select = 1'b0;
			c_select = 4'b0110;
			Ld_N = 1'b1;
			Ld_C = 1'b1;
			Ld_Z = 1'b1;
			end
	CMP_ABS_X_1 :
			begin
			LOAD_ADDRBUFF_LB = 1'b1;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	CMP_ABS_X_2 :
			begin 
			LOAD_ADDRBUFF_UB = 1'b1;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	CMP_ABS_X_3 :
			begin
			UBMUX = 1'b0;
			if (fixUB == 1'b0)
			begin
			ADDRMUX = 4'b0010;
			ALUK = 5'b10111;
			n_select = 1'b0;
			c_select = 4'b0110;
			Ld_N = 1'b1;
			Ld_C = 1'b1;
			Ld_Z = 1'b1;
			end
		end
	CMP_ABS_X_4 :
			begin
			ADDRMUX = 4'b0010;
			ALUK = 5'b10111;
			n_select = 1'b0;
			c_select = 4'b0110;
			Ld_N = 1'b1;
			Ld_C = 1'b1;
			Ld_Z = 1'b1;
			end
	CMP_ABS_Y_1 :
			begin
			LOAD_ADDRBUFF_LB = 1'b1;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	CMP_ABS_Y_2 :
			begin 
			LOAD_ADDRBUFF_UB = 1'b1;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	CMP_ABS_Y_3 :
			begin
			UBMUX = 1'b1;
			if (fixUB == 1'b0)
			begin
			ADDRMUX = 4'b0011;
			ALUK = 5'b10111;
			n_select = 1'b0;
			c_select = 4'b0110;
			Ld_N = 1'b1;
			Ld_C = 1'b1;
			Ld_Z = 1'b1;
			end
		end
	CMP_ABS_Y_4 :
			begin
			ADDRMUX = 4'b0011;
			ALUK = 5'b10111;
			n_select = 1'b0;
			c_select = 4'b0110;
			Ld_N = 1'b1;
			Ld_C = 1'b1;
			Ld_Z = 1'b1;
			end
	CMP_IND_X_1 :
			begin
			ADDRMUX = 4'b0100;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			INDMUX = 3'b000;
			LOAD_IND = 1'b1;
			end
	CMP_IND_X_2 :
			begin
			ADDRMUX = 4'b1001;
			LOAD_ADDRBUFF_LB = 1'b1;
			INDMUX = 3'b010;
			LOAD_IND = 1'b1;
			end
	CMP_IND_X_3 :
			begin
			LOAD_ADDRBUFF_UB = 1'b1;
			ADDRMUX = 4'b1001;
			end
	CMP_IND_X_4 :
			begin
			ADDRMUX = 4'b0001;
			end
	CMP_IND_X_5 :
			begin
			ADDRMUX = 4'b0001;
			ALUK = 5'b10111;
			n_select = 1'b0;
			c_select = 4'b0110;
			Ld_N = 1'b1;
			Ld_C = 1'b1;
			Ld_Z = 1'b1;
			end
	CMP_IND_Y_1 :
			begin
			ADDRMUX = 4'b0100;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			INDMUX = 3'b011; // IND reg will get pointer
			LOAD_IND = 1'b1;
			end
	CMP_IND_Y_2 :
			begin
			ADDRMUX = 4'b1001;
			LOAD_ADDRBUFF_LB = 1'b1;
			INDMUX = 3'b010;
			LOAD_IND = 1'b1;
			end
	CMP_IND_Y_3 :
			begin
			ADDRMUX = 4'b1001;
			LOAD_ADDRBUFF_UB = 1'b1;
			end
	CMP_IND_Y_4 :
			begin
			UBMUX = 1'b1;
			if (fixUB == 1'b0)
			begin
			ADDRMUX = 4'b0011;
			ALUK = 5'b10111;
			n_select = 1'b0;
			c_select = 4'b0110;
			Ld_N = 1'b1;
			Ld_C = 1'b1;
			Ld_Z = 1'b1;
			end
		end
	CMP_IND_Y_5 :
			begin
			ADDRMUX = 4'b0011;
			ALUK = 5'b10111;
			n_select = 1'b0;
			c_select = 4'b0110;
			Ld_N = 1'b1;
			Ld_C = 1'b1;
			Ld_Z = 1'b1;
			end
	CPX_I :
		begin
			ALUK = 5'b11000;
			n_select = 1'b0;
			c_select = 4'b0110;
			LOAD_PC = 1'b1;
			Ld_N = 1'b1;
			Ld_C = 1'b1;
			Ld_Z = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
		end
	CPX_Z_1 :
			begin
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			LOAD_ADDRBUFF = 1'b1;
			end
	CPX_Z_2 :
			begin
			ADDRMUX = 4'b0001;
			ALUK = 5'b11000;
			n_select = 1'b0;
			c_select = 4'b0110;
			Ld_N = 1'b1;
			Ld_C = 1'b1;
			Ld_Z = 1'b1;
			end
	CPX_ABS_1 :
			begin
			LOAD_ADDRBUFF_LB = 1'b1;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	CPX_ABS_2 :
			begin
			LOAD_ADDRBUFF_UB = 1'b1;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	CPX_ABS_3 :
			begin
			ADDRMUX = 4'b0001;
			ALUK = 5'b11000;
			n_select = 1'b0;
			c_select = 4'b0110;
			Ld_N = 1'b1;
			Ld_C = 1'b1;
			Ld_Z = 1'b1;
			end
	/////
	CPY_I :
		begin
			ALUK = 5'b11001;
			n_select = 1'b0;
			c_select = 4'b0110;
			LOAD_PC = 1'b1;
			Ld_N = 1'b1;
			Ld_C = 1'b1;
			Ld_Z = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
		end
	CPY_Z_1 :
			begin
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			LOAD_ADDRBUFF = 1'b1;
			end
	CPY_Z_2 :
			begin
			ADDRMUX = 4'b0001;
			ALUK = 5'b11001;
			n_select = 1'b0;
			c_select = 4'b0110;
			Ld_N = 1'b1;
			Ld_C = 1'b1;
			Ld_Z = 1'b1;
			end
	CPY_ABS_1 :
			begin
			LOAD_ADDRBUFF_LB = 1'b1;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	CPY_ABS_2 :
			begin
			LOAD_ADDRBUFF_UB = 1'b1;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	CPY_ABS_3 :
			begin
			ADDRMUX = 4'b0001;
			ALUK = 5'b11001;
			n_select = 1'b0;
			c_select = 4'b0110;
			Ld_N = 1'b1;
			Ld_C = 1'b1;
			Ld_Z = 1'b1;
			end
	DEC_Z_1 :
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			LOAD_ADDRBUFF = 1'b1;
			end
	DEC_Z_2 :
			begin
			ADDRMUX = 4'b001; // read from address
			end
	DEC_Z_3 :
			begin
			ADDRMUX = 4'b0001;
			ALUK = 5'b10110;
			n_select = 1'b0;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			LOAD_DATA = 1'b1;
			end
	DEC_Z_4 :
			begin
			ADDRMUX = 4'b0001;
			databus_select = 3'b100; 
			w = 1'b0;
			end
	DEC_Z_X_1 :
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			LOAD_ADDRBUFF = 1'b1;
			end
	DEC_Z_X_2 :
			begin
			; // burn a cycle
			end
	DEC_Z_X_3 :
			begin
			; // 
			end
	DEC_Z_X_4 :
			begin
			ADDRMUX = 4'b0010;
			ALUK = 5'b10110;
			n_select = 1'b0;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			LOAD_DATA = 1'b1;
			end
	DEC_Z_X_5 :
			begin
			ADDRMUX = 4'b0010;
			databus_select = 3'b100; 
			w = 1'b0;
			end
	DEC_ABS_1 :
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			LOAD_ADDRBUFF_LB = 1'b1;
			end
	DEC_ABS_2 :
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			LOAD_ADDRBUFF_UB = 1'b1;
			end
	DEC_ABS_3 :
			begin
			; // waste time
			end
	DEC_ABS_4 :
			begin
			ADDRMUX = 4'b0001;
			ALUK = 5'b10110;
			n_select = 1'b0;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			LOAD_DATA = 1'b1;
			end
	DEC_ABS_5 :
			begin
			ADDRMUX = 4'b0001;
			databus_select = 3'b100; 
			w = 1'b0;
			end
	DEC_ABS_X_1 :
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			LOAD_ADDRBUFF_LB = 1'b1;
			end
	DEC_ABS_X_2 :
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			LOAD_ADDRBUFF_UB = 1'b1;
			end
	DEC_ABS_X_3 :
			begin
			;
			end
	DEC_ABS_X_4 :
			begin
			;
			end
	DEC_ABS_X_5 :
			begin
			ADDRMUX = 4'b0010;
			ALUK = 5'b10110;
			n_select = 1'b0;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			LOAD_DATA = 1'b1;
			end
	DEC_ABS_X_6 :
			begin
			ADDRMUX = 4'b0010;
			databus_select = 3'b100; 
			w = 1'b0;
			end
	DEX :
			begin
			ALUK = 5'b10100;
			XMUX = 2'b01;
			LOAD_X = 1'b1;
			n_select = 1'b0;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			end
	DEY :
			begin
			ALUK = 5'b10101;
			YMUX = 1'b1;
			LOAD_Y = 1'b1;
			n_select = 1'b0;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			end
	ORA_I :
			begin
			ALUK = 5'b00000;
			n_select = 1'b0;
			AMUX = 1'b1;
			LOAD_A =1'b1;
			LOAD_PC = 1'b1;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	ORA_Z_1 :
			begin
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			LOAD_ADDRBUFF = 1'b1;
			end
	ORA_Z_2 :
			begin
			ADDRMUX = 4'b0001;
			ALUK = 5'b00000;
			n_select = 1'b0;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A =1'b1;
			end
	ORA_Z_X_1 :
			begin
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	ORA_Z_X_2 :
			begin
			ADDRMUX = 4'b0111;
			end
	ORA_Z_X_3 :
			begin
			ALUK = 5'b00000;
			n_select = 1'b0;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A =1'b1;
			end
	ORA_ABS_1 :
			begin
			LOAD_ADDRBUFF_LB = 1'b1;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	ORA_ABS_2 :
			begin
			LOAD_ADDRBUFF_UB = 1'b1;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	ORA_ABS_3 :
			begin
			ADDRMUX = 4'b0001;
			ALUK = 5'b00000;
			n_select = 1'b0;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A = 1'b1;
			end
	ORA_ABS_X_1 :
			begin
			LOAD_ADDRBUFF_LB = 1'b1;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	ORA_ABS_X_2 :
			begin 
			LOAD_ADDRBUFF_UB = 1'b1;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	ORA_ABS_X_3 :
			begin
			UBMUX = 1'b0;
			if (fixUB == 1'b0)
			begin
			ADDRMUX = 4'b0010;
			ALUK = 5'b00000;
			n_select = 1'b0;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A = 1'b1;
			end
		end
	ORA_ABS_X_4 :
			begin
			ADDRMUX = 4'b0010;
			ALUK = 5'b00000;
			n_select = 1'b0;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A = 1'b1;
			end
	ORA_ABS_Y_1 :
			begin
			LOAD_ADDRBUFF_LB = 1'b1;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	ORA_ABS_Y_2 :
			begin 
			LOAD_ADDRBUFF_UB = 1'b1;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	ORA_ABS_Y_3 :
			begin
			UBMUX = 1'b1;
			if (fixUB == 1'b0)
			begin
			ADDRMUX = 4'b0011;
			ALUK = 5'b00000;
			n_select = 1'b0;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A = 1'b1;
			end
		end
	ORA_ABS_Y_4 :
			begin
			ADDRMUX = 4'b0011;
			ALUK = 5'b00000;
			n_select = 1'b0;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A = 1'b1;
		end
	ORA_IND_X_1 :
			begin
			ADDRMUX = 4'b0100;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			INDMUX = 3'b000;
			LOAD_IND = 1'b1;
			end
	ORA_IND_X_2 :
			begin
			ADDRMUX = 4'b1001;
			LOAD_ADDRBUFF_LB = 1'b1;
			INDMUX = 3'b010;
			LOAD_IND = 1'b1;
			end
	ORA_IND_X_3 :
			begin
			LOAD_ADDRBUFF_UB = 1'b1;
			ADDRMUX = 4'b1001;
			end
	ORA_IND_X_4 :
			begin
			ADDRMUX = 4'b0001;
			end
	ORA_IND_X_5 :
			begin
			ADDRMUX = 4'b0001;
			ALUK = 5'b00000;
			n_select = 1'b0;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A = 1'b1;
			end
	ORA_IND_Y_1 :
			begin
			ADDRMUX = 4'b0100;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			INDMUX = 3'b011; // IND reg will get pointer
			LOAD_IND = 1'b1;
			end
	ORA_IND_Y_2 :
			begin
			ADDRMUX = 4'b1001;
			LOAD_ADDRBUFF_LB = 1'b1;
			INDMUX = 3'b010;
			LOAD_IND = 1'b1;
			end
	ORA_IND_Y_3 :
			begin
			ADDRMUX = 4'b1001;
			LOAD_ADDRBUFF_UB = 1'b1;
			end
	ORA_IND_Y_4 :
			begin
			UBMUX = 1'b1;
			if (fixUB == 1'b0)
			begin
			ADDRMUX = 4'b0011;
			ALUK = 5'b00000;
			n_select = 1'b0;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A = 1'b1;
			end
		end
	ORA_IND_Y_5 :
			begin
			ADDRMUX = 4'b0011;
			ALUK = 5'b00000;
			n_select = 1'b0;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A = 1'b1;
			end
	// EOR
	EOR_I :
			begin
			ALUK = 5'b00010;
			n_select = 1'b0;
			AMUX = 1'b1;
			LOAD_A =1'b1;
			LOAD_PC = 1'b1;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	EOR_Z_1 :
			begin
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			LOAD_ADDRBUFF = 1'b1;
			end
	EOR_Z_2 :
			begin
			ADDRMUX = 4'b0001;
			ALUK = 5'b00010;
			n_select = 1'b0;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A =1'b1;
			end
	EOR_Z_X_1 :
			begin
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	EOR_Z_X_2 :
			begin
			ADDRMUX = 4'b0111;
			end
	EOR_Z_X_3 :
			begin
			ALUK = 5'b00010;
			n_select = 1'b0;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A =1'b1;
			end
	EOR_ABS_1 :
			begin
			LOAD_ADDRBUFF_LB = 1'b1;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	EOR_ABS_2 :
			begin
			LOAD_ADDRBUFF_UB = 1'b1;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	EOR_ABS_3 :
			begin
			ADDRMUX = 4'b0001;
			ALUK = 5'b00010;
			n_select = 1'b0;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A = 1'b1;
			end
	EOR_ABS_X_1 :
			begin
			LOAD_ADDRBUFF_LB = 1'b1;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	EOR_ABS_X_2 :
			begin 
			LOAD_ADDRBUFF_UB = 1'b1;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	EOR_ABS_X_3 :
			begin
			UBMUX = 1'b0;
			if (fixUB == 1'b0)
			begin
			ADDRMUX = 4'b0010;
			ALUK = 5'b00010;
			n_select = 1'b0;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A = 1'b1;
			end
		end
	EOR_ABS_X_4 :
			begin
			ADDRMUX = 4'b0010;
			ALUK = 5'b00010;
			n_select = 1'b0;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A = 1'b1;
			end
	EOR_ABS_Y_1 :
			begin
			LOAD_ADDRBUFF_LB = 1'b1;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	EOR_ABS_Y_2 :
			begin 
			LOAD_ADDRBUFF_UB = 1'b1;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	EOR_ABS_Y_3 :
			begin
			if (fixUB == 1'b0)
			begin
			ADDRMUX = 4'b0011;
			ALUK = 5'b00010;
			n_select = 1'b0;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A = 1'b1;
			end
		end
	EOR_ABS_Y_4 :
			begin
			ADDRMUX = 4'b0011;
			ALUK = 5'b00010;
			n_select = 1'b0;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A = 1'b1;
		end
	EOR_IND_X_1 :
			begin
			ADDRMUX = 4'b0100;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			INDMUX = 3'b000;
			LOAD_IND = 1'b1;
			end
	EOR_IND_X_2 :
			begin
			ADDRMUX = 4'b1001;
			LOAD_ADDRBUFF_LB = 1'b1;
			INDMUX = 3'b010;
			LOAD_IND = 1'b1;
			end
	EOR_IND_X_3 :
			begin
			LOAD_ADDRBUFF_UB = 1'b1;
			ADDRMUX = 4'b1001;
			end
	EOR_IND_X_4 :
			begin
			ADDRMUX = 4'b0001;
			end
	EOR_IND_X_5 :
			begin
			ADDRMUX = 4'b0001;
			ALUK = 5'b00010;
			n_select = 1'b0;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A = 1'b1;
			end
	EOR_IND_Y_1 :
			begin
			ADDRMUX = 4'b0100;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			INDMUX = 3'b011; // IND reg will get pointer
			LOAD_IND = 1'b1;
			end
	EOR_IND_Y_2 :
			begin
			ADDRMUX = 4'b1001;
			LOAD_ADDRBUFF_LB = 1'b1;
			INDMUX = 3'b010;
			LOAD_IND = 1'b1;
			end
	EOR_IND_Y_3 :
			begin
			ADDRMUX = 4'b1001;
			LOAD_ADDRBUFF_UB = 1'b1;
			end
	EOR_IND_Y_4 :
			begin
			if (fixUB == 1'b0)
			begin
			ADDRMUX = 4'b0011;
			ALUK = 5'b00010;
			n_select = 1'b0;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A = 1'b1;
			end
		end
	EOR_IND_Y_5 :
			begin
			ADDRMUX = 4'b0011;
			ALUK = 5'b00010;
			n_select = 1'b0;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A = 1'b1;
			end
	NOP : ;
	//
	INC_Z_1 :
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			LOAD_ADDRBUFF = 1'b1;
			end
	INC_Z_2 :
			begin
			ADDRMUX = 4'b001; // read from address
			end
	INC_Z_3 :
			begin
			ADDRMUX = 4'b0001;
			ALUK = 5'b10011;
			n_select = 1'b0;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			LOAD_DATA = 1'b1;
			end
	INC_Z_4 :
			begin
			ADDRMUX = 4'b0001;
			databus_select = 3'b100; 
			w = 1'b0;
			end
	INC_Z_X_1 :
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			LOAD_ADDRBUFF = 1'b1;
			end
	INC_Z_X_2 :
			begin
			; // burn a cycle
			end
	INC_Z_X_3 :
			begin
			; // 
			end
	INC_Z_X_4 :
			begin
			ADDRMUX = 4'b0010; // addr_reg[7:0] + x
			ALUK = 5'b10011;
			n_select = 1'b0;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			LOAD_DATA = 1'b1;
			end
	INC_Z_X_5 :
			begin
			ADDRMUX = 4'b0010;
			databus_select = 3'b100; 
			w = 1'b0;
			end
	INC_ABS_1 :
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			LOAD_ADDRBUFF_LB = 1'b1;
			end
	INC_ABS_2 :
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			LOAD_ADDRBUFF_UB = 1'b1;
			end
	INC_ABS_3 :
			begin
			; // waste time
			end
	INC_ABS_4 :
			begin
			ADDRMUX = 4'b0001;
			ALUK = 5'b10011;
			n_select = 1'b0;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			LOAD_DATA = 1'b1;
			end
	INC_ABS_5 :
			begin
			ADDRMUX = 4'b0001;
			databus_select = 3'b100; 
			w = 1'b0;
			end
	INC_ABS_X_1 :
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			LOAD_ADDRBUFF_LB = 1'b1;
			end
	INC_ABS_X_2 :
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			LOAD_ADDRBUFF_UB = 1'b1;
			end
	INC_ABS_X_3 :
			begin
			;
			end
	INC_ABS_X_4 :
			begin
			;
			end
	INC_ABS_X_5 :
			begin
			ADDRMUX = 4'b0010;
			ALUK = 5'b10011;
			n_select = 1'b0;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			LOAD_DATA = 1'b1;
			end
	INC_ABS_X_6 :
			begin
			ADDRMUX = 4'b0010;
			databus_select = 3'b100; 
			w = 1'b0;
			end
	INX :
			begin
			ALUK = 5'b10001;
			XMUX = 2'b01;
			LOAD_X = 1'b1;
			n_select = 1'b0;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			end
	INY :
			begin
			ALUK = 5'b10010;
			YMUX = 1'b1;
			LOAD_Y = 1'b1;
			n_select = 1'b0;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			end
	BIT_Z_1 :
			begin
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			LOAD_ADDRBUFF = 1'b1;
			end
	BIT_Z_2 :
			begin
			ADDRMUX = 4'b0001;
			ALUK = 5'b00001;
			n_select = 1'b1;
			v_select = 2'b01;
			Ld_N = 1'b1;
			Ld_V = 1'b1;
			Ld_Z = 1'b1;
			end
	BIT_ABS_1 :
			begin
			LOAD_ADDRBUFF_LB = 1'b1;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	BIT_ABS_2 :
			begin
			LOAD_ADDRBUFF_UB = 1'b1;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	BIT_ABS_3 :
			begin
			ADDRMUX = 4'b0001;
			ALUK = 5'b00001;
			n_select = 1'b1;
			v_select = 2'b01;
			Ld_N = 1'b1;
			Ld_V = 1'b1;
			Ld_Z = 1'b1;
			end
	LDA_Z_1 :
			begin
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			LOAD_ADDRBUFF = 1'b1;
			end
	LDA_Z_2 :
			begin
			ADDRMUX = 4'b0001;
			ALUK = 5'b01101;
			n_select = 1'b1;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A =1'b1;
			end
	LDA_Z_X_1 :
			begin
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	LDA_Z_X_2 :
			begin
			ADDRMUX = 4'b0111;
			end
	LDA_Z_X_3 :
			begin
			ALUK = 5'b01101;
			n_select = 1'b1;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A =1'b1;
			end
	LDA_ABS_1 :
			begin
			LOAD_ADDRBUFF_LB = 1'b1;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	LDA_ABS_2 :
			begin
			LOAD_ADDRBUFF_UB = 1'b1;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	LDA_ABS_3 :
			begin
			ADDRMUX = 4'b0001;
			ALUK = 5'b01101;
			n_select = 1'b1;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A = 1'b1;
			end
	LDA_ABS_X_1 :
			begin
			LOAD_ADDRBUFF_LB = 1'b1;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	LDA_ABS_X_2 :
			begin 
			LOAD_ADDRBUFF_UB = 1'b1;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	LDA_ABS_X_3 :
			begin
			UBMUX = 1'b0;
			if (fixUB == 1'b0)
			begin
			ADDRMUX = 4'b0010;
			ALUK = 5'b01101;
			n_select = 1'b1;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A = 1'b1;
			end
		end
	LDA_ABS_X_4 :
			begin
			ADDRMUX = 4'b0010;
			ALUK = 5'b01101;
			n_select = 1'b1;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A = 1'b1;
			end
	LDA_ABS_Y_1 :
			begin
			LOAD_ADDRBUFF_LB = 1'b1;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	LDA_ABS_Y_2 :
			begin 
			LOAD_ADDRBUFF_UB = 1'b1;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	LDA_ABS_Y_3 :
			begin
			if (fixUB == 1'b0)
			begin
			ADDRMUX = 4'b0011;
			ALUK = 5'b01101;
			n_select = 1'b1;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A = 1'b1;
			end
		end
	LDA_ABS_Y_4 :
			begin
			ADDRMUX = 4'b0011;
			ALUK = 5'b01101;
			n_select = 1'b1;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A = 1'b1;
		end
	LDA_IND_X_1 :
			begin
			ADDRMUX = 4'b0100;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			INDMUX = 3'b000;
			LOAD_IND = 1'b1;
			end
	LDA_IND_X_2 :
			begin
			ADDRMUX = 4'b1001;
			LOAD_ADDRBUFF_LB = 1'b1;
			INDMUX = 3'b010;
			LOAD_IND = 1'b1;
			end
	LDA_IND_X_3 :
			begin
			LOAD_ADDRBUFF_UB = 1'b1;
			ADDRMUX = 4'b1001;
			end
	LDA_IND_X_4 :
			begin
			ADDRMUX = 4'b0001;
			end
	LDA_IND_X_5 :
			begin
			ADDRMUX = 4'b0001;
			ALUK = 5'b01101;
			n_select = 1'b1;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A = 1'b1;
			end
	LDA_IND_Y_1 :
			begin
			ADDRMUX = 4'b0100;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			INDMUX = 3'b011; // IND reg will get pointer
			LOAD_IND = 1'b1;
			end
	LDA_IND_Y_2 :
			begin
			ADDRMUX = 4'b1001;
			LOAD_ADDRBUFF_LB = 1'b1;
			INDMUX = 3'b010;
			LOAD_IND = 1'b1;
			end
	LDA_IND_Y_3 :
			begin
			ADDRMUX = 4'b1001;
			LOAD_ADDRBUFF_UB = 1'b1;
			end
	LDA_IND_Y_4 :
			begin
			if (fixUB == 1'b0)
			begin
			ADDRMUX = 4'b0011;
			ALUK = 5'b01101;
			n_select = 1'b1;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A = 1'b1;
			end
		end
	LDA_IND_Y_5 :
			begin
			ADDRMUX = 4'b0011;
			ALUK = 5'b01101;
			n_select = 1'b1;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			AMUX = 1'b1;
			LOAD_A = 1'b1;
			end
	LDX_Z_1 :
			begin
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			LOAD_ADDRBUFF = 1'b1;
			end
	LDX_Z_2 :
			begin
			ADDRMUX = 4'b0001;
			ALUK = 5'b01101;
			n_select = 1'b1;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			XMUX = 2'b01;
			LOAD_X =1'b1;
			end
	LDX_Z_Y_1 :
			begin
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	LDX_Z_Y_2 :
			begin
			ADDRMUX = 4'b0111;
			end
	LDX_Z_Y_3 :
			begin
			ALUK = 5'b01101;
			n_select = 1'b1;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			XMUX = 2'b01;
			LOAD_X =1'b1;
			end
	LDX_ABS_1 :
			begin
			LOAD_ADDRBUFF_LB = 1'b1;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	LDX_ABS_2 :
			begin
			LOAD_ADDRBUFF_UB = 1'b1;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	LDX_ABS_3 :
			begin
			ADDRMUX = 4'b0001;
			ALUK = 5'b01101;
			n_select = 1'b1;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			XMUX = 2'b01;
			LOAD_X = 1'b1;
			end
	LDX_ABS_Y_1 :
			begin
			LOAD_ADDRBUFF_LB = 1'b1;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	LDX_ABS_Y_2 :
			begin 
			LOAD_ADDRBUFF_UB = 1'b1;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	LDX_ABS_Y_3 :
			begin
			UBMUX = 1'b1;
			if (fixUB == 1'b0)
			begin
			ADDRMUX = 4'b0011;
			ALUK = 5'b01101;
			n_select = 1'b1;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			XMUX = 2'b01;
			LOAD_X = 1'b1;
			end
		end
	LDX_ABS_Y_4 :
			begin
			ADDRMUX = 4'b0011;
			ALUK = 5'b01101;
			n_select = 1'b1;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			XMUX = 2'b01;
			LOAD_X = 1'b1;
		end 
	//
	LDY_Z_1 :
			begin
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			LOAD_ADDRBUFF = 1'b1;
			end
	LDY_Z_2 :
			begin
			ADDRMUX = 4'b0001;
			ALUK = 5'b01101;
			n_select = 1'b1;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			YMUX = 1'b1;
			LOAD_Y =1'b1;
			end
	LDY_Z_X_1 :
			begin
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	LDY_Z_X_2 :
			begin
			ADDRMUX = 4'b0111;
			end
	LDY_Z_X_3 :
			begin
			ALUK = 5'b01101;
			n_select = 1'b1;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			YMUX = 1'b1;
			LOAD_Y =1'b1;
			end
	LDY_ABS_1 :
			begin
			LOAD_ADDRBUFF_LB = 1'b1;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	LDY_ABS_2 :
			begin
			LOAD_ADDRBUFF_UB = 1'b1;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	LDY_ABS_3 :
			begin
			ADDRMUX = 4'b0001;
			ALUK = 5'b01101;
			n_select = 1'b1;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			YMUX = 1'b1;
			LOAD_Y = 1'b1;
			end
	LDY_ABS_X_1 :
			begin
			LOAD_ADDRBUFF_LB = 1'b1;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	LDY_ABS_X_2 :
			begin 
			LOAD_ADDRBUFF_UB = 1'b1;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			end
	LDY_ABS_X_3 :
			begin
			UBMUX = 1'b0;
			if (fixUB == 1'b0)
			begin
			ADDRMUX = 4'b0010;
			ALUK = 5'b01101;
			n_select = 1'b1;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			YMUX = 1'b1;
			LOAD_Y = 1'b1;
			end
		end
	LDY_ABS_X_4 :
			begin
			ADDRMUX = 4'b0010;
			ALUK = 5'b01101;
			n_select = 1'b1;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			YMUX = 1'b1;
			LOAD_Y = 1'b1;
			end 
	LSR_A :
			begin
			ALUK = 5'b00101;
			n_select = 1'b0;
			c_select = 4'b0010;
			LOAD_A = 1'b1;
			AMUX = 1'b1;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			Ld_C = 1'b1;
			end
	LSR_Z_1 :
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			LOAD_ADDRBUFF = 1'b1;
			end
	LSR_Z_2 :
			begin
			ADDRMUX = 4'b001; // read from address
			end
	LSR_Z_3 :
			begin
			ADDRMUX = 4'b0001;
			ALUK = 5'b00110;
			n_select = 1'b0;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			Ld_C = 1'b1;
			c_select = 4'b0011;
			LOAD_DATA = 1'b1;
			end
	LSR_Z_4 :
			begin
			ADDRMUX = 4'b0001;
			databus_select = 3'b100; 
			w = 1'b0;
			end
	LSR_Z_X_1 :
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			LOAD_ADDRBUFF = 1'b1;
			end
	LSR_Z_X_2 :
			begin
			; // burn a cycle
			end
	LSR_Z_X_3 :
			begin
			; // 
			end
	LSR_Z_X_4 :
			begin
			ADDRMUX = 4'b0010;
			ALUK = 5'b00110;
			n_select = 1'b0;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			Ld_C = 1'b1;
			c_select = 4'b0011;
			LOAD_DATA = 1'b1;
			end
	LSR_Z_X_5 :
			begin
			ADDRMUX = 4'b0010;
			databus_select = 3'b100; 
			w = 1'b0;
			end
	LSR_ABS_1 :
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			LOAD_ADDRBUFF_LB = 1'b1;
			end
	LSR_ABS_2 :
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			LOAD_ADDRBUFF_UB = 1'b1;
			end
	LSR_ABS_3 :
			begin
			; // waste time
			end
	LSR_ABS_4 :
			begin
			ADDRMUX = 4'b0001;
			ALUK = 5'b00110;
			n_select = 1'b0;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			Ld_C = 1'b1;
			c_select = 4'b0011;
			LOAD_DATA = 1'b1;
			end
	LSR_ABS_5 :
			begin
			ADDRMUX = 4'b0001;
			databus_select = 3'b100; 
			w = 1'b0;
			end
	LSR_ABS_X_1 :
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			LOAD_ADDRBUFF_LB = 1'b1;
			end
	LSR_ABS_X_2 :
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			LOAD_ADDRBUFF_UB = 1'b1;
			end
	LSR_ABS_X_3 :
			begin
			;
			end
	LSR_ABS_X_4 :
			begin
			;
			end
	LSR_ABS_X_5 :
			begin
			ADDRMUX = 4'b0010;
			ALUK = 5'b00110;
			n_select = 1'b0;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			Ld_C = 1'b1;
			c_select = 4'b0011;
			LOAD_DATA = 1'b1;
			end
	LSR_ABS_X_6 :
			begin
			ADDRMUX = 4'b0010;
			databus_select = 3'b100; 
			w = 1'b0;
			end
	//
	ROL_A :
			begin
			ALUK = 5'b00111;
			n_select = 1'b0;
			c_select = 4'b0100;
			LOAD_A = 1'b1;
			AMUX = 1'b1;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			Ld_C = 1'b1;
			end
	ROL_Z_1 :
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			LOAD_ADDRBUFF = 1'b1;
			end
	ROL_Z_2 :
			begin
			ADDRMUX = 4'b001; // read from address
			end
	ROL_Z_3 :
			begin
			ADDRMUX = 4'b0001;
			ALUK = 5'b01000;
			n_select = 1'b0;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			Ld_C = 1'b1;
			c_select = 4'b0101;
			LOAD_DATA = 1'b1;
			end
	ROL_Z_4 :
			begin
			ADDRMUX = 4'b0001;
			databus_select = 3'b100; 
			w = 1'b0;
			end
	ROL_Z_X_1 :
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			LOAD_ADDRBUFF = 1'b1;
			end
	ROL_Z_X_2 :
			begin
			; // burn a cycle
			end
	ROL_Z_X_3 :
			begin
			; // 
			end
	ROL_Z_X_4 :
			begin
			ADDRMUX = 4'b0010;
			ALUK = 5'b01000;
			n_select = 1'b0;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			Ld_C = 1'b1;
			c_select = 4'b0101;
			LOAD_DATA = 1'b1;
			end
	ROL_Z_X_5 :
			begin
			ADDRMUX = 4'b0010;
			databus_select = 3'b100; 
			w = 1'b0;
			end
	ROL_ABS_1 :
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			LOAD_ADDRBUFF_LB = 1'b1;
			end
	ROL_ABS_2 :
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			LOAD_ADDRBUFF_UB = 1'b1;
			end
	ROL_ABS_3 :
			begin
			; // waste time
			end
	ROL_ABS_4 :
			begin
			ADDRMUX = 4'b0001;
			ALUK = 5'b01000;
			n_select = 1'b0;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			Ld_C = 1'b1;
			c_select = 4'b0101;
			LOAD_DATA = 1'b1;
			end
	ROL_ABS_5 :
			begin
			ADDRMUX = 4'b0001;
			databus_select = 3'b100; 
			w = 1'b0;
			end
	ROL_ABS_X_1 :
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			LOAD_ADDRBUFF_LB = 1'b1;
			end
	ROL_ABS_X_2 :
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			LOAD_ADDRBUFF_UB = 1'b1;
			end
	ROL_ABS_X_3 :
			begin
			;
			end
	ROL_ABS_X_4 :
			begin
			;
			end
	ROL_ABS_X_5 :
			begin
			ADDRMUX = 4'b0010;
			ALUK = 5'b01000;
			n_select = 1'b0;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			Ld_C = 1'b1;
			c_select = 4'b0101;
			LOAD_DATA = 1'b1;
			end
	ROL_ABS_X_6 :
			begin
			ADDRMUX = 4'b0010;
			databus_select = 3'b100; 
			w = 1'b0;
			end
	//
	ROR_A :
			begin
			ALUK = 5'b01001;
			n_select = 1'b0;
			c_select = 4'b0010;
			LOAD_A = 1'b1;
			AMUX = 1'b1;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			Ld_C = 1'b1;
			end
	ROR_Z_1 :
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			LOAD_ADDRBUFF = 1'b1;
			end
	ROR_Z_2 :
			begin
			ADDRMUX = 4'b001; // read from address
			end
	ROR_Z_3 :
			begin
			ADDRMUX = 4'b0001;
			ALUK = 5'b01010;
			n_select = 1'b0;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			Ld_C = 1'b1;
			c_select = 4'b0011;
			LOAD_DATA = 1'b1;
			end
	ROR_Z_4 :
			begin
			ADDRMUX = 4'b0001;
			databus_select = 3'b100; 
			w = 1'b0;
			end
	ROR_Z_X_1 :
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			LOAD_ADDRBUFF = 1'b1;
			end
	ROR_Z_X_2 :
			begin
			; // burn a cycle
			end
	ROR_Z_X_3 :
			begin
			; // 
			end
	ROR_Z_X_4 :
			begin
			ADDRMUX = 4'b0010;
			ALUK = 5'b01010;
			n_select = 1'b0;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			Ld_C = 1'b1;
			c_select = 4'b0011;
			LOAD_DATA = 1'b1;
			end
	ROR_Z_X_5 :
			begin
			ADDRMUX = 4'b0010;
			databus_select = 3'b100; 
			w = 1'b0;
			end
	ROR_ABS_1 :
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			LOAD_ADDRBUFF_LB = 1'b1;
			end
	ROR_ABS_2 :
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			LOAD_ADDRBUFF_UB = 1'b1;
			end
	ROR_ABS_3 :
			begin
			; // waste time
			end
	ROR_ABS_4 :
			begin
			ADDRMUX = 4'b0001;
			ALUK = 5'b01010;
			n_select = 1'b0;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			Ld_C = 1'b1;
			c_select = 4'b0011;
			LOAD_DATA = 1'b1;
			end
	ROR_ABS_5 :
			begin
			ADDRMUX = 4'b0001;
			databus_select = 3'b100; 
			w = 1'b0;
			end
	ROR_ABS_X_1 :
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			LOAD_ADDRBUFF_LB = 1'b1;
			end
	ROR_ABS_X_2 :
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			LOAD_ADDRBUFF_UB = 1'b1;
			end
	ROR_ABS_X_3 :
			begin
			;
			end
	ROR_ABS_X_4 :
			begin
			;
			end
	ROR_ABS_X_5 :
			begin
			ADDRMUX = 4'b0010;
			ALUK = 5'b01010;
			n_select = 1'b0;
			Ld_N = 1'b1;
			Ld_Z = 1'b1;
			Ld_C = 1'b1;
			c_select = 4'b0011;
			LOAD_DATA = 1'b1;
			end
	ROR_ABS_X_6 :
			begin
			ADDRMUX = 4'b0010;
			databus_select = 3'b100; 
			w = 1'b0;
			end
	STA_Z_1 :
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			LOAD_ADDRBUFF = 1'b1;
			end
	STA_Z_2 :
			begin
			ADDRMUX = 4'b0001;
			databus_select = 3'b010;
			w = 1'b0;
			end
	STA_Z_X_1 :
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			LOAD_ADDRBUFF = 1'b1;
			end
	STA_Z_X_2 :
			begin
			;
			end
	STA_Z_X_3 :
			begin
			ADDRMUX = 4'b0010;
			databus_select = 3'b010;
			w = 1'b0;
			end
	STA_ABS_1 :
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			LOAD_ADDRBUFF_LB = 1'b1;
			end
	STA_ABS_2 :
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			LOAD_ADDRBUFF_UB = 1'b1;
			end
	STA_ABS_3 :
			begin
			ADDRMUX = 4'b0001;
			databus_select = 3'b010;
			w = 1'b0;
			end
	STA_ABS_X_1:
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			LOAD_ADDRBUFF_LB = 1'b1;
			end
	STA_ABS_X_2:
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			LOAD_ADDRBUFF_UB = 1'b1;
			end
	STA_ABS_X_3:
			begin
			;
			end
	STA_ABS_X_4:
			begin
			ADDRMUX = 4'b0010;
			databus_select = 3'b010;
			w = 1'b0;
			end
	STA_ABS_Y_1:
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			LOAD_ADDRBUFF_LB = 1'b1;
			end
	STA_ABS_Y_2:
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			LOAD_ADDRBUFF_UB = 1'b1;
			end
	STA_ABS_Y_3:
			begin
			;
			end
	STA_ABS_Y_4:
			begin
			ADDRMUX = 4'b0011;
			databus_select = 3'b010;
			w = 1'b0;
			end
	STA_IND_X_1:
			begin
			ADDRMUX = 4'b0100;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			INDMUX = 3'b000;
			LOAD_IND = 1'b1;
			end
	STA_IND_X_2:
			begin
			ADDRMUX = 4'b1001;
			LOAD_ADDRBUFF_LB = 1'b1;
			INDMUX = 3'b010;
			LOAD_IND = 1'b1;
			end
	STA_IND_X_3:
			begin
			LOAD_ADDRBUFF_UB = 1'b1;
			ADDRMUX = 4'b1001;
			end
	STA_IND_X_4:
			begin
			;
			end
	STA_IND_X_5:
			begin
			ADDRMUX = 4'b0001;
			databus_select = 3'b010;
			w = 1'b0;
			end
	STA_IND_Y_1:
			begin
			ADDRMUX = 4'b0100;
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			INDMUX = 3'b011;	// was 1
			LOAD_IND = 1'b1;
			end
	STA_IND_Y_2:
			begin
			ADDRMUX = 4'b1001;
			LOAD_ADDRBUFF_LB = 1'b1;
			INDMUX = 3'b010;
			LOAD_IND = 1'b1;
			end
	STA_IND_Y_3:
			begin
			LOAD_ADDRBUFF_UB = 1'b1;
			ADDRMUX = 4'b1001;
			end
	STA_IND_Y_4:
			begin
			;
			end
	STA_IND_Y_5:
			begin
			ADDRMUX = 4'b0011;
			databus_select = 3'b010;
			w = 1'b0;
			end
	//
	STX_Z_1 :
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			LOAD_ADDRBUFF = 1'b1;
			end
	STX_Z_2 :
			begin
			ADDRMUX = 4'b0001;
			databus_select = 3'b000;
			w = 1'b0;
			end
	STX_Z_Y_1 :
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			LOAD_ADDRBUFF = 1'b1;
			end
	STX_Z_Y_2 :
			begin
			;
			end
	STX_Z_Y_3 :
			begin
			ADDRMUX = 4'b0011;
			databus_select = 3'b000;
			w = 1'b0;
			end
	STX_ABS_1 :
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			LOAD_ADDRBUFF_LB = 1'b1;
			end
	STX_ABS_2 :
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			LOAD_ADDRBUFF_UB = 1'b1;
			end
	STX_ABS_3 :
			begin
			ADDRMUX = 4'b0001;
			databus_select = 3'b000;
			w = 1'b0;
			end
	//
	STY_Z_1 :
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			LOAD_ADDRBUFF = 1'b1;
			end
	STY_Z_2 :
			begin
			ADDRMUX = 4'b0001;
			databus_select = 3'b001;
			w = 1'b0;
			end
	STY_Z_X_1 :
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			LOAD_ADDRBUFF = 1'b1;
			end
	STY_Z_X_2 :
			begin
			;
			end
	STY_Z_X_3 :
			begin
			ADDRMUX = 4'b0010;
			databus_select = 3'b001;
			w = 1'b0;
			end
	STY_ABS_1 :
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			LOAD_ADDRBUFF_LB = 1'b1;
			end
	STY_ABS_2 :
			begin
			ADDRMUX = 4'b0100;
			PCMUX = 2'b10;
			LOAD_PC = 1'b1;
			LOAD_ADDRBUFF_UB = 1'b1;
			end
	STY_ABS_3 :
			begin
			ADDRMUX = 4'b0001;
			databus_select = 3'b001;
			w = 1'b0;
			end
	TAX :
			begin
			ALUK = 5'b01110;
			XMUX = 1'b01;
			LOAD_X = 1'b1;
			n_select = 1'b0;
			Ld_Z = 1'b1;
			Ld_N = 1'b1;
			end
	TAY :
			begin
			ALUK = 5'b01110;
			YMUX = 1'b1;
			LOAD_Y = 1'b1;
			n_select = 1'b0;
			Ld_Z = 1'b1;
			Ld_N = 1'b1;
			end
	TSX :
			begin
			ALUK = 5'b11010;
			XMUX = 2'b01;
			LOAD_X = 1'b1;
			n_select = 1'b0;
			Ld_Z = 1'b1;
			Ld_N = 1'b1;
			end
	TXA :
			begin
			ALUK = 5'b01011;
			AMUX = 1'b1;
			LOAD_A = 1'b1;
			n_select = 1'b0;
			Ld_Z = 1'b1;
			Ld_N = 1'b1;
			end
	TXS :
			begin
			STACKMUX = 2'b00;
			LOAD_SP = 1'b1;
			end
	TYA :
			begin
			ALUK = 5'b01100;
			AMUX = 1'b1;
			LOAD_A = 1'b1;
			n_select = 1'b0;
			Ld_Z = 1'b1;
			Ld_N = 1'b1;
			end
	CLD : ;
	JMP_ABS_1 :
			begin
			LOAD_PC = 1'b1;
			PCMUX = 2'b00;
			ADDRMUX = 4'b0100;
			LOAD_IND = 1'b1;
			INDMUX = 3'b100;
			end
	JMP_ABS_2 :
			begin
			LOAD_PC_UB = 1'b1;
			PCMUX = 2'b00;
			ADDRMUX = 4'b0110;
			end
	JMP_IND_1 :
			begin
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			LOAD_IND_LB = 1'b1;
			INDMUX = 3'b011;
			end
	JMP_IND_2 :
			begin
			ADDRMUX = 4'b0100;
			LOAD_IND_UB = 1'b1;
			INDMUX = 3'b011;
			end
	JMP_IND_3 :
			begin
			ADDRMUX = 4'b1001;
			LOAD_IND = 1'b1;
			INDMUX = 3'b010;
			PCMUX = 1'b0;
			LOAD_PC_LB = 1'b1;
			end
	JMP_IND_4 :
			begin
			ADDRMUX = 4'b1001;
			PCMUX = 1'b0;
			LOAD_PC_UB = 1'b1;
			end
	JSR_1 :
			begin
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			ADDRMUX = 4'b0100;
			LOAD_IND = 1'b1;
			INDMUX = 3'b100;
			LOAD_ADDRBUFF_LB = 1'b1;
			end
	JSR_2 :
			begin
			LOAD_ADDRBUFF_UB = 1'b1;
			ADDRMUX = 4'b0100;
			end
	JSR_3 :
			begin
			PCOUTMUX = 1'b0;
			LOAD_SP = 1'b1;
			STACKMUX = 2'b01;
			ADDRMUX = 4'b0000;
			databus_select = 3'b101;
			w = 1'b0;
			end
	JSR_4 :
			begin
			PCOUTMUX = 1'b1;
			LOAD_SP = 1'b1;
			STACKMUX = 2'b01;
			ADDRMUX = 4'b0000;
			databus_select = 3'b101;
			w = 1'b0;
			end
	JSR_5 :
			begin
			LOAD_PC = 1'b1;
			PCMUX = 2'b11;
			end
	RTS_1 :
			begin
			;
			end
	RTS_2 :
			begin
			LOAD_SP = 1'b1;
			STACKMUX = 2'b10;
			end
	RTS_3 :
			begin
			PCMUX = 2'b00;
			ADDRMUX = 4'b0000;
			LOAD_PC_LB = 1'b1;
			LOAD_SP = 1'b1;
			STACKMUX = 2'b10;
			end
	RTS_4 :
			begin
			PCMUX = 2'b00;
			ADDRMUX = 4'b0000;
			LOAD_PC_UB = 1'b1;
			end
	RTS_5 :
			begin
			LOAD_PC = 1'b1;
			PCMUX = 2'b10;
			end
	RTI_1 :
			begin
			;
			end
	RTI_2 :
			begin
			STACKMUX = 2'b10;
			LOAD_SP = 1'b1;
			end
	RTI_3 :
			begin
			ADDRMUX = 4'b0000;
			PLP = 1'b1;
			ALUK = 5'b01101;
			STACKMUX = 2'b10;
			LOAD_SP = 1'b1;
			end
	RTI_4 :
			begin
			PCMUX = 2'b00;
			ADDRMUX = 4'b0000;
			LOAD_PC_LB = 1'b1;
			STACKMUX = 2'b10;
			LOAD_SP = 1'b1;
			end
	RTI_5 :
			begin
			PCMUX = 2'b00;
			ADDRMUX = 4'b0000;
			LOAD_PC_UB = 1'b1;
			end
	BRK_1 :
			begin
			brk = 1'b1;
			end
	BRK_2 :
			begin
			PCOUTMUX = 1'b0;
			LOAD_SP = 1'b1;
			STACKMUX = 2'b01;
			ADDRMUX = 4'b0000;
			w = 1'b0;
			databus_select = 3'b101;
			end
	BRK_3 :
			begin
			PCOUTMUX = 1'b1;
			LOAD_SP = 1'b1;
			STACKMUX = 2'b01;
			ADDRMUX = 4'b0000;
			w = 1'b0;
			databus_select = 3'b101;
			end
	BRK_4 :
			begin
			LOAD_SP = 1'b1;
			STACKMUX = 2'b01;
			ADDRMUX = 4'b0000;
			w = 1'b0;
			databus_select = 3'b011;
			if (nmi_status)
				addr_reg_nmi = 1'b1;
			else
				irq = 1'b1;
			end
	BRK_5 :
			begin
			ADDRMUX = 4'b0001;
			LOAD_PC_LB = 1'b1;
			PCMUX = 2'b00;
			end
	BRK_6 :
			begin
			ADDRMUX = 4'b0101;
			LOAD_PC_UB = 1'b1;
			PCMUX = 2'b00;
			end
	PHA_1 :
			begin
			;
			end
	PHA_2 :
			begin
			ADDRMUX = 4'b0000;
			LOAD_SP = 1'b1;
			STACKMUX = 2'b01;
			databus_select = 3'b010;
			w = 1'b0;
			end
	PHP_1 :
			begin
			;
			end
	PHP_2 :
			begin
			ADDRMUX = 4'b0000;
			LOAD_SP = 1'b1;
			STACKMUX = 2'b01;
			databus_select = 3'b011;
			w = 1'b0;
			end
	PLA_1 :
			begin
			;
			end
	PLA_2 :
			begin
			LOAD_SP = 1'b1;
			STACKMUX = 2'b10;
			end
	PLA_3 :
			begin
			ADDRMUX = 4'b0000;
			LOAD_A = 1'b1;
			AMUX = 1'b0;
			end
	PLP_1 :
			begin
			;
			end
	PLP_2 :
			begin
			LOAD_SP = 1'b1;
			STACKMUX = 2'b10;
			end
	PLP_3 :
			begin
			ADDRMUX = 4'b0000;
			PLP = 1'b1;
			ALUK = 5'b01101;
			end
	DMA_1 :
			begin
			ADDRMUX = 4'b1010;
			dma_select = 1'b1;
			end
	DMA_2 :
			begin
			ADDRMUX = 4'b1010;
			OAM_write = 1'b1;
			inc_counter = 1'b1;
			end
	NMI_1 :;
	NMI_2 :
			begin
			PCOUTMUX = 1'b0;
			LOAD_SP = 1'b1;
			STACKMUX = 2'b01;
			ADDRMUX = 4'b0000;
			w = 1'b0;
			databus_select = 3'b101;
			end
	NMI_3 :
			begin
			PCOUTMUX = 1'b1;
			LOAD_SP = 1'b1;
			STACKMUX = 2'b01;
			ADDRMUX = 4'b0000;
			w = 1'b0;
			databus_select = 3'b101;
			end
	NMI_4 :
			begin
			LOAD_SP = 1'b1;
			STACKMUX = 2'b01;
			ADDRMUX = 4'b0000;
			w = 1'b0;
			databus_select = 3'b011;
			addr_reg_nmi = 1'b1;
			end
	NMI_5 :
			begin
			ADDRMUX = 4'b0001;
			LOAD_PC_LB = 1'b1;
			PCMUX = 2'b00;
			nmi_done = 1'b1;
			end
	NMI_6 :
			begin
			ADDRMUX = 4'b0101;
			LOAD_PC_UB = 1'b1;
			PCMUX = 2'b00;
			end
		endcase 
	end
endmodule 