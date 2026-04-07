`timescale 1ns/100ps

module TB_MRAM_MODELING_ver2();
	localparam DATA_WIDTH = 16;
    localparam ADDR_WIDTH = 18;
    logic i_CLK,i_RST_n;

	//Signal for MRAM MODELING connect to MRAM_COMMU
	logic E_n;
    logic G_n;
    logic W_n;
    logic[ADDR_WIDTH-1:0] ADDR;
    logic UB_n; //Upper byte
    logic LB_n; //Lower byte
    wire[DATA_WIDTH-1:0] DQ;

MRAM_MODELING_ver2 MRAM1(
    .E_n(E_n),
    .G_n(G_n),
    .W_n(W_n),
    .ADDR(ADDR),
    .UB_n(UB_n),
    .LB_n(LB_n),
    .DQ(DQ)

);

	//clock block
	always
	begin
	i_CLK = 1;
	#5;
	i_CLK = 0;
	#5;
	end

	initial
	begin
	    i_RST_n = 0;
	    #13;
	    i_RST_n = 1;
	end

    initial begin
        repeat(2) @(posedge i_CLK);
        E_n = 1;
        G_n = 0;
        UB_n = 0;
        LB_n = 0;
        W_n = 1;
        repeat(2) @(posedge i_CLK);
        E_n = 0;
        G_n = 1;
        UB_n = 0;
        LB_n = 0;
        W_n = 1;
        repeat(2) @(posedge i_CLK);
        E_n = 0;
        G_n = 0;
        UB_n = 0;
        LB_n = 0;
        W_n = 1;
        repeat(2) @(posedge i_CLK);
        E_n = 0;
        G_n = 0;
        UB_n = 1;
        LB_n = 1;
        W_n = 1;
    end


endmodule