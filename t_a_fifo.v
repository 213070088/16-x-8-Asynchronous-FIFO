`timescale 1ns / 1ps

module t_a_fifo;
reg wr_clk,rd_clk,rst;
wire wr_full,rd_empty;
wire [7:0] d_out;

a_fifo dut(d_out, wr_full, rd_empty,
rd_clk, wr_clk, rst);


initial 
begin
wr_clk=0;
rd_clk=0;
rst=1;
#1000 $stop;
end


initial
#5 rst=0;

always
#25 wr_clk=~wr_clk;

always
#250 rd_clk=~rd_clk;



endmodule









