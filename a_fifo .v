`timescale 1ns / 1ps


module a_fifo(d_out, write_full, read_empty,
read_clk, write_clk, rst);
//d_out=dataout
//reset=rst
parameter WID = 8; //WIDTH=WID
parameter PTR = 4; //PTR=POINTER
output [WID-1 : 0] d_out;
output write_full;
output read_empty;
//d_in=datain
wire [WID-1 : 0] d_in; 
input read_clk, write_clk;
input rst;

reg [PTR : 0] rd_ptr, rd_syn_1, rd_syn_2;
reg [PTR : 0] wr_ptr, wr_syn_1, wr_syn_2;
wire [PTR:0] rd_ptr_g,wr_ptr_g;

parameter DEPTH = 1 << PTR;

reg [WID-1 : 0] mem [DEPTH-1 : 0];

wire [PTR : 0] rd_ptr_syn;
wire [PTR: 0] wr_ptr_syn;
reg full,empty;
reg [7:0] tr_ptr;

//--write logic--//

always @(posedge write_clk or posedge rst) begin
if (rst) begin
wr_ptr <= 0;
tr_ptr<=0;
end
else if (full == 1'b0) begin
wr_ptr <= wr_ptr + 1;
tr_ptr<=tr_ptr+1;
mem[wr_ptr[PTR-1 : 0]] <= d_in;
end
end

send s(tr_ptr,d_in);

//--read pointer synchronizer controled by write clock--//

always @(posedge write_clk) begin
rd_syn_1 <= rd_ptr_g;
rd_syn_2 <= rd_syn_1;
end

//--read logic--//

always @(posedge read_clk or posedge rst) begin
if (rst) begin
rd_ptr <= 0;
end
else if (empty == 1'b0) begin
rd_ptr <= rd_ptr + 1;
end
end

//--write pointer synchronizer controled by read clock--//

always @(posedge read_clk) begin
wr_syn_1 <= wr_ptr_g;
wr_syn_2 <= wr_syn_1;
end

//--Combinational logic--//
//--Binary pointer--//

always @(*)
begin
if({~wr_ptr[PTR],wr_ptr[PTR-1:0]}==rd_ptr_syn)
full = 1;
else
full = 0;
end


always @(*)
begin
if(wr_ptr_syn==rd_ptr)
empty = 1;
else
empty = 0;
end

assign d_out = mem[rd_ptr[PTR-1 : 0]];


//--binary code to gray code--//

assign wr_ptr_g = wr_ptr ^ (wr_ptr >> 1);
assign rd_ptr_g = rd_ptr ^ (rd_ptr >> 1);

//--gray code to binary code--//

assign wr_ptr_syn[4]=wr_syn_2[4];
assign wr_ptr_syn[3]=wr_syn_2[3] ^ wr_ptr_syn[4];
assign wr_ptr_syn[2]=wr_syn_2[2] ^ wr_ptr_syn[3];
assign wr_ptr_syn[1]=wr_syn_2[1] ^ wr_ptr_syn[2];
assign wr_ptr_syn[0]=wr_syn_2[0] ^ wr_ptr_syn[1];


assign rd_ptr_syn[4]=rd_syn_2[4];
assign rd_ptr_syn[3]=rd_syn_2[3] ^ rd_ptr_syn[4];
assign rd_ptr_syn[2]=rd_syn_2[2] ^ rd_ptr_syn[3];
assign rd_ptr_syn[1]=rd_syn_2[1] ^ rd_ptr_syn[2];
assign rd_ptr_syn[0]=rd_syn_2[0] ^ rd_ptr_syn[1];

assign write_full = full;
assign read_empty = empty;

endmodule

module send(wr_ptr,d_out);

output [7:0] d_out;
input [7:0] wr_ptr;
reg [7:0] input_rom [127:0];
integer i;
initial begin

for(i=0;i<128;i=i+1)
input_rom[i] = i+10;
end

assign d_out = input_rom[wr_ptr];

endmodule
