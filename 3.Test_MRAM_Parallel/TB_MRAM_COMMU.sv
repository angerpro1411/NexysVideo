`timescale 1ns/100ps
module TB_MRAM_COMMU();
    logic i_CLK,i_RST_n;

    logic i_START_CMD;
    logic [31:0]i_REG0;
	logic [31:0]o_REG1;
    logic [31:0]i_REG2;
    logic [31:0]i_REG3;
	//wire [15:0]DQ;

    localparam BIT_RD_WRn = 0;
    localparam BIT_BLEn  = 1;
    localparam BIT_BHEn  = 2;



    
    localparam BIT_BUSY   = 0;
	localparam BIT_ERR    = 1;


	localparam DATA_WIDTH = 16;
    localparam ADDR_WIDTH = 18;

	//Signal for MRAM MODELING connect to MRAM_COMMU
	logic E_n;
    logic G_n;
    logic W_n;
    logic[ADDR_WIDTH-1:0] ADDR;
    logic UB_n; //Upper byte
    logic LB_n; //Lower byte
    wire[DATA_WIDTH-1:0] DQ;

MRAM_COMMU uut (

    .i_CLK(i_CLK),
    .i_RST_n(i_RST_n),

    .i_START_CMD(i_START_CMD),
    .i_REG0(i_REG0),
    .o_REG1(o_REG1),
    .i_REG2(i_REG2),
    .i_REG3(i_REG3),
    .o_REG4(),


    .E_n(E_n),
    .G_n(G_n),
    .W_n(W_n),
    .ADDR(ADDR),
    .UB_n(UB_n),
    .LB_n(LB_n),
    .DQ(DQ)
);


MRAM_MODELING MRAM1(
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


	//Stimulus
	initial
	begin
		//normal case, waiting no busy
	    repeat(2) @(posedge i_CLK);
	    write_data(18'd0,16'd100);
	    @(negedge o_REG1[BIT_BUSY]);
	    write_data(18'd1,16'd200);
	    @(negedge o_REG1[BIT_BUSY]);
	    read_data(18'd0);
		@(negedge o_REG1[BIT_BUSY]);
		read_data(18'd1);

		// //anormal case, no check busy => lost data.
	    // repeat(2) @(posedge i_CLK);
	    // write_data(18'd100,16'd100);
	    // @(posedge i_CLK);
	    // write_data(18'd200,16'd200);
	    // @(posedge i_CLK);
	    // read_data(18'b100);

	end


	task write_data(logic [17:0] address, logic [15:0]i_data);
	    fork
	    begin
		i_REG2 = {14'd0,address};
		i_REG3 = {16'd0,i_data};
		i_REG0 = 0;
		i_START_CMD = 0;
	    end 
	    begin
		@(posedge i_CLK);    
		i_START_CMD = 1;
		@(posedge i_CLK);
		i_START_CMD = 0;
		i_REG0[2:0] = 3'b000;
	    end
	    join
	endtask


	task read_data(logic [17:0] address);
	    fork
	    begin
		i_REG2 = {14'd0,address};
		i_REG0 = 0;
		i_START_CMD = 0;
	    end
	    begin
		@(posedge i_CLK);
		i_START_CMD = 1;
		@(posedge i_CLK);
		i_START_CMD = 0;
		i_REG0[2:0] = 3'b001;
	    end
		join
	endtask


endmodule
