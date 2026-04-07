`timescale 1ns/100ps

module test();
	logic clk, rst_n;
	logic valid,ready;
	logic data_out;
	
	typedef enum logic[4:0] = 
	{
		IDLE = 4'b0001,
		LOAD = 4'b0010,
		PROC = 4'b0100,
		DONE = 4'b1000
	};
	
	assert property (@(posedge clk))
		!rsn_n | ->  ##1 (data_out == 0); 

	asset property (@(posedge clk))
		

endmodule