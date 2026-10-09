`include "./AXI_LITE_IF.sv"

module AXIL_MASTER_WRAPPER #(
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32
)(
    // ============================================================
    // User interface
    // ============================================================
    input  logic                     START_WRITE,
    input  logic [ADDR_WIDTH-1:0]     WR_ADDR,
    input  logic [DATA_WIDTH-1:0]     WR_DATA,
    input  logic [DATA_WIDTH/8-1:0]   WR_STRB,

    input  logic                     START_READ,
    input  logic [ADDR_WIDTH-1:0]     RD_ADDR,

    output logic [DATA_WIDTH-1:0]     RD_DATA,
    output logic                     RD_DATA_VALID,
    input  logic                     HOST_RD_DATA_READY,

    output logic                     WR_BUSY,
    output logic                     ERR_WR,
    output logic                     ERR_RD,

    // ============================================================
    // Clock and reset
    // ============================================================
    input logic                       M_AXIL_ACLK,
    input logic                       M_AXIL_RSTN,

    // ============================================================
    // AXI-Lite Master Interface
    // ============================================================

    // Write Address Channel
    output logic [ADDR_WIDTH-1:0]     M_AXIL_AWADDR,
    output logic                      M_AXIL_AWVALID,
    input  logic                       M_AXIL_AWREADY,

    // Write Data Channel
    output logic [DATA_WIDTH-1:0]     M_AXIL_WDATA,
    output logic [DATA_WIDTH/8-1:0]   M_AXIL_WSTRB,
    output logic                      M_AXIL_WVALID,
    input  logic                       M_AXIL_WREADY,

    // Write Response Channel
    input  logic [1:0]                 M_AXIL_BRESP,
    input  logic                       M_AXIL_BVALID,
    output logic                       M_AXIL_BREADY,

    // Read Address Channel
    output logic [ADDR_WIDTH-1:0]     M_AXIL_ARADDR,
    output logic                      M_AXIL_ARVALID,
    input  logic                       M_AXIL_ARREADY,

    // Read Data Channel
    input  logic [DATA_WIDTH-1:0]     M_AXIL_RDATA,
    input  logic [1:0]                 M_AXIL_RRESP,
    input  logic                       M_AXIL_RVALID,
    output logic                       M_AXIL_RREADY
);

    // ============================================================
    // AXI-Lite Interface
    // ============================================================

    AXI_LITE_IF #(
        .DATA_WIDTH      (DATA_WIDTH),
        .AXIL_ADDR_WIDTH (ADDR_WIDTH)
    ) axi_if();


    // ============================================================
    // External AXI-Lite signals -> Interface
    // ============================================================

    assign axi_if.AWREADY = M_AXIL_AWREADY;
    assign axi_if.WREADY  = M_AXIL_WREADY;

    assign axi_if.BRESP   = M_AXIL_BRESP;
    assign axi_if.BVALID  = M_AXIL_BVALID;

    assign axi_if.ARREADY = M_AXIL_ARREADY;

    assign axi_if.RDATA   = M_AXIL_RDATA;
    assign axi_if.RRESP   = M_AXIL_RRESP;
    assign axi_if.RVALID  = M_AXIL_RVALID;


    // ============================================================
    // Interface -> External AXI-Lite signals
    // ============================================================

    // Write Address Channel
    assign M_AXIL_AWADDR  = axi_if.AWADDR;
    assign M_AXIL_AWVALID = axi_if.AWVALID;

    // Write Data Channel
    assign M_AXIL_WDATA   = axi_if.WDATA;
    assign M_AXIL_WSTRB   = axi_if.WSTRB;
    assign M_AXIL_WVALID  = axi_if.WVALID;

    // Write Response Channel
    assign M_AXIL_BREADY  = axi_if.BREADY;

    // Read Address Channel
    assign M_AXIL_ARADDR  = axi_if.ARADDR;
    assign M_AXIL_ARVALID = axi_if.ARVALID;

    // Read Data Channel
    assign M_AXIL_RREADY  = axi_if.RREADY;


    // ============================================================
    // AXI-Lite Master
    // ============================================================

    AXIL_MASTER #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH)
    ) u_axil_master (
        // User interface
        .START_WRITE        (START_WRITE),
        .WR_ADDR            (WR_ADDR),
        .WR_DATA            (WR_DATA),
        .WR_STRB            (WR_STRB),

        .START_READ         (START_READ),
        .RD_ADDR            (RD_ADDR),

        .RD_DATA            (RD_DATA),
        .RD_DATA_VALID      (RD_DATA_VALID),
        .HOST_RD_DATA_READY (HOST_RD_DATA_READY),

        .WR_BUSY            (WR_BUSY),
        .ERR_WR             (ERR_WR),
        .ERR_RD             (ERR_RD),

        // Clock and reset
        .M_AXIL_ACLK        (M_AXIL_ACLK),
        .M_AXIL_RSTN        (M_AXIL_RSTN),

        // AXI-Lite interface
        .AXIL_MASTER        (axi_if.MASTER)
    );

endmodule
