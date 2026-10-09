`include "./AXI_LITE_IF.sv"

module AXIL_ARBITRATOR #(
    parameter int DATA_WIDTH = 32,
 
    parameter int AXIL_ADDR_WIDTH  = 32,
    parameter int NUM_AXIL_MASTERS = 4,
    parameter logic[AXIL_ADDR_WIDTH-1:0] PERIPH_BASE_ADDR = 32'h30000000    
)(
    input logic AXIL_ACLK,
    input logic AXIL_RESETN,

    //One external axil slave interface
    AXI_LITE_IF.SLAVE S_AXIL,

    //Multi external axil master interface
    AXI_LITE_IF.MASTER M_AXIL [NUM_AXIL_MASTERS-1:0]

);


    logic [NUM_AXIL_MASTERS-1:0] m_awvalid;
    logic [NUM_AXIL_MASTERS-1:0] m_awready;

    logic [NUM_AXIL_MASTERS*AXIL_ADDR_WIDTH-1:0] m_awaddr;

    logic [NUM_AXIL_MASTERS-1:0] m_wvalid;
    logic [NUM_AXIL_MASTERS-1:0] m_wready;

    logic [NUM_AXIL_MASTERS*DATA_WIDTH-1:0] m_wdata;
    logic [NUM_AXIL_MASTERS*(DATA_WIDTH/8)-1:0] m_wstrb;

    logic [NUM_AXIL_MASTERS-1:0] m_bready;
    logic [NUM_AXIL_MASTERS-1:0] m_bvalid;
    logic [NUM_AXIL_MASTERS*2-1:0] m_bresp;

    logic [NUM_AXIL_MASTERS-1:0] m_arvalid;
    logic [NUM_AXIL_MASTERS-1:0] m_arready;

    logic [NUM_AXIL_MASTERS*AXIL_ADDR_WIDTH-1:0] m_araddr;

    logic [NUM_AXIL_MASTERS-1:0] m_rvalid;
    logic [NUM_AXIL_MASTERS-1:0] m_rready;

    logic [NUM_AXIL_MASTERS*DATA_WIDTH-1:0] m_rdata;
    logic [NUM_AXIL_MASTERS*2-1:0] m_rresp;



    //entity vhdl instantation
    AXIL_SLAVE_ARBITRATOR #(
        .DATA_WIDTH(DATA_WIDTH),
        .NUM_AXIL_MASTERS(NUM_AXIL_MASTERS),
        .PERIPH_BASE_ADDR(PERIPH_BASE_ADDR),       
        .AXIL_ADDR_WIDTH(AXIL_ADDR_WIDTH)
    )
    ARBITRATOR_IP
	(

        // N AXI-Lite master interfaces
        .M_AXIL_AWVALID (m_awvalid),
        .M_AXIL_AWADDR  (m_awaddr),
        .M_AXIL_AWREADY (m_awready),

        .M_AXIL_WVALID (m_wvalid),
        .M_AXIL_WDATA  (m_wdata),
        .M_AXIL_WSTRB (m_wstrb),
        .M_AXIL_WREADY (m_wready),

        .M_AXIL_BREADY (m_bready),
        .M_AXIL_BVALID (m_bvalid),
        .M_AXIL_BRESP  (m_bresp),

        .M_AXIL_ARVALID (m_arvalid),
        .M_AXIL_ARADDR  (m_araddr),
        .M_AXIL_ARREADY (m_arready),

        .M_AXIL_RVALID (m_rvalid),
        .M_AXIL_RDATA  (m_rdata),
        .M_AXIL_RREADY (m_rready),
        .M_AXIL_RRESP (m_rresp),


        // Axil slave interface
		.S_AXI_ACLK(AXIL_ACLK),
		.S_AXI_RESETN(AXIL_RESETN),
		.S_AXI_AWVALID(S_AXIL.AWVALID),
		
		.S_AXI_AWREADY(S_AXIL.AWREADY),
		.S_AXI_AWADDR(S_AXIL.AWADDR),
			
		.S_AXI_WDATA(S_AXIL.WDATA),
		.S_AXI_WSTRB(S_AXIL.WSTRB),
		.S_AXI_WVALID(S_AXIL.WVALID),
		
		.S_AXI_WREADY(S_AXIL.WREADY),

		.S_AXI_BREADY(S_AXIL.BREADY),
		.S_AXI_BVALID(S_AXIL.BVALID),
		.S_AXI_BRESP(S_AXIL.BRESP),
	    .S_AXI_ARADDR(S_AXIL.ARADDR),	
		.S_AXI_ARVALID(S_AXIL.ARVALID),
		
		.S_AXI_ARREADY(S_AXIL.ARREADY),
				
		.S_AXI_RDATA(S_AXIL.RDATA),		
		.S_AXI_RRESP(S_AXIL.RRESP),
        .S_AXI_RVALID(S_AXIL.RVALID),
		.S_AXI_RREADY(S_AXIL.RREADY)
	);

    generate
        for(genvar i=0; i<NUM_AXIL_MASTERS;i++) begin : GEN_AXIL_MASTER
            // write address
            assign M_AXIL[i].AWVALID = m_awvalid[i];
            assign m_awready[i] = M_AXIL[i].AWREADY;
            assign M_AXIL[i].AWADDR = m_awaddr[AXIL_ADDR_WIDTH*(i+1)-1:AXIL_ADDR_WIDTH*i];

            // write data
            assign M_AXIL[i].WVALID = m_wvalid[i];
            assign m_wready[i] = M_AXIL[i].WREADY;
            assign M_AXIL[i].WDATA = m_wdata[DATA_WIDTH*(i+1)-1:DATA_WIDTH*i];
            assign M_AXIL[i].WSTRB = m_wstrb[(DATA_WIDTH/8)*(i+1)-1:(DATA_WIDTH/8)*i];

            // Brespond
            assign M_AXIL[i].BREADY = m_bready[i];
            assign m_bvalid[i] = M_AXIL[i].BVALID;
            assign m_bresp[2*(i+1)-1:2*i] = M_AXIL[i].BRESP;

            // read address
            assign M_AXIL[i].ARVALID = m_arvalid[i];
            assign m_arready[i] = M_AXIL[i].ARREADY;
            assign M_AXIL[i].ARADDR = m_araddr[AXIL_ADDR_WIDTH*(i+1)-1:AXIL_ADDR_WIDTH*i];
            
            // read data
            assign m_rvalid[i] = M_AXIL[i].RVALID;
            assign M_AXIL[i].RREADY = m_rready[i];
            assign m_rdata[DATA_WIDTH*(i+1)-1:DATA_WIDTH*i] = M_AXIL[i].RDATA;
            assign m_rresp[2*(i+1)-1:2*i] = M_AXIL[i].RRESP;
        end
    endgenerate
    
endmodule