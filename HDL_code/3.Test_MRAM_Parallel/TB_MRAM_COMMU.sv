`timescale 1ns/100ps
module TB_MRAM_COMMU();
    logic i_CLK,i_RST_n;
        // -- Assume that AXI_LITE will command write or read through Register
        // -- REG0 : Control : RD/WRn, BLEN, BHEN 
        // -- REG1 : STATUS  : ERR, Busy
        // -- REG2 : ADDRESS 
        // -- REG3 : WR_DATA
        // -- REG4 : RD_DATA
    logic i_START_CMD;
    logic [31:0]i_REG0;
	logic [31:0]o_REG1;
    logic [31:0]i_REG2;
    logic [31:0]i_REG3;
	logic [31:0]o_REG4;
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

	int unsigned result = 0;

MRAM_COMMU uut (

    .i_CLK(i_CLK),
    .i_RST_n(i_RST_n),

    .i_START_CMD(i_START_CMD),
    .i_REG0(i_REG0),
    .o_REG1(o_REG1),
    .i_REG2(i_REG2),
    .i_REG3(i_REG3),
    .o_REG4(o_REG4),


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

		testWR_RD();

		// simple_WRnRD();
		// losedata_WRITEnREAD();


	end


	task write_data(logic [17:0] address, logic [15:0]i_data);
	    fork
	    begin
		i_REG2 = {14'd0,address};
		i_REG3 = {16'd0,i_data};
	    end 
	    begin
		i_REG0 = 0;
		i_START_CMD = 0;			
		@(posedge i_CLK);    
		i_START_CMD = 1;
		@(posedge i_CLK);
		i_START_CMD = 0;
		i_REG0[2:0] = 3'b000;
	    end
	    join
	endtask


	task read_data(logic [17:0] address,output int unsigned result);
	    fork
	    begin
		i_REG2 = {14'd0,address};
	    end
	    begin
		i_REG0 = 0;
		i_START_CMD = 0;			
		@(posedge i_CLK);
		i_START_CMD = 1;
		@(posedge i_CLK);
		i_START_CMD = 0;
		i_REG0[2:0] = 3'b001;
	    end
		join
		@(posedge G_n);
		result = $unsigned(o_REG4);
	endtask

	task simple_WRnRD();
	    repeat(2) @(posedge i_CLK);
		write_data(18'd0,16'd100);
		@(negedge o_REG1[BIT_BUSY]);
		write_data(18'd1,16'd200);
		@(negedge o_REG1[BIT_BUSY]);
		read_data(18'd0,result);
		@(negedge o_REG1[BIT_BUSY]);
		read_data(18'd1,result);
	endtask

	task losedata_WRITEnREAD();
		// //anormal case, no check busy => lost data.
	    repeat(2) @(posedge i_CLK);
	    write_data(18'd100,16'd100);
	    @(posedge i_CLK);
	    write_data(18'd200,16'd200);
	    @(posedge i_CLK);
	    read_data(18'b100,result);
	endtask

	task testWR_RD();

		//normal case, waiting no busy
	    repeat(2) @(posedge i_CLK);
		for(int unsigned i=0; i<20;i++) begin
			write_data(18'(i),16'(i+1));
			@(negedge o_REG1[BIT_BUSY]);
		end

	    for(int unsigned i=0;i<20;i++) begin 
			result = 0;
	    	read_data(18'(i),result);
			assert (result == i+1) 
				else $warning("Data isn't matched Result = %d different i+1 = %d",result,i+1);
			@(negedge o_REG1[BIT_BUSY]);
		end	

		//write i+1
		for(int unsigned i=20; i<40;i++) begin
			write_data(18'(i),16'(i+1));
			@(negedge o_REG1[BIT_BUSY]);
		end

		//But check i to trigger the warning
	    for(int unsigned i=20;i<40;i++) begin 
			result = 0;
	    	read_data(18'(i),result);
			assert (result == i) 
				else $warning("Data isn't matched Result = %d different i = %d",result,i);
			@(negedge o_REG1[BIT_BUSY]);
		end	

		//Random write
		for(int unsigned i=40;i<60;i++) begin
			write_data(18'(i),16'($urandom_range(((1<<16)-1),0)));
			@(negedge o_REG1[BIT_BUSY]);
		end

		@(negedge o_REG1[BIT_BUSY]);	
	endtask

endmodule
