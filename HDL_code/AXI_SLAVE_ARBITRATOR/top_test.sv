`timescale 1ns/100ps
`include "./AXI_LITE_IF.sv"

module top_test();

    localparam int DATA_WIDTH = 32;
    localparam int STROBE_WIDTH	= DATA_WIDTH/8;
 
    localparam int AXIL_ADDR_WIDTH  = 32;
    localparam int NUM_REGS         = 4;
    localparam int NUM_AXIL_MASTERS = 4;
    localparam logic[AXIL_ADDR_WIDTH-1:0] PERIPH_BASE_ADDR = 32'h30000000;


    // AXI PROTOCOL
		logic AXI_ACLK 		;
		logic AXI_ARESETN		;
		// logic AXI_AWVALID		;
		
		// logic AXI_AWREADY		;
		// logic [31:0]AXI_AWADDR		;
			
		// logic [31:0]AXI_WDATA		;
		// logic [3:0]AXI_WSTRB		;
		// logic AXI_WVALID		;
		
		// logic AXI_WREADY		;
		
		// logic AXI_BREADY		;
		// logic AXI_BVALID		;
		// logic [1:0]AXI_BRESP		;
	    // logic [31:0]AXI_ARADDR		;	
		// logic AXI_ARVALID		;
		
		// logic AXI_ARREADY	 ;
				
		// logic [31:0]AXI_RDATA		;		
		// logic [1:0]AXI_RRESP		;
        // logic AXI_RVALID		;
		
		// logic AXI_RREADY		;

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

        // axi lite bus upstream
        AXI_LITE_IF #(
            .DATA_WIDTH(DATA_WIDTH),
            .AXIL_ADDR_WIDTH(AXIL_ADDR_WIDTH)
        ) AXIL_BUS_UPSTREAM();

        // axi lite bus downstream
        AXI_LITE_IF #(
            .DATA_WIDTH(DATA_WIDTH),
            .AXIL_ADDR_WIDTH(AXIL_ADDR_WIDTH)            
        ) AXIL_BUS_DOWNSTREAM[NUM_AXIL_MASTERS-1:0]();

    AXIL_MASTER #(
        .ADDR_WIDTH(DATA_WIDTH),
        .DATA_WIDTH(AXIL_ADDR_WIDTH)
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

        //MASTER bus
        .AXIL_MASTER(AXIL_BUS_UPSTREAM)

        // //Write address channel
        // .M_AXIL_AWVALID(AXI_AWVALID),
        // .M_AXIL_AWADDR(AXI_AWADDR),
        // .M_AXIL_AWREADY(AXI_AWREADY),

        // //Write data channel
        // .M_AXIL_WVALID(AXI_WVALID),
        // .M_AXIL_WDATA(AXI_WDATA),
        // .M_AXIL_WSTRB(AXI_WSTRB),
        // .M_AXIL_WREADY(AXI_WREADY),

        // //Write response channel
        // .M_AXIL_BREADY(AXI_BREADY),
        // .M_AXIL_BVALID(AXI_BVALID),
        // .M_AXIL_BRESP(AXI_BRESP),

        // //Read channel address
        // .M_AXIL_ARVALID(AXI_ARVALID),
        // .M_AXIL_ARADDR(AXI_ARADDR),
        // .M_AXIL_ARREADY(AXI_ARREADY),

        // //Read channel data 
        // .M_AXIL_RVALID(AXI_RVALID),
        // .M_AXIL_RDATA(AXI_RDATA),
        // .M_AXIL_RREADY(AXI_RREADY),

        // .M_AXIL_RRESP(AXI_RRESP)
    );


    AXIL_ARBITRATOR #(
        .DATA_WIDTH(DATA_WIDTH),
        .NUM_AXIL_MASTERS(NUM_AXIL_MASTERS),
        .PERIPH_BASE_ADDR(PERIPH_BASE_ADDR),       
        .AXIL_ADDR_WIDTH(AXIL_ADDR_WIDTH)
    ) ARBITRATOR_IP (

        .AXIL_ACLK(AXI_ACLK),
        .AXIL_RESETN(AXI_ARESETN),

        .S_AXIL(AXIL_BUS_UPSTREAM),

        .M_AXIL(AXIL_BUS_DOWNSTREAM)

	);

    generate
        for(genvar i=0;i<NUM_AXIL_MASTERS;i++) begin : GEN_AXIL_SLAVE
            AXIL_SLAVE_SV #(
                .DATA_WIDTH(DATA_WIDTH),
                .STROBE_WIDTH(STROBE_WIDTH),
                .AXIL_ADDR_WIDTH(AXIL_ADDR_WIDTH),
                .NUM_REGS(NUM_REGS),
                .ADDRLSB(2)
            ) AXIL_SLAVE_INST (
                .AXIL_ACLK(AXI_ACLK),
                .AXIL_RESETN(AXI_ARESETN),
                .S_AXIL(AXIL_BUS_DOWNSTREAM[i])
            );
        end
    endgenerate

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
        //main_test();
        //ADDRESS_WRONG();
        MIX();

        // repeat(2)
        //     @(negedge AXI_ACLK);
        // WRITE_WRONG_ADDR();
        // WRITE(32'hAAAAAAAA,32'h30000400,4'b1111);
        // @(WR_BUSY == 0);
        // WRITE(32'hBBBBBBBB,32'h30000404,4'b1111);
        // @(WR_BUSY == 0);

        // WRITE(32'hCCCCCCCC,32'h30000408,4'b1111);
        // @(WR_BUSY == 0);
        // WRITE(32'hDDDDDDDD,32'h3000040C,4'b1111);   
        // @(WR_BUSY == 0);
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

    task WRITE_WRONG_ADDR();
        WRITE(32'hDEADC0DE,32'h00000000,4'b1111);
        @(WR_BUSY == 0);
        WRITE(32'hDEADC0DE,32'h30001000,4'b1111);
        @(WR_BUSY == 0);
    endtask

    task READ_WRONG_ADDR();
        READ(32'h00000000);
        @((AXIL_BUS_UPSTREAM.RVALID == 1) && (AXIL_BUS_UPSTREAM.RREADY == 1));
        PROCESSOR_TAKES();
        READ(32'h30001000);
        @((AXIL_BUS_UPSTREAM.RVALID == 1) && (AXIL_BUS_UPSTREAM.RREADY == 1));
        PROCESSOR_TAKES();
    endtask

    task ADDRESS_WRONG();
        repeat(2)
            @(negedge AXI_ACLK);
        WRITE_WRONG_ADDR();
        READ_WRONG_ADDR();
    endtask
    
    //write wrong, write true, write wrong, write true
    //read wrong, read true, read wrong, read true
    task MIX();
        repeat(2)
            @(negedge AXI_ACLK);
        WRITE_WRONG_ADDR();

        WRITE(32'hAAAAAAAA,32'h30000000,4'b1111);
        @(WR_BUSY == 0);
        WRITE(32'hBBBBBBBB,32'h30000004,4'b1111);
        @(WR_BUSY == 0);
        WRITE_WRONG_ADDR();

        WRITE(32'hCCCCCCCC,32'h30000008,4'b1111);
        @(WR_BUSY == 0);
        WRITE(32'hDDDDDDDD,32'h3000000C,4'b1111);   
        @(WR_BUSY == 0);
        delay();
        
        READ_WRONG_ADDR();

        READ(32'h30000000);
        PROCESSOR_TAKES();

        READ(32'h30000004);
        PROCESSOR_TAKES();        

        READ_WRONG_ADDR();

        READ(32'h30000008);
        PROCESSOR_TAKES();
    
        READ(32'h3000000C);
        PROCESSOR_TAKES();

    endtask

    task main_test();
        repeat(2)
            @(negedge AXI_ACLK);
        WRITE(32'hAAAAAAAA,32'h30000000,4'b1111);
        @(WR_BUSY == 0);
        WRITE(32'hBBBBBBBB,32'h30000004,4'b1111);
        @(WR_BUSY == 0);
        WRITE(32'hCCCCCCCC,32'h30000008,4'b1111);
        @(WR_BUSY == 0);
        WRITE(32'hDDDDDDDD,32'h3000000C,4'b1111);
        @(WR_BUSY == 0);
        WRITE(1,32'h30000400,4'b1111);
        @(WR_BUSY == 0);
        WRITE(2,32'h30000404,4'b1111);
        @(WR_BUSY == 0);
        WRITE(3,32'h30000408,4'b1111);
        @(WR_BUSY == 0);
        WRITE(4,32'h3000040C,4'b1111);  
        @(WR_BUSY == 0);
        WRITE(5,32'h30000800,4'b1111);
        @(WR_BUSY == 0);
        WRITE(6,32'h30000804,4'b1111);
        @(WR_BUSY == 0);
        WRITE(7,32'h30000808,4'b1111);
        @(WR_BUSY == 0);
        WRITE(8,32'h3000080C,4'b1111);  
        @(WR_BUSY == 0);
        WRITE(9,32'h30000C00,4'b1111);
        @(WR_BUSY == 0);
        WRITE(10,32'h30000C04,4'b1111);
        @(WR_BUSY == 0);
        WRITE(11,32'h30000C08,4'b1111);
        @(WR_BUSY == 0);
        WRITE(12,32'h30000C0C,4'b1111);          

        delay();
                READ(32'h30000000);
        PROCESSOR_TAKES();

        READ(32'h30000004);
        PROCESSOR_TAKES();
     
        READ(32'h30000008);
        PROCESSOR_TAKES();
    
        READ(32'h3000000C);
        PROCESSOR_TAKES();

                READ(32'h30000400);
        PROCESSOR_TAKES();

        READ(32'h30000404);
        PROCESSOR_TAKES();
     
        READ(32'h30000408);
        PROCESSOR_TAKES();
    
        READ(32'h3000040C);
        PROCESSOR_TAKES();

                READ(32'h30000800);
        PROCESSOR_TAKES();

        READ(32'h30000804);
        PROCESSOR_TAKES();
     
        READ(32'h30000808);
        PROCESSOR_TAKES();
    
        READ(32'h3000080C);
        PROCESSOR_TAKES();

                READ(32'h30000C00);
        PROCESSOR_TAKES();

        READ(32'h30000C04);
        PROCESSOR_TAKES();
     
        READ(32'h30000C08);
        PROCESSOR_TAKES();
    
        READ(32'h30000C0C);
        PROCESSOR_TAKES();        
    endtask

endmodule