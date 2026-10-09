`include "./AXI_LITE_IF.sv"

module AXIL_SLAVE_SV #(
    parameter int DATA_WIDTH = 32,
    parameter int STROBE_WIDTH	= DATA_WIDTH/8,
 
    parameter int AXIL_ADDR_WIDTH  = 32,
    parameter int NUM_REGS         = 4,
    parameter int ADDRLSB = 2
)(
    input logic AXIL_ACLK,
    input logic AXIL_RESETN,

    //One external axil slave interface
    AXI_LITE_IF.SLAVE S_AXIL    
);

    AXIL_SLAVE_VHDL #(
        .DATA_WIDTH(DATA_WIDTH),
        .STROBE_WIDTH(STROBE_WIDTH),
        .NUM_REGS(NUM_REGS),       
        .AXIL_ADDR_WIDTH(AXIL_ADDR_WIDTH),
        .ADDRLSB(ADDRLSB)
    ) AXIL_SLAVE (
		.S_AXI_ACLK(AXIL_ACLK),
		.S_AXI_ARESETN(AXIL_RESETN),
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

endmodule