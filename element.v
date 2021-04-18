module mux4_to_1(out,i0,i1,i2,i3,s1,s0);
parameter width=32;
output reg[width-1:0] out;
input [width-1:0] i0,i1,i2,i3;
input s1,s0;

always @(s1 or s0 or i0 or i1 or i2 or i3)
begin
	case({s1,s0})
		2'b00:begin
		out=i0;
		end
		2'b01:begin
		out=i1;
		end
		2'b10:begin
		out=i2;
		end
		2'b11:begin
		out=i3;
		end
	endcase
end

endmodule

module mux2_to_1(out,i0,i1,s);
parameter width=32;
output reg [width-1:0] out;
input [width-1:0] i0,i1;
input s;
always @(i0 or i1 or s)
begin
	out=(s==0)?i0:i1;
end
endmodule

module RegFiles(input clk,W,
		input[31:0]W_data,
		input[4:0] R_reg1,R_reg2,W_reg,
		output reg[31:0]R_data1,R_data2);
parameter storage=32;
reg [31:0]regs[0:storage-1];
reg[4:0]address;
integer i;

initial begin
address=0;
for(i=0;i<storage;i=i+1) regs[i]=0;

//initialize for test
regs[0]=12;
regs[1]=3;
regs[2]=7;
regs[3]=1;
regs[4]=7;
regs[5]=-9;
regs[6]=-17;

end

always@(posedge clk or R_reg1 or R_reg2)begin

if(W)begin
address=W_reg;
regs[address]=W_data;
end
address=R_reg1;
R_data1=regs[address];
address=R_reg2;
R_data2=regs[address];

end

endmodule

module IM(input [31:0]Addr,output reg[31:0]Inst);
parameter storage=127;
reg [7:0]memory[0:storage-1];
reg [31:0]address;
integer i;

initial begin
address=0;
for(i=0;i<storage;i=i+1) memory[i]=0;
//initialize for test
{memory[0],memory[1],memory[2],memory[3]}=32'b000000_00110_00000_00111_00000_100000;//add:rf[7]=rf[6]+rf[0]...addu
{memory[4],memory[5],memory[6],memory[7]}=32'b000000_00001_00010_00111_00000_100010;//sub:rf[7]=rf[1]-rf[2]
{memory[8],memory[9],memory[10],memory[11]}=32'b000000_00010_00011_00111_00000_100100;//and:rf[7]=rf[2]&rf[3]
{memory[12],memory[13],memory[14],memory[15]}=32'b000000_00000_00001_00111_00000_100101;//or:rf[7]=rf[0] | rf[1]
{memory[16],memory[17],memory[18],memory[19]}=32'b000000_00110_00100_00111_00000_101010;//slt:rf[7]=rf[6]<rf[4]?1:0
{memory[20],memory[21],memory[22],memory[23]}=32'b000000_00110_00100_00111_00000_100001;//addu:rf[7]=rf[6]+rf[4]
{memory[24],memory[25],memory[26],memory[27]}=32'b100011_00011_00111_0000000000000001;//lw:rf[7]=DM[rf[3]+1]
{memory[28],memory[29],memory[30],memory[31]}=32'b101011_00011_00010_0000000000000100;//sw:DM[rf[3]+4]=rf[2]

//{memory[0],memory[1],memory[2],memory[3]}=32'b000100_00010_00100_0000000000000100;//beq:PC=PC+4+4<<2;
//{memory[0],memory[1],memory[2],memory[3]}=32'b000010_00000000000000000000000011;//J:PC=1100;

end

always@(*)begin
address=Addr;
Inst={memory[address],memory[address+1],memory[address+2],memory[address+3]};
end
endmodule

module DataMem(input R,W,
		input [31:0]Addr,
		input [31:0]W_data,
		output reg[31:0]R_data);
parameter storage=128;
reg[31:0] address;
reg[31:0] memory[0:storage-1];
integer i;

initial
begin
address=0;
for(i=0;i<storage;i=i+1) memory[i]=0;

//initialize for test
memory[0]=7;
memory[1]=13;
memory[2]=22;

end 

always@(*)
begin
address=Addr;
if(R==1)begin
R_data=memory[address];
end
if(W==1)begin
memory[address]=W_data;
end
end
endmodule

module PC(input clk,reset,
	input[31:0] Address,
	output reg [31:0] out);
initial
begin
out=0;
end
always @(posedge clk or negedge reset)
	begin
		out=reset?0:Address;
	end
endmodule

module Add4(input [31:0]in,output[31:0] out);
assign out=in+4;
endmodule

module Add(input [31:0]A,B,output [31:0] out);
assign out=A+B;
endmodule

module SHL2_26(input [25:0]in,output [27:0]out);
assign out=in<<2;
endmodule

module SHL2_32(input [31:0]in,output [31:0]out);
assign out=in<<2;
endmodule

module SignExt16_32(input [15:0]in,output [31:0]out);
assign out[15:0]=in;
assign out[31:16]=in[15]?16'hffff : 16'h0000;
endmodule

module SignExt5_32(input [4:0]in,output [31:0]out);
assign out[4:0]=in;
assign out[31:5]=in[4]?27'h7ffffff:27'h0000000;
endmodule
