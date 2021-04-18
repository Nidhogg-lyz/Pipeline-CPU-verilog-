module ALU(input[31:0]A,B,input[2:0]ALUCtrl,output reg zero,output reg[31:0] result);
always@(*)begin
case(ALUCtrl)
	3'b100:begin//ADD
		result=$signed(A)+$signed(B);
                zero=(result==0)?1:0;  
	end
	3'b101:begin//ADDU
		result=A+B;
		zero=(result==0)?1:0;
	end
	3'b110:begin//SUB
		result=$signed(A)-$signed(B);
		zero=(result==0)?1:0;
	end
	3'b000:begin//AND
		result=A&B;
		zero=(result==0)?1:0;
	end
	3'b001:begin//OR
		result=A|B;
		zero=(result==0)?1:0;
	end
	3'b011:begin//SLT
		result=($signed(A)<$signed(B))?1:0;
		zero=(result==0)?1:0;
	end
endcase
end
endmodule

module ALUCU(input[5:0]func,input[1:0]ALUOp,output reg[2:0]ALUCtrl);
always@(*)begin
if(ALUOp==00)begin
ALUCtrl=3'b100;
end
if(ALUOp==01)begin
ALUCtrl=3'b110;
end
if(ALUOp[1]==1'b1)begin
case(func)
	6'b100000:begin
		ALUCtrl=3'b100;//ADD
	end
	6'b100001:begin
		ALUCtrl=3'b101;//ADDU
	end
	6'b100010:begin
		ALUCtrl=3'b110;//SUB
	end
	6'b100100:begin
		ALUCtrl=3'b000;//AND
	end
	6'b100101:begin
		ALUCtrl=3'b001;//OR
	end
	6'b101010:begin
		ALUCtrl=3'b011;//SLT;
	end
endcase
end
end
endmodule

module CU(input [5:0]Inst,output reg RegDst,RegWr,MemtoReg,MemRd,MemWr,Branch,Jump,output reg [1:0]ALUOp,output reg ALUSrc);
always@(*)begin
case(Inst)
	6'b000000:begin//R
		{ALUOp,ALUSrc,Jump,Branch,MemRd,MemWr,RegDst,RegWr,MemtoReg}=10'b1000000110;
	end
	6'b100011:begin//LW
		{ALUOp,ALUSrc,Jump,Branch,MemRd,MemWr,RegDst,RegWr,MemtoReg}=10'b0010010011;
	end
	6'b101011:begin//SW
		{ALUOp,ALUSrc,Jump,Branch,MemRd,MemWr,RegDst,RegWr,MemtoReg}=10'b0010001x0x;
	end
	6'b000010:begin//J
		{ALUOp,ALUSrc,Jump,Branch,MemRd,MemWr,RegDst,RegWr,MemtoReg}=10'bxxx1000x0x;
	end
	6'b000100:begin//BEQ
		{ALUOp,ALUSrc,Jump,Branch,MemRd,MemWr,RegDst,RegWr,MemtoReg}=10'b0100100x0x;
	end
endcase
end
endmodule

module FI_ID(input clk,input[31:0]NPC1_in,IR_in,output reg [31:0]NPC1_o,IR_o);
reg[31:0] NPC1,IR;
always@(posedge clk)begin
NPC1=NPC1_in;
IR=IR_in;

NPC1_o=NPC1;
IR_o=IR;
end
/*assign NPC1_o=NPC1;
assign IR_o=IR;*/
endmodule

module ID_EX(input clk,input[31:0]NPC1_in,Rs_in,Rt_in,Imm32_in,IR_in,
	input RegDst,RegWr,MemtoReg,MemRd,MemWr,Branch,Jump,input[1:0]ALUOp,input ALUSrc,
	output reg[2:0]WB_o,output reg[3:0]MA_o,output reg[2:0]EX_o,
	output reg[31:0]NPC1_o,Rs_o,Rt_o,Imm32_o,IR_o);
reg[31:0] NPC1,Rs,Rt,Imm32,IR;
reg[2:0]WB;
reg[3:0]MA;
reg[2:0]EX;

always@(posedge clk)begin
NPC1=NPC1_in;
Rs=Rs_in;
Rt=Rt_in;
Imm32=Imm32_in;
IR=IR_in;
WB={RegDst,RegWr,MemtoReg};
MA={MemRd,MemWr,Branch,Jump};
EX={ALUOp,ALUSrc};

NPC1_o=NPC1;
Rs_o=Rs;
Rt_o=Rt;
Imm32_o=Imm32;
IR_o=IR;
WB_o=WB;
MA_o=MA;
EX_o=EX;
end
/*assign NPC1h_o=NPC1[31:28];
assign NPC1_o=NPC1;
assign Rs_o=Rs;
assign Rt_o=Rt;
assign Imm32_o=Imm32;
assign IR_o=IR;
assign WB_o=WB;
assign MA_o=MA;
assign Ex_o=EX;*/
endmodule

module EX_MA(input clk,input [31:0]NPC3_in,NPC2_in,input Flag_in,input [31:0]ALUOut_in,Rt_in,IR_in,
	input [2:0]WB_in,input[3:0]MA_in,
	output reg[2:0]WB_o,output reg[3:0]MA_o,
	output reg[31:0]NPC3_o,NPC2_o,output reg ZF,output reg[31:0]ALUOut_o,Rt_o,IR_o);
reg[31:0]NPC3,NPC2,ALUOut,Rt,IR;
reg[2:0]WB;
reg[3:0]MA;
reg Flag;
always@(posedge clk)begin
NPC3=NPC3_in;
NPC2=NPC2_in;
Flag=Flag_in;
ALUOut=ALUOut_in;
Rt=Rt_in;
IR=IR_in;
WB=WB_in;
MA=MA_in;

NPC3_o=NPC3;
NPC2_o=NPC2;
ZF=Flag;
ALUOut_o=ALUOut;
Rt_o=Rt;
IR_o=IR;
WB_o=WB;
MA_o=MA;
end
/*assign NPC3_o=NPC3;
assign NPC2_o=NPC2;
assign ZF=Flag;
assign ALUOut_o=ALUOut;
assign Rt_o=Rt;
assign IR_o=IR;
assign WB_o=WB;
assign MA_o=MA;*/
endmodule

module MA_WB(input clk,input [31:0]ALUOut_in,MEMOut_in,IR_in,
	input[2:0]WB_in,
	output reg[2:0]WB_o,
	output reg[31:0]ALUOut_o,MEMOut_o,IR_o);
reg[31:0]ALUOut,MEMOut,IR;
reg[2:0]WB;
always@(posedge clk)begin
ALUOut=ALUOut_in;
MEMOut=MEMOut_in;
IR=IR_in;
WB=WB_in;

ALUOut_o=ALUOut;
MEMOut_o=MEMOut;
IR_o=IR;
WB_o=WB;
end
/*assign ALUOut_o=ALUOut;
assign MEMOut_o=MEMOut;
assign IR_o=IR;
assign WB_o=WB;*/
endmodule
