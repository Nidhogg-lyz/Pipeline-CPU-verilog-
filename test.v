`timescale 1ns/1ns
module PipeCPU(input clk,reset);
wire[31:0]PC_in,PC_out,Add1_out,Inst,FI_NPCo,FI_IRo,mux1_i1,RFW_data,R_data1,R_data2,sig_out;
wire[31:0]ID_NPCo,ID_Rso,ID_Rto,ID_Imm32o,ID_IRo,shl2_o,Add2_out,mux2_o,ALUOut;
wire[31:0]EX_NPC3_in,EX_NPC3o,EX_NPC2o,EX_ALUOut,EX_Rto,EX_IRo,R_data;
wire[31:0]MA_ALUOut,MA_MEMOut,MA_IRo;
wire[4:0]RFW_Reg;
wire[2:0]ID_WBo,ID_EXo,EX_WBo,ALUCtrl,MA_WBo;
wire[3:0]ID_MAo,EX_MAo;
wire[27:0]shl1_o;
wire RegDst,RegWr,MemtoReg,MemRd,MemWr,Branch,Jump,ALUSrc,mux5_i1;
wire [1:0]ALUOp;
wire zero,EX_Flago,PCSrc;

PC pc(clk,reset,PC_in,PC_out);
Add4 Add1(PC_out,Add1_out);
mux2_to_1 mux1(PC_in,Add1_out,mux1_i1,PCSrc);
IM im(PC_out,Inst);
FI_ID fi_id(clk,Add1_out,Inst,FI_NPCo,FI_IRo);
RegFiles rf(clk,MA_WBo[1],RFW_data,FI_IRo[25:21],FI_IRo[20:16],RFW_Reg,R_data1,R_data2);
CU cu(FI_IRo[31:26],RegDst,RegWr,MemtoReg,MemRd,MemWr,Branch,Jump,ALUOp,ALUSrc);
SignExt16_32 sig(FI_IRo[15:0],sig_out);
ID_EX id_ex(clk,FI_NPCo,R_data1,R_data2,sig_out,FI_IRo,RegDst,RegWr,MemtoReg,MemRd,MemWr,Branch,Jump,ALUOp,ALUSrc,ID_WBo,ID_MAo,ID_EXo,ID_NPCo,ID_Rso,ID_Rto,ID_Imm32o,ID_IRo);
SHL2_26 shl1(ID_IRo[25:0],shl1_o);
SHL2_32 shl2(ID_Imm32o,shl2_o);
Add Add2(ID_NPCo,shl2_o,Add2_out);
ALUCU alucu(ID_IRo[5:0],ID_EXo[2:1],ALUCtrl);
mux2_to_1 mux2(mux2_o,ID_Rto,ID_Imm32o,ID_EXo[0]);
ALU alu(ID_Rso,mux2_o,ALUCtrl,zero,ALUOut);
EX_MA ex_ma(clk,EX_NPC3_in,Add2_out,zero,ALUOut,ID_Rto,ID_IRo,ID_WBo,ID_MAo,EX_WBo,EX_MAo,EX_NPC3o,EX_NPC2o,EX_Flago,EX_ALUOut,EX_Rto,EX_IRo);
mux4_to_1 mux5(mux1_i1,,EX_NPC3o,EX_NPC2o,,mux5_i1,EX_MAo[0]);
DataMem dm(EX_MAo[3],EX_MAo[2],EX_ALUOut,EX_Rto,R_data);
mux2_to_1 mux3(RFW_data,MA_ALUOut,MA_MEMOut,MA_WBo[0]);
mux2_to_1 mux4(RFW_Reg,MA_IRo[20:16],MA_IRo[15:11],MA_WBo[2]);defparam mux4.width=5;
MA_WB ma_wb(clk,EX_ALUOut,R_data,EX_IRo,EX_WBo,MA_WBo,MA_ALUOut,MA_MEMOut,MA_IRo);
myOR mymor(mux5_i1,EX_MAo[0],PCSrc);
assign EX_NPC3_in={ID_NPCo[31:28],shl1_o};
assign mux5_i1=EX_Flago&EX_MAo[1];
//assign PCSrc=mux5_i1|EX_MAo[0];
endmodule

module myOR(input A,B,output reg O);
reg result;
initial begin
result=0;
O=result;
end
always@(*)begin
if(A|B==1||A|B==0)begin
result=A|B;
O=result;
end
end
endmodule

module P_CPUt;
reg clk,reset;
wire [31:0]aluout;
wire [31:0]i;
wire [31:0]Rresult;
wire [31:0]A,R_data2;
wire [2:0]ctrl;
wire [5:0]func;
wire [2:0]ALUOp;
wire [31:0]Mresult;
wire zero,PCSrc;
//wire [4:0]out5;
initial begin
clk=0;
reset=1;
end

always #20 begin
clk=~clk;
reset=0;
end

PipeCPU cpu(clk,reset);
assign aluout=cpu.ex_ma.ALUOut;
assign Rresult=cpu.rf.regs[7];//cpu.rf.regs[1];
assign Mresult=cpu.dm.memory[5];

assign A=cpu.ID_Rso;
assign R_data2=cpu.ID_Rto;
assign func=cpu.ID_IRo[5:0];
assign ALUOp=cpu.ID_EXo;
assign ctrl=cpu.ALUCtrl;

assign zero=cpu.zero;
assign PCSrc=cpu.PCSrc;

assign i=cpu.PC_out;

endmodule
