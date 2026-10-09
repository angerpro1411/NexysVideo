interface AXI_LITE_IF #(
    parameter int DATA_WIDTH = 32,
    parameter int AXIL_ADDR_WIDTH  = 32
);
    logic [AXIL_ADDR_WIDTH-1:0] AWADDR;
    logic                  AWVALID;
    logic                  AWREADY;

    logic [DATA_WIDTH-1:0] WDATA;
    logic [DATA_WIDTH/8-1:0] WSTRB;
    logic                  WVALID;
    logic                  WREADY;

    logic [1:0] BRESP;
    logic       BVALID;
    logic       BREADY;

    logic [AXIL_ADDR_WIDTH-1:0] ARADDR;
    logic                  ARVALID;
    logic                  ARREADY;

    logic [DATA_WIDTH-1:0] RDATA;
    logic [1:0]            RRESP;
    logic                  RVALID;
    logic                  RREADY;

    modport MASTER (
        output AWADDR,
        output AWVALID,
        input  AWREADY,

        output WDATA,
        output WSTRB,
        output WVALID,
        input  WREADY,

        input  BRESP,
        input  BVALID,
        output BREADY,

        output ARADDR,
        output ARVALID,
        input  ARREADY,

        input  RDATA,
        input  RRESP,
        input  RVALID,
        output RREADY
    );

    modport SLAVE (
        input  AWADDR,
        input  AWVALID,
        output AWREADY,

        input  WDATA,
        input  WSTRB,
        input  WVALID,
        output WREADY,

        output BRESP,
        output BVALID,
        input  BREADY,

        input  ARADDR,
        input  ARVALID,
        output ARREADY,

        output RDATA,
        output RRESP,
        output RVALID,
        input  RREADY
    );

endinterface;
