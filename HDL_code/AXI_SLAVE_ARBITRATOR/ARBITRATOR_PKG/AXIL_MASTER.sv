`timescale 1ns/100ps

module AXIL_MASTER #(
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32
)(

    //User - Processor data
    input logic START_WRITE,
    input logic[ADDR_WIDTH-1:0]WR_ADDR,
    input logic[DATA_WIDTH-1:0]WR_DATA,
    input logic[DATA_WIDTH/8-1:0]WR_STRB,

    input logic START_READ,
    input logic[ADDR_WIDTH-1:0]RD_ADDR,

    // Havent data taken by host
    output logic[DATA_WIDTH-1:0]RD_DATA,
    output logic RD_DATA_VALID,
    input logic HOST_RD_DATA_READY,

    //STATUS from PROCESSOR or user
    output logic WR_BUSY,
    output logic ERR_WR,
    output logic ERR_RD,


    //clock and reset
    input logic M_AXIL_ACLK,
    input logic M_AXIL_RSTN,

    //Write address channel
    output logic M_AXIL_AWVALID,
    output logic[ADDR_WIDTH-1:0] M_AXIL_AWADDR,
    input logic M_AXIL_AWREADY,

    //Write data channel
    output logic M_AXIL_WVALID,
    output logic[DATA_WIDTH-1:0] M_AXIL_WDATA,
    output logic [DATA_WIDTH/8-1:0] M_AXIL_WSTRB,
    input logic M_AXIL_WREADY,

    //Write response channel
    output logic M_AXIL_BREADY,
    input logic M_AXIL_BVALID,
    input logic[1:0] M_AXIL_BRESP,

    //Read channel address
    output logic M_AXIL_ARVALID,
    output logic[ADDR_WIDTH-1:0]M_AXIL_ARADDR,
    input logic M_AXIL_ARREADY,

    //Read channel data 
    input logic M_AXIL_RVALID,
    input logic[DATA_WIDTH-1:0]M_AXIL_RDATA,
    output logic M_AXIL_RREADY,

    input logic[1:0] M_AXIL_RRESP
);

    //Signals for write operation
    typedef enum logic[2:0] {
            st_WRITE_IDLE,
            st_WRITE_OPE,
            st_WR_DONE_ADDR,
            st_WR_DONE_DAT,
            st_WR_WAIT_BRESP,
            st_WRITE_ERROR
    } STATE_WR_t;
    STATE_WR_t WR_ACT_ST,WR_NX_ST; 
    
    logic ACT_M_AXIL_AWVALID,NX_M_AXIL_AWVALID;
    logic[ADDR_WIDTH-1:0] ACT_M_AXIL_AWADDR,NX_M_AXIL_AWADDR;

    logic ACT_M_AXIL_WVALID,NX_M_AXIL_WVALID;
    logic[DATA_WIDTH-1:0] ACT_M_AXIL_WDATA,NX_M_AXIL_WDATA;
    logic [DATA_WIDTH/8-1:0] ACT_M_AXIL_WSTRB,NX_M_AXIL_WSTRB;
    logic ACT_WR_BUSY,NX_WR_BUSY;


    //Signals for read operation
    typedef enum logic[1:0] {
            st_READ_IDLE,
            st_READ_OPE,
            st_RD_DONE_ADDR,
            st_READ_ERROR
    } STATE_RD_t;
    STATE_RD_t RD_ACT_ST,RD_NX_ST; 

    logic ACT_M_AXIL_ARVALID,NX_M_AXIL_ARVALID;
    logic[ADDR_WIDTH-1:0]ACT_M_AXIL_ARADDR,NX_M_AXIL_ARADDR;

    logic ACT_M_AXIL_RREADY,NX_M_AXIL_RREADY;

//*********Write Operation implementation::START**************//

    always_ff @(posedge M_AXIL_ACLK) begin
        if (!M_AXIL_RSTN) begin
            WR_ACT_ST <= st_WRITE_IDLE;
            ACT_M_AXIL_AWVALID <= 1'b0;
            ACT_M_AXIL_AWADDR <= 32'hDEADC0DE;
            ACT_M_AXIL_WVALID <= 1'b0;
            ACT_M_AXIL_WDATA <= 32'hDEADC0DE;
            ACT_M_AXIL_WSTRB <= 4'hF;
            ACT_WR_BUSY <= 1'b0;
        end
        else begin
            WR_ACT_ST <= WR_NX_ST;
            
            ACT_M_AXIL_AWVALID <= NX_M_AXIL_AWVALID;
            ACT_M_AXIL_AWADDR <= NX_M_AXIL_AWADDR;

            ACT_M_AXIL_WVALID <= NX_M_AXIL_WVALID;
            ACT_M_AXIL_WDATA <= NX_M_AXIL_WDATA;
            ACT_M_AXIL_WSTRB <= NX_M_AXIL_WSTRB;

            ACT_WR_BUSY <= NX_WR_BUSY;
        end
    end

    always_comb begin
        WR_NX_ST = WR_ACT_ST;
        
        NX_M_AXIL_AWADDR = ACT_M_AXIL_AWADDR;
        NX_M_AXIL_AWVALID = ACT_M_AXIL_AWVALID;
        
        NX_M_AXIL_WDATA = ACT_M_AXIL_WDATA;
        NX_M_AXIL_WVALID = ACT_M_AXIL_WVALID;
        NX_M_AXIL_WSTRB = ACT_M_AXIL_WSTRB;  

        NX_WR_BUSY = ACT_WR_BUSY;   

        case (WR_ACT_ST)
            st_WRITE_IDLE : begin
                if (START_WRITE == 1) begin
                    WR_NX_ST = st_WRITE_OPE;
                    
                    NX_M_AXIL_AWADDR = WR_ADDR;
                    NX_M_AXIL_AWVALID = 1'b1;
                    
                    NX_M_AXIL_WDATA = WR_DATA;
                    NX_M_AXIL_WVALID = 1'b1;
                    NX_M_AXIL_WSTRB = WR_STRB;
                    NX_WR_BUSY = 1'b1;
                end
            end
            st_WRITE_OPE : begin
                if ((ACT_M_AXIL_WVALID) && (M_AXIL_WREADY) 
                    && (ACT_M_AXIL_AWVALID) && (M_AXIL_AWREADY)) begin
                    WR_NX_ST = st_WR_WAIT_BRESP;

                    NX_M_AXIL_AWVALID = 1'b0;

                    NX_M_AXIL_WVALID = 1'b0;
                    NX_WR_BUSY = 1'b1;
                end

                else if ((ACT_M_AXIL_WVALID) && (M_AXIL_WREADY)) begin
                    WR_NX_ST = st_WR_DONE_DAT;

                    NX_M_AXIL_WVALID = 1'b0;
                end

                else if ((ACT_M_AXIL_AWVALID) && (M_AXIL_AWREADY)) begin
                    WR_NX_ST = st_WR_DONE_ADDR;

                    NX_M_AXIL_AWVALID = 1'b0;
                end
            end
            st_WR_DONE_DAT :begin
                if ((ACT_M_AXIL_AWVALID) && (M_AXIL_AWREADY)) begin
                    WR_NX_ST = st_WR_WAIT_BRESP;

                    NX_M_AXIL_AWVALID = 1'b0;
                    NX_WR_BUSY = 1'b1;
                end
            end
            st_WR_DONE_ADDR : begin
                if ((ACT_M_AXIL_WVALID) && (M_AXIL_WREADY)) begin
                    WR_NX_ST = st_WR_WAIT_BRESP;

                    NX_M_AXIL_WVALID = 1'b0;
                    NX_WR_BUSY = 1'b1;
                end
            end
            st_WR_WAIT_BRESP : begin
                if (M_AXIL_BREADY && M_AXIL_BVALID) begin
                    
                    if (M_AXIL_BRESP == 2'b00) begin
                        WR_NX_ST = st_WRITE_IDLE;
                        NX_WR_BUSY = 1'b0;
                    end
                    else begin
                        WR_NX_ST = st_WRITE_ERROR;
                    end
                end 
            end
            st_WRITE_ERROR : begin
                // For further development
                WR_NX_ST = st_WRITE_IDLE;
                NX_WR_BUSY = 1'b0;
            end
            default : 
                WR_NX_ST = st_WRITE_IDLE;
        endcase
    end

    always_ff @(posedge M_AXIL_ACLK) begin
        if (!M_AXIL_RSTN) 
            ERR_WR <= 1'b0;
        else begin
            if (WR_NX_ST == st_WRITE_ERROR) 
                ERR_WR <= 1'b1;
            else
                ERR_WR <= 1'b0;
        end
    end

    assign M_AXIL_AWVALID = ACT_M_AXIL_AWVALID;
    assign M_AXIL_AWADDR = ACT_M_AXIL_AWADDR;
    assign M_AXIL_WVALID = ACT_M_AXIL_WVALID;
    assign M_AXIL_WDATA = ACT_M_AXIL_WDATA;
    assign M_AXIL_WSTRB = ACT_M_AXIL_WSTRB;
    assign WR_BUSY = ACT_WR_BUSY;

    // Control BREADY
    always_ff @(posedge M_AXIL_ACLK) begin
        if (!M_AXIL_RSTN) begin
            M_AXIL_BREADY <= 1'b0;
        end
        else begin
            if (WR_ACT_ST == st_WRITE_OPE) begin
                M_AXIL_BREADY <= 1'b1;
            end
            else if (M_AXIL_BREADY && M_AXIL_BVALID) begin
                M_AXIL_BREADY <= 1'b0;
            end
        end
    end

//*********Write Operation implementation::END**************//


//*********READ Operation implementation::START**************//

    always_ff @(posedge M_AXIL_ACLK) begin
        if (!M_AXIL_RSTN) begin
            ACT_M_AXIL_ARVALID <= 1'b0;
            ACT_M_AXIL_ARADDR <= 32'hDEADC0DE;
            RD_ACT_ST <= st_READ_IDLE;
        end
        else begin
            ACT_M_AXIL_ARVALID <= NX_M_AXIL_ARVALID;
            ACT_M_AXIL_ARADDR <= NX_M_AXIL_ARADDR;
            RD_ACT_ST <= RD_NX_ST;
        end
    end

    always_comb begin
        NX_M_AXIL_ARVALID = ACT_M_AXIL_ARVALID;
        NX_M_AXIL_ARADDR = ACT_M_AXIL_ARADDR;

        RD_NX_ST = RD_ACT_ST;
        case(RD_ACT_ST)
            st_READ_IDLE : begin
                if (START_READ) begin
                    RD_NX_ST = st_READ_OPE;
                    NX_M_AXIL_ARVALID = 1'b1;
                    NX_M_AXIL_ARADDR = RD_ADDR;
                end
            end 
            st_READ_OPE : begin
                if ((ACT_M_AXIL_ARVALID) && (M_AXIL_ARREADY)) begin
                    RD_NX_ST = st_RD_DONE_ADDR;
                    NX_M_AXIL_ARVALID = 1'b0;
                end
            end       
            st_RD_DONE_ADDR : begin
                if ((M_AXIL_RVALID) && (M_AXIL_RREADY)) begin
                    if (M_AXIL_RRESP == 2'b00) 
                        RD_NX_ST = st_READ_IDLE;
                    else
                        RD_NX_ST = st_READ_ERROR;
                end 
            end
            st_READ_ERROR : begin
                // for further development
                RD_NX_ST = st_READ_IDLE;
            end
            default :
                RD_NX_ST = st_READ_IDLE;
        endcase
    end

    always_ff @(posedge M_AXIL_ACLK) begin
        if (!M_AXIL_RSTN) 
            ERR_RD <= 1'b0;
        else begin
            if (RD_NX_ST == st_READ_ERROR) 
                ERR_RD <= 1'b1;
            else
                ERR_RD <= 1'b0;
        end
    end

    //Store read data into a reg
    always_ff @(posedge M_AXIL_ACLK) begin
        if (!M_AXIL_RSTN) begin
            RD_DATA <= 32'hDEADC0DE;
            RD_DATA_VALID <= 1'b0;
            M_AXIL_RREADY <= 1'b1;
        end
        else if ((M_AXIL_RVALID) && (M_AXIL_RREADY)) begin
            RD_DATA <= M_AXIL_RDATA;
            RD_DATA_VALID <= 1'b1;
            M_AXIL_RREADY <= 1'b0;
        end
        else if ((RD_DATA_VALID) && (HOST_RD_DATA_READY)) begin
            RD_DATA_VALID <= 1'b0;
            M_AXIL_RREADY <= 1'b1;
        end
    end 


    assign M_AXIL_ARVALID = ACT_M_AXIL_ARVALID;
    assign M_AXIL_ARADDR = ACT_M_AXIL_ARADDR;

//*********READ Operation implementation::END**************//

endmodule