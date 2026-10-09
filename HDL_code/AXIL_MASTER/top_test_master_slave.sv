`timescale 1ns/100ps

module top_test_master_slave();


    // AXI PROTOCOL
		logic AXI_ACLK 		;
		logic AXI_ARESETN		;
		logic AXI_AWVALID		;
		
		logic AXI_AWREADY		;
		logic [31:0]AXI_AWADDR		;
			
		logic [31:0]AXI_WDATA		;
		logic [3:0]AXI_WSTRB		;
		logic AXI_WVALID		;
		
		logic AXI_WREADY		;
		
		logic AXI_BREADY		;
		logic AXI_BVALID		;
		logic [1:0]AXI_BRESP		;
	    logic [31:0]AXI_ARADDR		;	
		logic AXI_ARVALID		;
		
		logic AXI_ARREADY	 ;
				
		logic [31:0]AXI_RDATA		;		
		logic [1:0]AXI_RRESP		;
        logic AXI_RVALID		;
		
		logic AXI_RREADY		;

    // USER PROCESSOR SIDE

        logic START_WRITE;
        logic [31:0] WR_ADDR;
        logic [31:0] WR_DATA;
        logic [3:0] WR_STRB;

        logic START_READ;
        logic [31:0] RD_ADDR;

        // Havent data taken by host
        logic [31:0] RD_DATA;
        logic RD_DATA_VALID;
        logic HOST_RD_DATA_READY;

        //STATUS from PROCESSOR or user
        logic WR_BUSY;
        logic ERR_WR;
        logic ERR_RD;

    AXIL_MASTER #(
        .ADDR_WIDTH(32),
        .DATA_WIDTH(32)
    ) MASTER_IP(

        //User - Processor data
        .START_WRITE(START_WRITE),
        .WR_ADDR(WR_ADDR),
        .WR_DATA(WR_DATA),
        .WR_STRB(WR_STRB),

        .START_READ(START_READ),
        .RD_ADDR(RD_ADDR),

        // Untaken data by host
        .RD_DATA(RD_DATA),
        .RD_DATA_VALID(RD_DATA_VALID),
        .HOST_RD_DATA_READY(HOST_RD_DATA_READY),

        //STATUS from PROCESSOR or user
        .WR_BUSY(WR_BUSY),
        .ERR_WR(ERR_WR),
        .ERR_RD(ERR_RD),


        //clock and reset
        .M_AXIL_ACLK(AXI_ACLK),
        .M_AXIL_RSTN(AXI_ARESETN),

        //Write address channel
        .M_AXIL_AWVALID(AXI_AWVALID),
        .M_AXIL_AWADDR(AXI_AWADDR),
        .M_AXIL_AWREADY(AXI_AWREADY),

        //Write data channel
        .M_AXIL_WVALID(AXI_WVALID),
        .M_AXIL_WDATA(AXI_WDATA),
        .M_AXIL_WSTRB(AXI_WSTRB),
        .M_AXIL_WREADY(AXI_WREADY),

        //Write response channel
        .M_AXIL_BREADY(AXI_BREADY),
        .M_AXIL_BVALID(AXI_BVALID),
        .M_AXIL_BRESP(AXI_BRESP),

        //Read channel address
        .M_AXIL_ARVALID(AXI_ARVALID),
        .M_AXIL_ARADDR(AXI_ARADDR),
        .M_AXIL_ARREADY(AXI_ARREADY),

        //Read channel data 
        .M_AXIL_RVALID(AXI_RVALID),
        .M_AXIL_RDATA(AXI_RDATA),
        .M_AXIL_RREADY(AXI_RREADY),

        .M_AXIL_RRESP(AXI_RRESP)
    );


    AXIL_SLAVE SLAVE_IP
	(
		.S_AXI_ACLK(AXI_ACLK),
		.S_AXI_ARESETN(AXI_ARESETN),
		.S_AXI_AWVALID(AXI_AWVALID),
		
		.S_AXI_AWREADY(AXI_AWREADY),
		.S_AXI_AWADDR(AXI_AWADDR),
			
		.S_AXI_WDATA(AXI_WDATA),
		.S_AXI_WSTRB(AXI_WSTRB),
		.S_AXI_WVALID(AXI_WVALID),
		
		.S_AXI_WREADY(AXI_WREADY),
		
		.S_AXI_BREADY(AXI_BREADY),
		.S_AXI_BVALID(AXI_BVALID),
		.S_AXI_BRESP(AXI_BRESP),
	    .S_AXI_ARADDR(AXI_ARADDR),	
		.S_AXI_ARVALID(AXI_ARVALID),
		
		.S_AXI_ARREADY(AXI_ARREADY),
				
		.S_AXI_RDATA(AXI_RDATA),		
		.S_AXI_RRESP(AXI_RRESP),
        .S_AXI_RVALID(AXI_RVALID),
		.S_AXI_RREADY(AXI_RREADY)
	);

    //clock process
    always begin
        AXI_ACLK = 1;
        #5;
        AXI_ACLK = 0;
        #5;
    end

    //reset process
    initial begin
        AXI_ARESETN = 0;
        #13;
        AXI_ARESETN = 1;
    end


    //stimulus
    initial begin
        main_test();

    end

    task WRITE(input logic[31:0]dat,input logic[31:0]addr,input logic[3:0]strb);
        @(negedge AXI_ACLK);
        WR_DATA = dat;
        WR_ADDR = addr;
        WR_STRB = strb;
        START_WRITE = 1'b1;
        @(negedge AXI_ACLK);
        START_WRITE = 1'b0;
    endtask

    task READ(input logic[31:0]addr);
        @(negedge AXI_ACLK);
        RD_ADDR = addr;
        START_READ = 1'b1;
        @(negedge AXI_ACLK);
        START_READ = 1'b0;
    endtask

    task PROCESSOR_TAKES();
        
        HOST_RD_DATA_READY = 1'b1;
        @ ((HOST_RD_DATA_READY) && (RD_DATA_VALID));
        @(posedge AXI_ACLK);
        HOST_RD_DATA_READY = 1'b0;
    endtask

    task delay();
        @(negedge AXI_ACLK);
    endtask

    task main_test();
        repeat(2)
            @(negedge AXI_ACLK);
        WRITE(32'hAAAAAAAA,32'h00000000,4'b1111);
        @(WR_BUSY == 0);
        WRITE(32'hBBBBBBBB,32'h00000004,4'b1111);
        @(WR_BUSY == 0);
        WRITE(32'hCCCCCCCC,32'h00000008,4'b1111);
        @(WR_BUSY == 0);
        WRITE(32'hDDDDDDDD,32'h0000000C,4'b1111);
        @(WR_BUSY == 0);
        WRITE(32'hAAAAAA00,32'h00000000,4'b0001);
        @(WR_BUSY == 0);
        WRITE(32'hAAAA0000,32'h00000004,4'b0010);
        @(WR_BUSY == 0);
        WRITE(32'hAA00AA00,32'h00000008,4'b0100);
        @(WR_BUSY == 0);
        WRITE(32'h00AAAA00,32'h0000000C,4'b1000);       
        delay();
        READ(0);
        PROCESSOR_TAKES();

        READ(4);
        PROCESSOR_TAKES();
     
        READ(8);
        PROCESSOR_TAKES();
    
        READ(12);
        PROCESSOR_TAKES();
    endtask

endmodule